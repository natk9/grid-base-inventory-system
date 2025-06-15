extends StackableData
class_name ConsumableData

@export var destroy_if_empty: bool = true

func use() -> bool:
	if current_amount > 0:
		push_warning("[Override this function] consumable item has been used")
		current_amount -= 1
		if current_amount <= 0:
			return destroy_if_empty
	return false
