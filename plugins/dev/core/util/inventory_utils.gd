extends Node

## 正在移动物品的显示层（顶层）
var _moving_item_layer: CanvasLayer

func get_moving_item_layer() -> CanvasLayer:
	if not _moving_item_layer: 
		_moving_item_layer = CanvasLayer.new()
		_moving_item_layer.layer = 128
		get_tree().root.add_child(_moving_item_layer)
	return _moving_item_layer

func clear_moving_layer() -> void:
	for o in _moving_item_layer.get_children():
		o.queue_free()
