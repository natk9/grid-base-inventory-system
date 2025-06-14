extends Resource
class_name ItemData

@export_group("Common Settings")
@export var type: GBIS.ItemType = GBIS.ItemType.ALL
@export var stack_size: int = 1
@export var current_amount: int = 1
@export var destroy_if_empty: bool = true
@export var show_stack: bool = false
@export_group("Display Settings")
@export var icon: Texture2D
@export var columns: int = 1
@export var rows: int = 1

func get_shape() -> Vector2i:
	return Vector2i(columns, rows)

func test_need(slot_name: String) -> bool:
	push_warning("[Override this function] [%s]:[%s] Equipment slot test passed. 
		If you have multiple players, you should test whether this slot belongs to GBIS.current_player. 
		Don't forget to change GBIS.current_player to the player that is currently being modified." % [GBIS.current_player, slot_name])
	return true

func use() -> bool:
	if current_amount > 0:
		push_warning("[Override this function] item has been used")
		current_amount -= 1
		if current_amount <= 0:
			return destroy_if_empty
	return false

func is_full() -> bool:
	return current_amount >= stack_size

func add_amount(amount: int) -> int:
	if is_full():
		return amount
	var amount_left = stack_size - current_amount
	if amount_left < amount:
		current_amount = stack_size
		return amount - amount_left
	current_amount += amount
	return 0
