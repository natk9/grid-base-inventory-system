extends Resource
class_name ItemData

@export_group("Common Settings")
@export var item_name: String = "Item Name"
@export var type: String = "ANY"
@export_group("Display Settings")
@export var icon: Texture2D
@export var columns: int = 1
@export var rows: int = 1

func get_shape() -> Vector2i:
	return Vector2i(columns, rows)
