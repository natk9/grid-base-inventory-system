extends Node

signal sig_item_added(inv_name: String, item_data: ItemData, grids: Array[Vector2i])
signal sig_item_removed(inv_name: String, item_data: ItemData)

var _inventroy_repository: InventoryRepository = InventoryRepository.new()

func regist_inventory(inv_name: String, columns: int, rows: int) -> bool:
	var inv_data = _inventroy_repository.get_inventory(inv_name)
	if inv_data:
		var is_same_size = inv_data.rows == rows and inv_data.columns == columns
		return is_same_size
	else:
		return _inventroy_repository.add_inventory(inv_name, columns, rows)

## 向指定背包添加物品
## 注意：此处传入的 item_data 将被复制，以确保多个相同物品的 data 互相独立
func add_item(inv_name: String, item_data: ItemData) -> void:
	var new_data = item_data.duplicate()
	var grids = _inventroy_repository.add_item(inv_name, new_data)
	if not grids.is_empty():
		sig_item_added.emit(inv_name, new_data, grids)

## 移除指定背包中的指定物品
## 注意：此处的 item_data 必须是背包中的实际数据，不能是 load 出来的 Resource
##      添加到背包中的时候，item_data 被复制了，以确保多个相同物品的 data 互相独立
func remove_item(inv_name: String, item_data: ItemData) -> void:
	if _inventroy_repository.remove_item(inv_name, item_data):
		sig_item_removed.emit(inv_name, item_data)

func move_item(inv_name: String, item_data: ItemData) -> void:
	# 从原背包中删除物品
	remove_item(inv_name, item_data)
	# 创建正在移动的物品 View
