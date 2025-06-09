extends Node
class_name InventoryController

var _inventory_datas: Dictionary[String, InventoryData]

func new_inventory(inv_name: String, columns: int, row: int) -> bool:
	if _inventory_datas.has(inv_name):
		push_error("容器名已存在: %s" % inv_name)
		return false
	_inventory_datas[inv_name] = InventoryData.new(columns, row)
	return true
