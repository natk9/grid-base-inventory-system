extends Resource
class_name ItemData

@export var columns: int = 1
@export var rows: int = 1

func get_shape() -> Vector2i:
	return Vector2i(columns, rows)
