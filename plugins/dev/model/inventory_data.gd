extends Resource
class_name InventoryData

signal sig_item_added(item: ItemData, grids: Array[Vector2i])
signal sig_item_removed(item: ItemData)

@export var columns: int = 2
@export var rows: int = 2

var _items: Array[ItemData] = []
var _item_grids_map: Dictionary[ItemData, Array]
var _grid_item_map: Dictionary[Vector2i, ItemData] = {} 

func _init(new_columns: int, new_rows: int) -> void:
	columns = new_columns
	rows = new_rows
	for row in rows:
		for col in columns:
			var pos = Vector2i(col, row)
			_grid_item_map[pos] = null

## 尝试把物品添加到第一个空位
## 成功返回true
## 失败返回false
func add_item(item: ItemData) -> bool:
	# 检查位置有效性
	var grids = _find_first_availble_grids(item)
	if not grids.is_empty():
		_items.append(item)
		_item_grids_map[item] = []
		sig_item_added.emit(item, grids)
		return true
	return false

## 如果容器中有这个物品，删除所有信息
func remove_item(item: ItemData) -> void:
	if _items.has(item):
		var grids = _item_grids_map[item]
		for grid in grids:
			_grid_item_map[grid] = null
		_items.erase(item)
		_item_grids_map.erase(item)
		sig_item_removed.emit(item)

## 找到第一个可以放下这个物品的格子
## 如果有，返回所有格子的数组
## 如果没有，返回空数组
func _find_first_availble_grids(item: ItemData) -> Array[Vector2i]:
	var item_shape = item.get_shape()
	for row in rows:
		for col in columns:
			# 如果当前格子中没有东西，则判断能否放下这个物品的形状
			if _grid_item_map[Vector2i(col, row)] == null:
				var grids = _try_get_empty_grids_by_shape(Vector2i(col, row), item.get_shape())
				if not grids.is_empty():
					return grids
	return []

## 从start（左上角）开始的位置
## 如果可以放下这个shape，返回所有格子的数组
## 否则返回空数组
func _try_get_empty_grids_by_shape(start: Vector2i, shape: Vector2i) -> Array[Vector2i]:
	var ret = []
	for row in shape.y:
		for col in shape.x:
			var grid = Vector2i(start.x + col, start.y + row)
			if _grid_item_map[grid] == null:
				ret.append(grid)
			else:
				return []
	return ret
