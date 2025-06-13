extends Control
class_name ItemView

var data: ItemData
var base_size: int:
	set(value):
		base_size = value
		call_deferred("recalculate_size")
var _is_moving: bool = false
var _moving_offset: Vector2i = Vector2i.ZERO

func _init(data: ItemData, base_size: int) -> void:
	self.data = data
	self.base_size = base_size
	recalculate_size()
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func recalculate_size() -> void:
	size = Vector2(data.columns * base_size, data.rows * base_size)
	queue_redraw()

func move(offset: Vector2i = Vector2i.ZERO) -> void:
	_is_moving = true
	_moving_offset = offset

func _draw() -> void:
	if data.icon:
		draw_texture_rect(data.icon, Rect2(Vector2.ZERO, size), false)

func _process(delta: float) -> void:
	if _is_moving:
		global_position = get_global_mouse_position() - Vector2(base_size * _moving_offset) - Vector2(base_size / 2, base_size / 2)
