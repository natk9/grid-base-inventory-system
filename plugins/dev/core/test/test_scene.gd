extends Control

func _ready() -> void:
	InventoryController.add_quick_move_relation("inv_1", "inv_2")
	InventoryController.add_quick_move_relation("inv_2", "inv_1")

func _on_button_pressed() -> void:
	InventoryController.add_item("inv_1", load("res://plugins/dev/resources/test_item_1.tres"))
