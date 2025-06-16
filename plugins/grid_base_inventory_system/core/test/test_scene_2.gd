extends Control


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://plugins/grid_base_inventory_system/core/test/test_scene.tscn")
