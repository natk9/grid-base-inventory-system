extends Control
class_name ItemView

var data: ItemData

var _is_moving: bool = false
var _moving_offset: Vector2i = Vector2i.ZERO
var _base_size: int

func _init(data: ItemData) -> void:
	self.data = data
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	if data.icon:
		draw_texture_rect(data.icon, Rect2(Vector2.ZERO, size), false)

func update_display(grid_size: int, global_position: Vector2 = Vector2.ZERO) -> void:
	size = Vector2(data.columns * grid_size, data.rows * grid_size)
	self.global_position = global_position

func move(grid_size: int, offset: Vector2i) -> void:
	_is_moving = true
	_base_size = grid_size
	_moving_offset = offset

func _process(delta: float) -> void:
	if _is_moving:
		update_display(_base_size, get_global_mouse_position() - Vector2(_base_size * _moving_offset) - Vector2(_base_size / 2, _base_size / 2))
