extends Control
class_name ItemView

var data: ItemData
var grid_size: int

var _is_moving: bool = false
var _moving_offset: Vector2i = Vector2i.ZERO

func _init(data: ItemData, grid_size: int, global_position: Vector2) -> void:
	self.data = data
	self.grid_size = grid_size
	self.global_position = global_position
	size = Vector2(data.columns * grid_size, data.rows * grid_size)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func move(offset: Vector2i) -> void:
	_is_moving = true
	_moving_offset = offset

func _draw() -> void:
	if data.icon:
		draw_texture_rect(data.icon, Rect2(Vector2.ZERO, size), false)

func _process(delta: float) -> void:
	if _is_moving:
		global_position = get_global_mouse_position() - Vector2(grid_size * _moving_offset) - Vector2(grid_size / 2, grid_size / 2)
