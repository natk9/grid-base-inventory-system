extends Node
class_name MovingItemService

var moving_item: ItemData
var moving_item_view: ItemView
var moving_item_offset: Vector2i = Vector2i.ZERO

var _moving_item_layer: CanvasLayer

func get_moving_item_layer() -> CanvasLayer:
	if not _moving_item_layer: 
		_moving_item_layer = CanvasLayer.new()
		_moving_item_layer.layer = 128
		GBIS.get_root().add_child(_moving_item_layer)
	return _moving_item_layer

func clear_moving_item() -> void:
	for o in _moving_item_layer.get_children():
		o.queue_free()
	moving_item = null

func draw_moving_item(item_data: ItemData, offset: Vector2i, base_size: int) -> void:
	self.moving_item = item_data
	self.moving_item_offset = offset
	self.moving_item_view = ItemView.new(item_data, base_size)
	get_moving_item_layer().add_child(moving_item_view)
	moving_item_view.move(offset)

func move_item(inv_name: String, grid_id: Vector2i, offset: Vector2i, base_size: int) -> void:
	if moving_item:
		push_error("Already had moving item.")
		return
	var item_data = GBIS.inventory_service.find_item_data_by_grid(inv_name, grid_id)
	if item_data:
		draw_moving_item(item_data, offset, base_size)
		GBIS.inventory_service.remove_item_by_data(inv_name, item_data)
