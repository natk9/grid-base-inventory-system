extends Control

func _ready() -> void:
	GBIS.inv_add_quick_move_relation("inv_1", "inv_2")
	GBIS.inv_add_quick_move_relation("inv_2", "inv_1")

func _on_button_pressed() -> void:
	GBIS.inv_add_item("inv_1", load("res://plugins/grid_base_inventory_system/core/test/resources/test_item_1.tres"))
