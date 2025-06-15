extends Control
class_name DropAreaView

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	call_deferred("resize")

func resize() -> void:
	size = get_parent().size
	if not Engine.is_editor_hint():
		await get_tree().process_frame
		get_parent().move_child(self, 0)

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("inv_click") && get_global_rect().has_point(get_global_mouse_position()):
		if GBIS.moving_item_service.moving_item:
			GBIS.moving_item_service.moving_item.drop()
			GBIS.moving_item_service.clear_moving_item()
