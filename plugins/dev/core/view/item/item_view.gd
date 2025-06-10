extends Control
class_name ItemView

var _data: ItemData

func _init(data: ItemData) -> void:
	_data = data

func _draw() -> void:
	if _data.icon:
		draw_texture_rect(_data.icon, Rect2(Vector2.ZERO, size), false)

func update_display(grid_size: int, global_position: Vector2) -> void:
	size = Vector2(_data.columns * grid_size, _data.rows * grid_size)
	self.global_position = global_position
