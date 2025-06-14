extends Resource
class_name InventoryData

@export var columns: int = 2
@export var rows: int = 2

var avilable_types: Array[GBIS.ItemType]
var inv_name: String

var _items: Array[ItemData] = []
var _item_grids_map: Dictionary[ItemData, Array] # Array[grid_id: Vector2i]
var _grid_item_map: Dictionary[Vector2i, ItemData] = {} 

## 尝试把物品添加到第一个空位
## 成功返回占用的格子
## 失败返回空数组
func add_item(item_data: ItemData) -> Array[Vector2i]:
	if not is_item_avilable(item_data):
		return []
	var grids = _find_first_availble_grids(item_data)
	_add_item_to_grids(item_data, grids)
	return grids

## 如果容器中有这个物品，删除所有信息
func remove_item(item: ItemData) -> void:
	if _items.has(item):
		var grids = _item_grids_map[item]
		for grid in grids:
			_grid_item_map[grid] = null
		_items.erase(item)
		_item_grids_map.erase(item)

func is_item_avilable(item_data: ItemData) -> bool:
	return avilable_types.has(GBIS.ItemType.ALL) or avilable_types.has(item_data.type)

func has_item(item: ItemData) -> bool:
	return _items.has(item)

func find_item_data_by_grid(grid_id: Vector2i) -> ItemData:
	return _grid_item_map.get(grid_id)

func try_add_to_grid(item_data: ItemData, grid_id: Vector2i) -> Array[Vector2i]:
	if not is_item_avilable(item_data):
		return []
	var grids = _try_get_empty_grids_by_shape(grid_id, item_data.get_shape())
	_add_item_to_grids(item_data, grids)
	return grids

func find_item_data_by_id(item_id: String) -> Array[ItemData]:
	var ret: Array[ItemData] = []
	for item in _items:
		if item.item_id == item_id:
			ret.append(item)
	return ret

@warning_ignore("shadowed_variable")
func _init(inv_name: String, columns: int, rows: int, avilable_types: Array[GBIS.ItemType]) -> void:
	self.inv_name = inv_name
	self.avilable_types = avilable_types
	self.columns = columns
	self.rows = rows
	for row in rows:
		for col in columns:
			var pos = Vector2i(col, row)
			_grid_item_map[pos] = null

func _add_item_to_grids(item_data: ItemData, grids: Array[Vector2i]) -> bool:
	if not grids.is_empty():
		_items.append(item_data)
		_item_grids_map[item_data] = grids
		for grid in grids:
			_grid_item_map[grid] = item_data
		return true
	return false

## 找到第一个可以放下这个物品的格子
## 如果有，返回所有格子的数组
## 如果没有，返回空数组
func _find_first_availble_grids(item: ItemData) -> Array[Vector2i]:
	var item_shape = item.get_shape()
	for row in rows:
		for col in columns:
			# 如果当前格子中没有东西，则判断能否放下这个物品的形状
			if _grid_item_map[Vector2i(col, row)] == null:
				var grids = _try_get_empty_grids_by_shape(Vector2i(col, row), item_shape)
				if not grids.is_empty():
					return grids
	return []

## 从start（左上角）开始的位置
## 如果可以放下这个shape，返回所有格子的数组
## 否则返回空数组
func _try_get_empty_grids_by_shape(start: Vector2i, shape: Vector2i) -> Array[Vector2i]:
	var ret: Array[Vector2i] = []
	for row in shape.y:
		for col in shape.x:
			var grid_id = Vector2i(start.x + col, start.y + row)
			if _grid_item_map.has(grid_id) and _grid_item_map[grid_id] == null:
				ret.append(grid_id)
			else:
				return []
	return ret
