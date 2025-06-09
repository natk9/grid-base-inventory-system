@tool
extends Control
class_name InventoryView

@export var inventory_name: String = "Default"
@export var inventory_columns: int = 2:
	set(value):
		inventory_columns = value
		_recalculate_size()
@export var inventory_rows: int = 2:
	set(value):
		inventory_rows = value
		_recalculate_size()
@export var grid_size: int = 32:
	set(value):
		grid_size = value
		_recalculate_size()
@export var grid_border_size: int = 1:
	set(value):
		grid_border_size = value
		queue_redraw()
@export var grid_border_color: Color = Color.GRAY:
	set(value):
		grid_border_color = value
		queue_redraw()
@export var gird_background_color_empty: Color = Color.DARK_SLATE_GRAY:
	set(value):
		gird_background_color_empty = value
		queue_redraw()
@export var gird_background_color_taken: Color = Color.SKY_BLUE:
	set(value):
		gird_background_color_taken = value
		queue_redraw()
@export var gird_background_color_conflict: Color = Color.INDIAN_RED:
	set(value):
		gird_background_color_conflict = value
		queue_redraw()

var _grid_container: GridContainer

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if not inventory_name:
		push_error("必须填写Inventory Name")
		return
	
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _regist_to_controller():
		_init_grid_container()
		_init_grids()

func _init_grid_container() -> void:
	_grid_container = GridContainer.new()
	_grid_container.add_theme_constant_override("h_separation", 0)
	_grid_container.add_theme_constant_override("v_separation", 0)
	_grid_container.columns = inventory_columns
	_grid_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_grid_container)

func _init_grids() -> void:
	for col in inventory_columns:
		for row in inventory_rows:
			var grid = GridView.new(grid_size, grid_border_size, grid_border_color, gird_background_color_empty, gird_background_color_taken, gird_background_color_conflict)
			_grid_container.add_child(grid)

func _regist_to_controller() -> bool:
	return true

func _draw() -> void:
	if Engine.is_editor_hint():
		var inner_size = grid_size - grid_border_size * 2
		for col in inventory_columns:
			for row in inventory_rows:
				draw_rect(Rect2(col * grid_size, row * grid_size, grid_size, grid_size), grid_border_color, true)
				draw_rect(Rect2(col * grid_size + grid_border_size, row * grid_size + grid_border_size, inner_size, inner_size), gird_background_color_empty, true)

func _recalculate_size() -> void:
		size = Vector2(inventory_columns * grid_size, inventory_rows * grid_size)
		queue_redraw()
