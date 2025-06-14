extends Node
class_name InventoryService

var _inventory_repository: InventoryRepository = InventoryRepository.instance

## 注册背包
## 如果已经有了，则检查要注册的大小是否和已有的数据一致
## 如果还没有，则新增背包数据
func regist_inventory(inv_name: String, columns: int, rows: int, avilable_types: Array[GBIS.ItemType]) -> bool:
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

## 向指定背包添加物品
## 注意：此处传入的 item_data 将被复制，以确保多个相同物品的 data 互相独立
func add_item(inv_name: String, item_data: ItemData) -> bool:
	var new_data = item_data.duplicate()
	var grids = _inventory_repository.add_item(inv_name, new_data)
	if not grids.is_empty():
		GBIS.sig_inv_item_added.emit(inv_name, new_data, grids)
		return true
	return false

func find_item_data_by_id(inv_name: String, item_id: String) -> Array[ItemData]:
	var inv = _inventory_repository.get_inventory(inv_name)
	if inv:
		return inv.find_item_data_by_id(item_id)
	return []

func find_item_data_by_grid(inv_name: String, grid_id: Vector2i) -> ItemData:
	return _inventory_repository.find_item_data_by_grid(inv_name, grid_id)

func split_item(inv_name: String, grid_id: Vector2i) -> ItemData:
	var inv = _inventory_repository.get_inventory(inv_name)
	if inv:
		var item = inv.find_item_data_by_grid(grid_id)
		if item and item.stack_size > 1 and item.current_amount > 1:
			var origin_amount = item.current_amount
			var new_amount_1 = origin_amount / 2
			var new_amount_2 = origin_amount - new_amount_1
			item.current_amount = new_amount_1
			GBIS.sig_inv_item_updated_grid_id.emit(inv_name, grid_id)
			var new_item = item.duplicate()
			new_item.current_amount = new_amount_2
			return new_item
	return null

func is_inventory_existed(inv_name: String) -> bool:
	return _inventory_repository.get_inventory(inv_name) != null

func place_to(inv_name: String, item_data: ItemData, grid_id: Vector2i) -> bool:
	if item_data:
		var inv = _inventory_repository.get_inventory(inv_name)
		if inv:
			var grids = inv.try_add_to_grid(item_data, grid_id - GBIS.moving_item_offset)
			if grids:
				GBIS.sig_inv_item_added.emit(inv_name, item_data, grids)
				return true
	return false

func quick_move(inv_name: String, grid_id: Vector2i) -> void:
	var target_inventories = _inventory_repository.get_quick_move_relations(inv_name)
	var item_to_move = _inventory_repository.find_item_data_by_grid(inv_name, grid_id)
	if target_inventories.is_empty() or not item_to_move:
		return
	for target_inv in target_inventories:
		var grids = _inventory_repository.add_item(target_inv, item_to_move)
		if not grids.is_empty():
			_inventory_repository.remove_item(inv_name, item_to_move)
			GBIS.sig_inv_item_added.emit(target_inv, item_to_move, grids)
			GBIS.sig_inv_item_removed.emit(inv_name, item_to_move)
			return
	
func is_item_avilable(inv_name: String, item_data: ItemData) -> bool:
	var inv = _inventory_repository.get_inventory(inv_name)
	if inv:
		return inv.is_item_avilable(item_data)
	return false

func add_quick_move_relation(inv_name: String, target_inv_name: String) -> void:
	_inventory_repository.add_quick_move_relation(inv_name, target_inv_name)

func remove_quick_move_relation(inv_name: String, target_inv_name: String) -> void:
	_inventory_repository.remove_quick_move_relation(inv_name, target_inv_name)

## 移除指定背包中的指定物品
func remove_item_by_data(inv_name: String, item_data: ItemData) -> void:
	if _inventory_repository.remove_item(inv_name, item_data):
		GBIS.sig_inv_item_removed.emit(inv_name, item_data)
