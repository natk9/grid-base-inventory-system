extends Control


func _on_button_pressed() -> void:
	InventoryController.add_item("Default", load("res://plugins/dev/resources/test_item_1.tres"))
