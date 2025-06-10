extends Node

signal sig_item_added(inv_name: String, item_data: ItemData, grids: Array[Vector2i])
signal sig_item_removed(inv_name: String, item_data: ItemData)

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

## 向指定背包添加物品
## 成功：返回复制后的 ItemData
## 失败，返回 null
func add_item(inv_name: String, item_data: ItemData) -> ItemData:
	var new_data = item_data.duplicate()
	var grids = _inventory_datas[inv_name].add_item(new_data)
	if not grids.is_empty():
		sig_item_added.emit(inv_name, new_data, grids)
		return new_data
	return null

func remove_item(inv_name: String, item_data: ItemData) -> void:
	var inv = _inventory_datas[inv_name]
	if inv.has_item(item_data):
		inv.remove_item(item_data)
		sig_item_removed.emit(inv_name, item_data)

func move_item(inv_name: String, item_data: ItemData) -> void:
	# 从原背包中删除物品
	remove_item(inv_name, item_data)
	# 创建正在移动的物品 View
