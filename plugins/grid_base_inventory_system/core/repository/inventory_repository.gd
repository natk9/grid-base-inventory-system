extends Resource
class_name InventoryRepository

const PREFIX: String = "inv_"

static var instance: InventoryRepository:
	get:
		if not instance:
			instance = InventoryRepository.new()
		return instance

@export_storage var _inventory_data_map: Dictionary[String, InventoryData]
@export_storage var _quick_move_relations_map: Dictionary[String, Array] # Array[inv_name: String]

func save() -> void:
	ResourceSaver.save(self, GBIS.current_save_path + PREFIX + GBIS.current_save_name)

func load() -> void:
	var saved_repository: InventoryRepository = load(GBIS.current_save_path + PREFIX + GBIS.current_save_name)
	if not saved_repository:
		return
	for inv_name in saved_repository._inventory_data_map.keys():
		_inventory_data_map[inv_name] = saved_repository._inventory_data_map[inv_name].deep_duplicate()
	_quick_move_relations_map = saved_repository._quick_move_relations_map.duplicate(true)

func add_inventory(inv_name: String, columns: int, rows: int, avilable_types: Array[GBIS.ItemType]) -> bool:
	var inv = get_inventory(inv_name)
	if not inv:
		_inventory_data_map[inv_name] = InventoryData.new(inv_name, columns, rows, avilable_types)
		return true
	return false

func get_inventory(inv_name: String) -> InventoryData:
	return _inventory_data_map.get(inv_name)

func add_item(inv_name: String, item_data: ItemData) -> Array[Vector2i]:
	var inv = get_inventory(inv_name)
	if inv:
		return inv.add_item(item_data)
	return []

func remove_item(inv_name: String, item_data: ItemData) -> bool:
	var inv = get_inventory(inv_name)
	if inv.has_item(item_data):
		inv.remove_item(item_data)
		return true
	return false

func find_item_data_by_grid(inv_name: String, grid_id: Vector2i) -> ItemData:
	var inv = get_inventory(inv_name)
	if inv:
		return inv.find_item_data_by_grid(grid_id)
	return null

func add_quick_move_relation(inv_name: String, target_inv_name: String) -> void:
	if _quick_move_relations_map.has(inv_name):
		var relations = _quick_move_relations_map[inv_name]
		relations.append(target_inv_name)
	else:
		var arr: Array[String] = [target_inv_name]
		_quick_move_relations_map[inv_name] = arr

func remove_quick_move_relation(inv_name: String, target_inv_name: String) -> void:
	if _quick_move_relations_map.has(inv_name):
		var relations = _quick_move_relations_map[inv_name]
		relations.erase(target_inv_name)

func remove_quick_move_relations(inv_name: String) -> void:
	_quick_move_relations_map.erase(inv_name)

func get_quick_move_relations(inv_name: String) -> Array[String]:
	return _quick_move_relations_map.get(inv_name, [])
