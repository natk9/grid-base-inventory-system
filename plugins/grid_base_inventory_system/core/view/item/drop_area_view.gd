extends Control
## 丢弃物品视图，加到场景中即可，会自动全屏并移到最底层
class_name DropAreaView

## 初始化
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	call_deferred("resize")

## 防呆，自动移到最底层，放置挡住背包导致无法放置
func resize() -> void:
	size = get_parent().size
	if not Engine.is_editor_hint():
		await get_tree().process_frame
		get_parent().move_child(self, 0)

## 输入控制
func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("inv_click"):
		if GBIS.moving_item_service.moving_item:
			GBIS.moving_item_service.moving_item.drop()
			GBIS.moving_item_service.clear_moving_item()
