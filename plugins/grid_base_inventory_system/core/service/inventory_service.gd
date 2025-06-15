extends Node
class_name InventoryService

var _inventory_repository: InventoryRepository = InventoryRepository.instance

func save() -> void:
	_inventory_repository.save()

func load() -> void:
	_inventory_repository.load()

func regist_inventory(inv_name: String, columns: int, rows: int, avilable_types: Array[String]) -> bool:
	var inv_data = _inventory_repository.get_inventory(inv_name)
	if inv_data:
		var is_same_size = inv_data.rows == rows and inv_data.columns == columns
		var is_same_avilable_types = avilable_types.size() == inv_data.avilable_types.size()
		if is_same_avilable_types:
			for i in range(avilable_types.size()):
				is_same_avilable_types = avilable_types[i] == inv_data.avilable_types[i]
				if not is_same_avilable_types:
					break
		return is_same_size && is_same_avilable_types
	else:
		return _inventory_repository.add_inventory(inv_name, columns, rows, avilable_types)

func get_inv_by_name(inv_name: String) -> InventoryData:
	return _inventory_repository.get_inventory(inv_name)

func add_item(inv_name: String, item_data: ItemData) -> bool:
	var new_item_data = item_data.duplicate()
	if new_item_data is StackableData:
		var items = find_item_data_by_item_name(inv_name, new_item_data.item_name)
		for item in items:
			if not item.is_full():
				new_item_data.current_amount = item.add_amount(new_item_data.current_amount)
				var old_item_grids = _inventory_repository.get_inventory(inv_name).find_grids_by_item_data(item)
				assert(not old_item_grids.is_empty())
				GBIS.sig_inv_item_updated_grid_id.emit(inv_name, old_item_grids[0])
				if new_item_data.current_amount <= 0:
					return true
		if new_item_data.current_amount <= 0:
			return true
	
	var grids = _inventory_repository.get_inventory(inv_name).add_item(new_item_data)
	if not grids.is_empty():
		GBIS.sig_inv_item_added.emit(inv_name, new_item_data, grids)
		return true
	return false

func stack_item(inv_name: String, grid_id: Vector2i) -> void:
	if not GBIS.moving_item_service.moving_item:
		return
	var item_data = find_item_data_by_grid(inv_name, grid_id)
	if item_data.item_name == GBIS.moving_item_service.moving_item.item_name:
		var amount_left = item_data.add_amount(GBIS.moving_item_service.moving_item.current_amount)
		if amount_left > 0:
			GBIS.moving_item_service.moving_item.current_amount = amount_left
		else:
			GBIS.moving_item_service.clear_moving_item()
		GBIS.sig_inv_item_updated_item_data.emit(inv_name, item_data)

func place_moving_item(inv_name: String, grid_id: Vector2i) -> bool:
	if place_to(inv_name, GBIS.moving_item_service.moving_item, grid_id):
		GBIS.moving_item_service.clear_moving_item()
		return true
	return false

func use_item(inv_name: String, grid_id: Vector2i) -> bool:
	var item_data = find_item_data_by_grid(inv_name, grid_id)
	if not item_data:
		return false
	if item_data is EquipmentData:
		if GBIS.equipment_slot_service.try_equip(item_data):
			remove_item_by_data(inv_name, item_data)
			return true
	elif item_data is ConsumableData:
		if item_data.use():
			remove_item_by_data(inv_name, item_data)
		else:
			GBIS.sig_inv_item_updated_grid_id.emit(inv_name, grid_id)
		return true
	return false

func find_item_data_by_item_name(inv_name: String, item_name: String) -> Array[ItemData]:
	var inv = _inventory_repository.get_inventory(inv_name)
	if inv:
		return inv.find_item_data_by_item_name(item_name)
	return []

func find_item_data_by_grid(inv_name: String, grid_id: Vector2i) -> ItemData:
	return _inventory_repository.get_inventory(inv_name).find_item_data_by_grid(grid_id)

func split_item(inv_name: String, grid_id: Vector2i, offset: Vector2i, base_size: int) -> ItemData:
	var inv = _inventory_repository.get_inventory(inv_name)
	if inv:
		var item = inv.find_item_data_by_grid(grid_id)
		if item and item is StackableData and item.stack_size > 1 and item.current_amount > 1:
			var origin_amount = item.current_amount
			var new_amount_1 = origin_amount / 2
			var new_amount_2 = origin_amount - new_amount_1
			item.current_amount = new_amount_1
			GBIS.sig_inv_item_updated_grid_id.emit(inv_name, grid_id)
			
			var new_item = item.duplicate()
			new_item.current_amount = new_amount_2
			GBIS.moving_item_service.draw_moving_item(new_item, offset, base_size)
			return new_item
	return null

func is_inventory_existed(inv_name: String) -> bool:
	return _inventory_repository.get_inventory(inv_name) != null

func place_to(inv_name: String, item_data: ItemData, grid_id: Vector2i) -> bool:
	if item_data:
		var inv = _inventory_repository.get_inventory(inv_name)
		if inv:
			var grids = inv.try_add_to_grid(item_data, grid_id - GBIS.moving_item_service.moving_item_offset)
			if grids:
				GBIS.sig_inv_item_added.emit(inv_name, item_data, grids)
				return true
	return false

func quick_move(inv_name: String, grid_id: Vector2i) -> void:
	var target_inventories = _inventory_repository.get_quick_move_relations(inv_name)
	var item_to_move = _inventory_repository.get_inventory(inv_name).find_item_data_by_grid(grid_id)
	if target_inventories.is_empty() or not item_to_move:
		return
	for target_inventory in target_inventories:
		if add_item(target_inventory, item_to_move):
			remove_item_by_data(inv_name, item_to_move)
			break
	
func is_item_avilable(inv_name: String, item_data: ItemData) -> bool:
	var inv = _inventory_repository.get_inventory(inv_name)
	if inv:
		return inv.is_item_avilable(item_data)
	return false

func add_quick_move_relation(inv_name: String, target_inv_name: String) -> void:
	_inventory_repository.add_quick_move_relation(inv_name, target_inv_name)

func remove_quick_move_relation(inv_name: String, target_inv_name: String) -> void:
	_inventory_repository.remove_quick_move_relation(inv_name, target_inv_name)

func remove_item_by_data(inv_name: String, item_data: ItemData) -> void:
	if _inventory_repository.get_inventory(inv_name).remove_item(item_data):
		GBIS.sig_inv_item_removed.emit(inv_name, item_data)
