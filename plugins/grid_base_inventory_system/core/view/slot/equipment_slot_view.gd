@tool
extends Control
class_name EquipmentSlotView

enum State{
	NORMAL, AVILABLE, INAVILABLE
}

@export var slot_name: String = GBIS.DEFAULT_SLOT_NAME
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
@export var background: Texture2D:
	set(value):
		background = value
		queue_redraw()
@export var avilable_color: Color = Color.GREEN * 0.3:
	set(value):
		avilable_color = value
		queue_redraw()
@export var inavilable_color: Color = Color.DARK_RED * 0.3:
	set(value):
		inavilable_color = value
		queue_redraw()
@export var avilable_types: Array[String] = ["ANY"]

var _item_container: Node
var _item_view: ItemView
var _state: State = State.NORMAL

func is_empty() -> bool:
	return _item_view == null

func _ready() -> void:
	if Engine.is_editor_hint():
		call_deferred("_recalculate_size")
		return
	
	if not slot_name:
		push_error("Slot must have a name.")
		return
	
	var ret = GBIS.equipment_slot_service.regist_slot(slot_name, avilable_types)
	if not ret:
		return
	
	mouse_filter = Control.MOUSE_FILTER_STOP
	_init_item_container()
	GBIS.sig_slot_item_equipped.connect(_on_item_equipped)
	GBIS.sig_slot_item_unequipped.connect(_on_item_unequipped)
	GBIS.sig_slot_refresh.connect(_on_slot_refresh)
	mouse_entered.connect(_on_slot_hover)
	mouse_exited.connect(_on_slot_lose_hover)
	
	call_deferred("_on_slot_refresh")

func _on_slot_refresh() -> void:
	_clear_slot()
	var slot_data = GBIS.equipment_slot_service.get_slot(slot_name)
	if slot_data:
		var item_data = slot_data.equipped_item
		if item_data:
			_on_item_equipped(slot_name, item_data)

func _on_slot_hover() -> void:
	if not GBIS.moving_item_service.moving_item:
		return
	if GBIS.moving_item_service.moving_item is EquipmentData:
		GBIS.moving_item_service.moving_item_view.base_size = base_size
		var is_avilable = GBIS.equipment_slot_service.get_slot(slot_name).is_item_avilable(GBIS.moving_item_service.moving_item)
		_state = State.AVILABLE if is_avilable and is_empty() else State.INAVILABLE
	else:
		_state = State.INAVILABLE
	queue_redraw()

func _on_slot_lose_hover() -> void:
	_state = State.NORMAL
	queue_redraw()

@warning_ignore("shadowed_variable")
func _on_item_equipped(slot_name: String, item_data: ItemData):
	if slot_name != self.slot_name:
		return
	
	_item_view = _draw_item(item_data)
	_item_container.add_child(_item_view)
	_state = State.NORMAL
	queue_redraw()

func _draw_item(item_data: ItemData) -> ItemView:
	var item = ItemView.new(item_data, base_size)
	var center = global_position + size / 2 - item.size / 2
	item.global_position = center
	return item

@warning_ignore("shadowed_variable")
func _on_item_unequipped(slot_name: String, _item_data: ItemData):
	if slot_name != self.slot_name:
		return
	
	_clear_slot()

func _clear_slot() -> void:
	if _item_view:
		_item_view.queue_free()
		_item_view = null

## 初始化物品容器
func _init_item_container() -> void:
	_item_container = Node.new()
	add_child(_item_container)

func _draw() -> void:
	if background:
		draw_texture_rect(background, Rect2(0, 0, columns * base_size, rows * base_size), false)
		match _state:
			State.AVILABLE:
				draw_rect(Rect2(0, 0, columns * base_size, rows * base_size), avilable_color)
			State.INAVILABLE:
				draw_rect(Rect2(0, 0, columns * base_size, rows * base_size), inavilable_color)
	else:
		draw_rect(Rect2(0, 0, columns * base_size, rows * base_size), inavilable_color * 10)

func _recalculate_size() -> void:
	size = Vector2(columns * base_size, rows * base_size)
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("inv_click") && get_global_rect().has_point(get_global_mouse_position()):
		if GBIS.moving_item_service.moving_item and is_empty():
			GBIS.equipment_slot_service.equip_moving_item(slot_name)
		elif not GBIS.moving_item_service.moving_item and not is_empty():
			GBIS.equipment_slot_service.move_item(slot_name, base_size)
			_on_slot_hover()
	if event.is_action_pressed("inv_use") && get_global_rect().has_point(get_global_mouse_position()):
		if not is_empty():
			GBIS.equipment_slot_service.unequip(slot_name)
