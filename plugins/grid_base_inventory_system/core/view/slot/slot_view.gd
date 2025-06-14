@tool
extends Control
class_name SlotView

@export var slot_name: String = "defalut slot"
@export var background: Texture2D:
	set(value):
		background = value
		queue_redraw()
@export var base_size: int = 32:
	set(value):
		base_size = value
		_recalculate_size()
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

func is_empty() -> bool:
	return _item_view == null

func _ready() -> void:
	if Engine.is_editor_hint():
		call_deferred("_recalculate_size")
		return
	
	if not slot_name:
		push_error("Slot must have a name.")
		return
	
	var ret = GBIS.slot_regist(slot_name, avilable_types)
	if not ret:
		return
	
	mouse_filter = Control.MOUSE_FILTER_STOP
	_init_item_container()
	GBIS.sig_slot_item_equipped.connect(_on_item_equipped)
	GBIS.sig_slot_item_unequipped.connect(_on_item_unequipped)
	mouse_entered.connect(_on_slot_hover)
	mouse_exited.connect(_on_slot_lose_hover)

func _on_slot_hover() -> void:
	if not GBIS.moving_item:
		return
	if GBIS.equippable_types.has(GBIS.moving_item_view.data.type):
		GBIS.moving_item_view.base_size = base_size

func _on_slot_lose_hover() -> void:
	pass

@warning_ignore("shadowed_variable")
func _on_item_equipped(slot_name: String, item_data: ItemData):
	if slot_name != self.slot_name:
		return
	
	_item_view = _draw_item(item_data)
	_item_container.add_child(_item_view)

func _draw_item(item_data: ItemData) -> ItemView:
	var item = ItemView.new(item_data, base_size)
	var center = global_position + size / 2 - item.size / 2
	item.global_position = center
	return item

@warning_ignore("shadowed_variable")
@warning_ignore("unused_parameter")
func _on_item_unequipped(slot_name: String, item_data: ItemData):
	if slot_name != self.slot_name:
		return
	
	_item_view.queue_free()
	_item_view = null

## 初始化物品容器
func _init_item_container() -> void:
	_item_container = Node.new()
	add_child(_item_container)

func _draw() -> void:
	if background:
		draw_texture_rect(background, Rect2(0, 0, columns * base_size, rows * base_size), false)
	else:
		draw_rect(Rect2(0, 0, columns * base_size, rows * base_size), default_background_color)

func _recalculate_size() -> void:
	size = Vector2(columns * base_size, rows * base_size)
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inv_click") && get_global_rect().has_point(get_global_mouse_position()):
		if GBIS.moving_item and is_empty():
			GBIS.slot_equip_moving_item(slot_name)
		elif not GBIS.moving_item and not is_empty():
			GBIS.slot_move_item(slot_name, base_size)
	if event.is_action_pressed("inv_use") && get_global_rect().has_point(get_global_mouse_position()):
		if not is_empty():
			GBIS.slot_unequip(slot_name)
