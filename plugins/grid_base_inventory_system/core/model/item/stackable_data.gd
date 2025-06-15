extends ItemData
class_name StackableData

@export var stack_size: int = 2
@export var current_amount: int = 1

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
