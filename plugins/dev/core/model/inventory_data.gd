extends Resource
class_name InventoryData

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
## 成功返回占用的格子
## 失败返回空数组
func add_item(item: ItemData) -> Array[Vector2i]:
	# 检查位置有效性
	var grids = _find_first_availble_grids(item)
	if not grids.is_empty():
		_items.append(item)
		_item_grids_map[item] = grids
		for grid in grids:
			_grid_item_map[grid] = item
		return grids
	return [] as Array[Vector2i]

## 如果容器中有这个物品，删除所有信息
func remove_item(item: ItemData) -> void:
	if _items.has(item):
		var grids = _item_grids_map[item]
		for grid in grids:
			_grid_item_map[grid] = null
		_items.erase(item)
		_item_grids_map.erase(item)

func has_item(item: ItemData) -> bool:
	return _items.has(item)

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
	return [] as Array[Vector2i]

## 从start（左上角）开始的位置
## 如果可以放下这个shape，返回所有格子的数组
## 否则返回空数组
func _try_get_empty_grids_by_shape(start: Vector2i, shape: Vector2i) -> Array[Vector2i]:
	var ret = [] as Array[Vector2i]
	for row in shape.y:
		for col in shape.x:
			var grid = Vector2i(start.x + col, start.y + row)
			if _grid_item_map[grid] == null:
				ret.append(grid)
			else:
				return [] as Array[Vector2i]
	return ret
