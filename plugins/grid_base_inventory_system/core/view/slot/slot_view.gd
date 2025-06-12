@tool
extends Control
class_name SlotView

@export var slot_name: String = "defalut slot"
@export var background: Texture2D:
	set(value):
		background = value
		queue_redraw()
@export var grid_size: int = 32
@export var columns: int = 2:
	set(value):
		columns = value
		_recalculate_size()
@export var rows: int = 2:
	set(value):
		rows = value
		_recalculate_size()
@export var default_background_color: Color = Color.DARK_RED:
	set(value):
		default_background_color = value
		queue_redraw()
@export var avilable_types: Array[GBIS.ItemType] = [GBIS.ItemType.ALL]

var _item_container: Node
var _item_view: ItemView

func _ready() -> void:
	if Engine.is_editor_hint():
		call_deferred("_recalculate_size")
		return
	
	if not slot_name:
		push_error("Slot must have a name.")
		return
	
	var ret = GBIS.regist_slot(slot_name, avilable_types)
	if not ret:
		return
	
	mouse_filter = Control.MOUSE_FILTER_STOP
	_init_item_container()
	GBIS.slot_controller.sig_item_equipped.connect(_on_item_equipped)
	GBIS.slot_controller.sig_item_unequipped.connect(_on_item_unequipped)

func _on_item_equipped(slot_name: String, item_data: ItemData):
	if slot_name != self.slot_name:
		return
	
	_draw_item(item_data)

func _draw_item(item_data: ItemData) -> void:
	var item = ItemView.new(item_data, grid_size, global_position)
	_item_container.add_child(item)
	_item_view = item

func _on_item_unequipped(slot_name: String, item_data: ItemData):
	_item_view.queue_free()
	_item_view = null

## 初始化物品容器
func _init_item_container() -> void:
	_item_container = Node.new()
	add_child(_item_container)

func _draw() -> void:
	if background:
		draw_texture_rect(background, Rect2(0, 0, columns * grid_size, rows * grid_size), false)
	else:
		draw_rect(Rect2(0, 0, columns * grid_size, rows * grid_size), default_background_color)

func _recalculate_size() -> void:
	size = Vector2(columns * grid_size, rows * grid_size)
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_click") && get_global_rect().has_point(get_global_mouse_position()):
		pass
	if event.is_action_pressed("ui_quick_move") && get_global_rect().has_point(get_global_mouse_position()):
		pass
	if event.is_action_pressed("ui_use") && get_global_rect().has_point(get_global_mouse_position()):
		pass
