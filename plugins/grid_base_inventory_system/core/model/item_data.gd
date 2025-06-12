extends Resource
class_name ItemData

@export var icon: Texture2D
@export var columns: int = 1
@export var rows: int = 1
@export var type: GBIS.ItemType = GBIS.ItemType.ALL

func get_shape() -> Vector2i:
	return Vector2i(columns, rows)
