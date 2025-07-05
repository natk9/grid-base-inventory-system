extends Control

func _ready() -> void:
	GBIS.add_quick_move_relation("inventory_1", "inventory_2")
	GBIS.add_quick_move_relation("inventory_2", "inventory_1")
	GBIS.current_inventories = ["inventory_1", "inventory_2"]
	GBIS.sig_item_focused.connect(_show_item_info.bind(true))
	GBIS.sig_item_focus_lost.connect(_show_item_info.bind(false))

func _show_item_info(item_data: ItemData, is_focusing: bool) -> void:
	if is_focusing:
		print("%s is focusing, showing info" % item_data.item_name)
	else:
		print("%s lost focus, clear info" % item_data.item_name)

func _on_button_pressed() -> void:
	var consumable_item_data = load("res://GBIS_demos/resources/consumable_1.tres")
	var equipment_item_data = load("res://GBIS_demos/resources/equipment_1.tres")
	GBIS.add_item("inventory_1", equipment_item_data)
	GBIS.add_item("inventory_1", consumable_item_data)
	GBIS.add_item("inventory_2", consumable_item_data)

func _on_button_2_pressed() -> void:
	GBIS.save()

func _on_button_3_pressed() -> void:
	GBIS.load()

func _on_button_4_pressed() -> void:
	get_tree().change_scene_to_file("res://GBIS_demos/test_scene_2.tscn")
