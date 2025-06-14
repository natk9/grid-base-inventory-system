extends Control

func _ready() -> void:
	GBIS.inv_add_quick_move_relation("inv_1", "inv_2")
	GBIS.inv_add_quick_move_relation("inv_2", "inv_1")
	GBIS.current_inventories = ["inv_1", "inv_2"]
	GBIS.load()

func _on_button_pressed() -> void:
	GBIS.inv_add_item("inv_1", load("res://plugins/grid_base_inventory_system/core/test/resources/test_item_1.tres"))
	GBIS.inv_add_item("inv_2", load("res://plugins/grid_base_inventory_system/core/test/resources/test_item_2.tres"))
	GBIS.inv_add_item("inv_1", load("res://plugins/grid_base_inventory_system/core/test/resources/test_item_2.tres"))

func _on_button_2_pressed() -> void:
	GBIS.save()

func _on_button_3_pressed() -> void:
	GBIS.load()
