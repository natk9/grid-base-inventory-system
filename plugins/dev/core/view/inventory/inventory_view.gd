@tool
extends Control
class_name InventoryView

@export_category("Inventory Settings")
@export var inventory_name: String = "Default"
@export var inventory_columns: int = 2:
	set(value):
		inventory_columns = value
		_recalculate_size()
@export var inventory_rows: int = 2:
	set(value):
		inventory_rows = value
		_recalculate_size()
@export_category("Grid Settings")
@export var grid_size: int = 32:
	set(value):
		grid_size = value
		_recalculate_size()
@export var grid_border_size: int = 1:
	set(value):
		grid_border_size = value
		queue_redraw()
@export var grid_border_color: Color = GridView.DEFAULT_BORDER_COLOR:
	set(value):
		grid_border_color = value
		queue_redraw()
@export var gird_background_color_empty: Color = GridView.DEFAULT_EMPTY_COLOR:
	set(value):
		gird_background_color_empty = value
		queue_redraw()
@export var gird_background_color_taken: Color = GridView.DEFAULT_TAKEN_COLOR:
	set(value):
		gird_background_color_taken = value
		queue_redraw()
@export var gird_background_color_conflict: Color = GridView.DEFAULT_CONFLICT_COLOR:
	set(value):
		gird_background_color_conflict = value
		queue_redraw()

var _grid_container: GridContainer
var _item_container: Node

var _items: Array[ItemView]
var _item_grids_map: Dictionary[ItemView, Array]
var _grid_map: Dictionary[Vector2i, GridView]
var _grid_item_map: Dictionary[Vector2i, ItemView]

func move_item(grid_id: Vector2i, offset: Vector2i) -> void:
	if InventoryController.has_moving_item():
		return
	var item = _grid_item_map[grid_id]
	var item_data = item.data
	if InventoryController.move_item_start(inventory_name, grid_id):
		var moving_item = ItemView.new(item_data)
		moving_item.update_display(grid_size, get_global_mouse_position())
		InventoryUtils.get_moving_item_layer().add_child(moving_item)
		moving_item.move()

func place_item(grid_id) -> void:
	if InventoryController.has_moving_item():
		if InventoryController.move_item_end(inventory_name, grid_id):
			InventoryUtils.clear_moving_layer()

func _ready() -> void:
	if Engine.is_editor_hint():
		call_deferred("_recalculate_size")
		return
	
	if not inventory_name:
		push_error("Inventory must have a name.")
		return
	
	var ret = InventoryController.regist_inventory(inventory_name, inventory_columns, inventory_rows)
	if not ret:
		return
	
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_init_grid_container()
	_init_item_container()
	_init_grids()
	InventoryController.sig_item_added.connect(_on_item_added)
	InventoryController.sig_item_removed.connect(_on_item_removed)

## 添加物品时调用，显示添加的物品
func _on_item_added(inv_name:String, item_data: ItemData, grids: Array[Vector2i]) -> void:
	if not inv_name == inventory_name:
		return
	
	var item = _draw_item(item_data, grids)
	_items.append(item)
	_item_grids_map[item] = grids
	for grid in grids:
		_grid_map[grid].taken(grid - grids[0])
		_grid_item_map[grid] = item

## 移除物品时调用，反向遍历，释放空间
func _on_item_removed(inv_name:String, item_data: ItemData) -> void:
	if not inv_name == inventory_name:
		return
	
	for i in range(_items.size() - 1, -1, -1):
		var item = _items[i]
		if item.data == item_data:
			var grids = _item_grids_map[item]
			for grid in grids:
				_grid_map[grid].release()
				_grid_item_map[grid] = null
			item.queue_free()
			_items.remove_at(i)

## 绘制物品
func _draw_item(item_data: ItemData, grids: Array[Vector2i]) -> ItemView:
	var item = ItemView.new(item_data)
	_item_container.add_child(item)
	var left_corner_grid_view = _grid_map[grids[0]]
	item.update_display(grid_size, left_corner_grid_view.global_position)
	item.global_position = left_corner_grid_view.global_position
	return item

## 初始化格子容器
func _init_grid_container() -> void:
	_grid_container = GridContainer.new()
	_grid_container.add_theme_constant_override("h_separation", 0)
	_grid_container.add_theme_constant_override("v_separation", 0)
	_grid_container.columns = inventory_columns
	_grid_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_grid_container)

## 初始化物品容器
func _init_item_container() -> void:
	_item_container = Node.new()
	add_child(_item_container)

## 初始化格子
func _init_grids() -> void:
	for row in inventory_rows:
		for col in inventory_columns:
			var grid_id = Vector2i(col, row)
			var grid = GridView.new(self, grid_id, grid_size, grid_border_size, grid_border_color, gird_background_color_empty, gird_background_color_taken, gird_background_color_conflict)
			_grid_container.add_child(grid)
			_grid_map[grid_id] = grid

## 编辑器中绘制自身
func _draw() -> void:
	if Engine.is_editor_hint():
		var inner_size = grid_size - grid_border_size * 2
		for row in inventory_rows:
			for col in inventory_columns:
				draw_rect(Rect2(col * grid_size, row * grid_size, grid_size, grid_size), grid_border_color, true)
				draw_rect(Rect2(col * grid_size + grid_border_size, row * grid_size + grid_border_size, inner_size, inner_size), gird_background_color_empty, true)

## 重新计算大小并绘制
func _recalculate_size() -> void:
		size = Vector2(inventory_columns * grid_size, inventory_rows * grid_size)
		queue_redraw()
