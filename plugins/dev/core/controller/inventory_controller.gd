extends Node

signal sig_item_added(inv_name: String, item_data: ItemData, grids: Array[Vector2i])
signal sig_item_removed(inv_name: String, item_data: ItemData)
signal sig_item_moved(inv_name:String, item_data: ItemData, target_grids: Array[Vector2i])

var _inventory_datas: Dictionary[String, InventoryData]

func regist_inventory(inv_name: String, columns: int, rows: int) -> bool:
	if not _inventory_datas.has(inv_name):
		_inventory_datas[inv_name] = InventoryData.new(columns, rows)
	else:
		var inv_data = _inventory_datas[inv_name]
		if inv_data.rows != rows or inv_data.columns != columns:
			push_error("Inventory [%s] has existed but with different size." % inv_name)
			return false
	return true

func add_item(inv_name: String, item_data: ItemData) -> bool:
	var grids = _inventory_datas[inv_name].add_item(item_data)
	if not grids.is_empty():
		sig_item_added.emit(inv_name, item_data, grids)
		return true
	return false
