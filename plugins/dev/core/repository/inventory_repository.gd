extends Node
class_name InventoryRepository

var _inventory_datas: Dictionary[String, InventoryData]

func add_inventory(inv_name: String, columns: int, rows: int, avilable_types: Array[ItemData.Type]) -> bool:
	var inv = get_inventory(inv_name)
	if not inv:
		_inventory_datas[inv_name] = InventoryData.new(columns, rows, avilable_types)
		return true
	return false

func get_inventory(inv_name: String) -> InventoryData:
	if _inventory_datas.has(inv_name):
		return _inventory_datas[inv_name]
	return null

func add_item(inv_name: String, item_data: ItemData) -> Array[Vector2i]:
	var inv = get_inventory(inv_name)
	if inv:
		return inv.add_item(item_data)
	return [] as Array[Vector2i]

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
