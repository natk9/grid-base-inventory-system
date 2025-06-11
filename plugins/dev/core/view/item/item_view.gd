extends Control
class_name ItemView

var data: ItemData
var _is_moving: bool = false

func _init(data: ItemData) -> void:
	self.data = data

func _draw() -> void:
	if data.icon:
		draw_texture_rect(data.icon, Rect2(Vector2.ZERO, size), false)

func update_display(grid_size: int, global_position: Vector2) -> void:
	size = Vector2(data.columns * grid_size, data.rows * grid_size)
	self.global_position = global_position

func move() -> void:
	_is_moving = true

func _process(delta: float) -> void:
	if _is_moving:
		global_position = get_global_mouse_position()
