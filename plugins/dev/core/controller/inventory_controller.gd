extends Node

signal sig_item_added(inv_name: String, item_data: ItemData, grids: Array[Vector2i])
signal sig_item_removed(inv_name: String, item_data: ItemData)

var _inventroy_repository: InventoryRepository = InventoryRepository.new()
var _moving_item: ItemData
var _moving_item_offset: Vector2i = Vector2i.ZERO

## 注册背包
## 如果已经有了，则检查要注册的大小是否和已有的数据一致
## 如果还没有，则新增背包数据
func regist_inventory(inv_name: String, columns: int, rows: int, avilable_types: Array[ItemData.Type]) -> bool:
	var inv_data = _inventroy_repository.get_inventory(inv_name)
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
		return _inventroy_repository.add_inventory(inv_name, columns, rows, avilable_types)

## 向指定背包添加物品
## 注意：此处传入的 item_data 将被复制，以确保多个相同物品的 data 互相独立
func add_item(inv_name: String, item_data: ItemData) -> void:
	var new_data = item_data.duplicate()
	var grids = _inventroy_repository.add_item(inv_name, new_data)
	if not grids.is_empty():
		sig_item_added.emit(inv_name, new_data, grids)

func move_item_start(inv_name: String, grid_id: Vector2i, offset: Vector2i) -> bool:
	var item_data = _inventroy_repository.find_item_data_by_grid(inv_name, grid_id - offset)
	if item_data:
		_moving_item = item_data
		_moving_item_offset = offset
		# 从原背包中删除物品
		_remove_item(inv_name, item_data)
		return true
	return false

func move_item_end(inv_name: String, grid_id: Vector2i) -> bool:
	if has_moving_item():
		var inv = _inventroy_repository.get_inventory(inv_name)
		if inv:
			var grids = inv.try_add_to_grid(get_moving_item(), grid_id - _moving_item_offset)
			if grids:
				sig_item_added.emit(inv_name, _moving_item, grids)
				_moving_item = null
				_moving_item_offset = Vector2i.ZERO
				return true
	return false

func quick_move(inv_name: String, grid_id: Vector2i) -> void:
	var target_inventories = _inventroy_repository.get_quick_move_relations(inv_name)
	var item_to_move = _inventroy_repository.find_item_data_by_grid(inv_name, grid_id)
	if target_inventories.is_empty() or not item_to_move:
		return
	for target_inv in target_inventories:
		var grids = _inventroy_repository.add_item(target_inv, item_to_move)
		if not grids.is_empty():
			_inventroy_repository.remove_item(inv_name, item_to_move)
			sig_item_added.emit(target_inv, item_to_move, grids)
			sig_item_removed.emit(inv_name, item_to_move)
			return
	
func is_item_avilable(inv_name: String, item_data: ItemData) -> bool:
	var inv = _inventroy_repository.get_inventory(inv_name)
	if inv:
		return inv.is_item_avilable(item_data)
	return false

func has_moving_item() -> bool:
	return _moving_item != null

func get_moving_item() -> ItemData:
	return _moving_item

func get_moving_item_offset() -> Vector2i:
	return _moving_item_offset

func add_quick_move_relation(inv_name: String, target_inv_name: String) -> void:
	_inventroy_repository.add_quick_move_relation(inv_name, target_inv_name)

func remove_quick_move_relation(inv_name: String, target_inv_name: String) -> void:
	_inventroy_repository.remove_quick_move_relation(inv_name, target_inv_name)

## 移除指定背包中的指定物品
func _remove_item(inv_name: String, item_data: ItemData) -> void:
	if _inventroy_repository.remove_item(inv_name, item_data):
		sig_item_removed.emit(inv_name, item_data)
