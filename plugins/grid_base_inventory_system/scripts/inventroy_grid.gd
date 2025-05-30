extends Control
class_name InventoryGrid

## 当格子被选中的时候触发
signal sig_selected(InventoryGrid)
## 鼠标悬停在格子上时触发
signal sig_hovered(InventoryGrid)
## 鼠标离开格子时触发
signal sig_hover_lost(InventoryGrid)

enum GridState {EMPTY, TAKEN, HORVERING, CONFLICT}

@export var empty_color = Color.DARK_SLATE_GRAY
@export var taken_color = Color.WEB_GRAY
@export var hovering_color = Color.LIGHT_SLATE_GRAY
@export var conflict_color = Color.ORANGE_RED

@onready var _background: ColorRect = $Border/Background

static var GRID_SCENE: PackedScene = preload("res://plugins/grid_base_inventory_system/scenes/inventroy_grid.tscn")

## 当前格子在数组中的Index
var _id: int
## 当前格子状态
var _state: GridState
## 当前格子存储的物品
var _stored_item: Item
## 当前格子相对于物体的本地列ID
var _local_column: int
## 当前格子相对于物体的本地行ID
var _local_row: int
## 存储这个物品的所有格子，包含自己
var _all_grids: Array[InventoryGrid]
## 自己归属的Inventory
var _inventory: Inventory

# ===== Getter =======
func is_empty() -> bool: return _stored_item == null
func get_id() -> int: return _id
func get_stored_item() -> Item: return _stored_item
func get_local_offset() -> Vector2i: return Vector2i(_local_column, _local_row)
func get_all_grids() -> Array[InventoryGrid]: return _all_grids
# ====================

## 新建格子
static func new_grid(id, inventory: Inventory) -> InventoryGrid:
	var grid = GRID_SCENE.instantiate()
	grid._id = id
	grid._state = GridState.EMPTY
	grid._inventory = inventory
	return grid

## 使用当前格子，传入占用的物品和当前格子相对于这个物品的偏移
func taken(item, offset: Vector2i, all_grids: Array[InventoryGrid]) -> void:
	_stored_item = item
	_local_column = offset.x
	_local_row = offset.y
	_all_grids = all_grids
	_change_state(GridState.TAKEN)

## 检查物品是否存储与当前格子，如果是则清空
func clear_grid() -> void:
	_stored_item = null
	_all_grids = []
	_change_state(GridState.EMPTY)

func hover(is_conflict: bool) -> void:
	if is_conflict:
		_change_state(GridState.CONFLICT)
	else:
		_change_state(GridState.HORVERING)

func lose_hover() -> void:
	if is_empty():
		_change_state(GridState.EMPTY)
	else:
		_change_state(GridState.TAKEN)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_change_state(GridState.EMPTY)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

## 根据格子状态更新格子颜色
func _change_state(state: GridState) -> void:
	match state:
		GridState.TAKEN:
			_state = GridState.TAKEN
			_background.color = taken_color
		GridState.EMPTY:
			_state = GridState.EMPTY
			_background.color = empty_color
		GridState.HORVERING:
			_state = GridState.HORVERING
			_background.color = hovering_color
		GridState.CONFLICT:
			_state = GridState.CONFLICT
			_background.color = conflict_color

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_click") && get_global_rect().has_point(get_global_mouse_position()):
		_inventory.on_grid_selected(self)
	if event.is_action_pressed("ui_quick_move") && get_global_rect().has_point(get_global_mouse_position()):
		if _stored_item:
			_inventory.try_quick_move(_stored_item)
	if event.is_action_pressed("ui_equip_unequip") && get_global_rect().has_point(get_global_mouse_position()):
		if _stored_item:
			_inventory.try_equip_unequip(_stored_item)

func _on_mouse_entered() -> void:
	_inventory.on_grid_hover(self, true)

func _on_mouse_exited() -> void:
	_inventory.on_grid_hover(self, false)
