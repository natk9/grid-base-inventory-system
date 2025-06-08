@tool
extends ColorRect
class_name Inventory

## 格子大小
@export var grid_size: int = 32
## 格子边框大小（内边框）
@export var grid_border_size: int = 1
## 库存系统配置 - 列数
@export var inventory_columns: int
## 库存系统配置 - 行数
@export var inventory_rows: int
## 是否在编辑器中实时预览大小
@export var resize_in_editor: bool = true
## 可以存放的物品类型
@export var valid_item_types: Array[ItemResourceData.Type]

## 格子容器
@onready var grid_container: GridContainer = $GridContainer
## 放置Item的地方
@onready var item_container: Control = $ItemContainer

## 当前库存拥有的所有格子
var _grids: Array[InventoryGrid] = []
## 容器中的所有Items，映射到它存储的第一个格子
var _item_to_first_grid: Dictionary[Item, InventoryGrid] = {}
## 快速移动的目标列表，快速移动时从前到后尝试添加
var _quick_move_targets: Array[Inventory]

## 直接向背包添加物品，放置在第一个可以放置的位置
func add_item(item: Item) -> bool:
	if not _is_valid(item): 
		return false
	var available_grids = _find_first_available_grids(item)
	if available_grids.size() > 0:
		_place_item(item, available_grids)
		return true
	return false

## 移除物品
func remove_item(item: Item, hover: bool = false) -> void:
	var first_grid = _item_to_first_grid[item]
	_item_to_first_grid.erase(item)
	if item.get_parent() == item_container: 
		item_container.remove_child(item)
	var removal_grids = first_grid.get_all_grids()
	for removal_grid in removal_grids:
		removal_grid.clear_grid()
		if hover: 
			removal_grid.hover(false)

## 移动到其他库存中
func try_quick_move(item: Item) -> void:
	if not item:
		return
	for inv in _quick_move_targets:
		if inv.add_item(item):
			remove_item(item)
			break

func try_equip_unequip(item: Item) -> void:
	InventorySystem.equip(item, self)

func try_consume(item: Item) -> void:
	if item.get_item_type() == ItemResourceData.Type.CONSUMABLE:
		if item.get_item_data().test_need():
			item.get_item_data().consume()
	# 移除物品
	remove_item(item)

## 添加快速移动目标
func add_quick_move_target(target_inv: Inventory) -> void: _quick_move_targets.append(target_inv)
## 移除快速移动目标
func remove_quick_move_target(target_inv: Inventory) -> void: _quick_move_targets.erase(target_inv)

## 处理格子的hover和lose hover
func on_grid_hover(grid: InventoryGrid, is_hover: bool) -> void:
	if InventorySystem.has_moving_item():
		InventorySystem.get_moving_item().update_size(grid_size)
		var affected_grids = _get_affected_grids(grid, InventorySystem.get_moving_item(), InventorySystem.get_moving_offset(), true)
		var is_conflict = not _is_valid(InventorySystem.get_moving_item())
		if not is_conflict:
			for affected_grid in affected_grids:
				if not affected_grid.is_empty():
					is_conflict = true
		for affected_grid in affected_grids:
			affected_grid.hover(is_conflict) if is_hover else affected_grid.lose_hover()

## 处理格子点击事件
func on_grid_selected(grid: InventoryGrid) -> void:
	# 如果有正在移动的物品，则尝试放置物品
	if InventorySystem.has_moving_item():
		_handle_item_placement(grid)
	# 没有正在移动的物品，如果格子有存储的物品，则移动物品
	elif grid.get_stored_item():
		_handle_item_moving(grid)

func _ready() -> void:
	if not Engine.is_editor_hint():
		_setup_inventory_grid()

func _process(_delta: float) -> void:
	if resize_in_editor && Engine.is_editor_hint():
		var new_size = Vector2(inventory_columns * grid_size, inventory_rows * grid_size)
		if new_size != size:
			size = new_size

## 初始化库存系统格子
func _setup_inventory_grid() -> void:
	grid_container.columns = inventory_columns
	for row in range(inventory_rows):
		for column in range(inventory_columns):
			var grid_id = row * inventory_columns + column
			var grid = InventoryGrid.new_grid(grid_id, self)
			grid_container.add_child(grid)
			_grids.append(grid)

## 物品是否可以放在这个Inventory
func _is_valid(item: Item) -> bool:
	if valid_item_types.has(ItemResourceData.Type.ALL):
		return true
	elif valid_item_types.has(item.get_item_type()):
		return true
	return false

## 放置物品，更新格子状态
func _place_item(item: Item, grids: Array[InventoryGrid]) -> void:
	item.reparent(item_container) if item.get_parent() else item_container.add_child(item)
	# 把物品加入库存
	_item_to_first_grid[item] =  grids[0]
	for i in range(grids.size()):
		# 计算offset，即格子的相对于存放物品的本地坐标
		var offset = Vector2i(
			i % item.get_item_shape().x,
			i / item.get_item_shape().x
		)
		grids[i].taken(item, offset, grids)
	item.global_position = grids[0].global_position
	item.update_size(grid_size)

## 处理格子点击时的物品放置逻辑
func _handle_item_placement(grid: InventoryGrid) -> void:
	if not grid.is_empty():
		return
	
	var moving_item = InventorySystem.get_moving_item()
	if not _is_valid(moving_item):
		return
	
	var placement_grids = _get_affected_grids(grid, moving_item, InventorySystem.get_moving_offset())
	if placement_grids.size() > 0:
		_place_item(moving_item, placement_grids)
		InventorySystem.stop_move_item()

## 处理格子点击时的物品移动逻辑
func _handle_item_moving(grid: InventoryGrid) -> void:
	var item = grid.get_stored_item()
	InventorySystem.move_item(item, grid.get_local_offset())
	# 从这个库存中删除正在移动的物品
	remove_item(item, true)

## 查找第一个可用的格子
func _find_first_available_grids(item: Item) -> Array[InventoryGrid]:
	for grid in _grids:
		if grid.is_empty():
			var potential_grids = _get_affected_grids(grid, item)
			if potential_grids.size() > 0:
				return potential_grids
	return []

## 查找物品覆盖的格子
func _get_affected_grids(grid: InventoryGrid, item: Item, offset: Vector2i = Vector2i.ZERO, force: bool = false) -> Array[InventoryGrid]:
	var shape = item.get_item_shape()
	var start_id = grid.get_id() - offset.x - offset.y * inventory_columns
	
	if start_id < 0 or start_id >= _grids.size():
		return []
	
	var start_row = start_id / inventory_columns
	var start_col = start_id % inventory_columns
	
	if start_col + shape.x > inventory_columns or start_row + shape.y > inventory_rows:
		return []
	
	var affected_grids: Array[InventoryGrid] = []
	for y in range(shape.y):
		for x in range(shape.x):
			var index = (start_row + y) * inventory_columns + (start_col + x)
			if index >= _grids.size():
				return []
			if not force && not _grids[index].is_empty() and _grids[index].get_stored_item() != item:
				return []
			affected_grids.append(_grids[index])
	
	return affected_grids
