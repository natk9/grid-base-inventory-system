extends Control
class_name GridView

enum State{
	EMPTY, TAKEN, CONFLICT, AVILABLE
}

const DEFAULT_BORDER_COLOR: Color = Color.GRAY
const DEFAULT_EMPTY_COLOR: Color = Color.DARK_SLATE_GRAY
const DEFAULT_TAKEN_COLOR: Color = Color.LIGHT_SLATE_GRAY
const DEFAULT_CONFLICT_COLOR: Color = Color.INDIAN_RED
const DEFAULT_AVILABLE_COLOR: Color = Color.STEEL_BLUE

var state: State = State.EMPTY:
	set(value):
		state = value
		queue_redraw()

var grid_id: Vector2i = Vector2i.ZERO
var offset: Vector2i = Vector2i.ZERO
var has_taken: bool = false

var _size: int = 32
var _border_size: int = 1
var _border_color: Color = DEFAULT_BORDER_COLOR
var _empty_color: Color = DEFAULT_EMPTY_COLOR
var _taken_color: Color = DEFAULT_TAKEN_COLOR
var _conflict_color: Color = DEFAULT_CONFLICT_COLOR
var _avilable_color: Color = DEFAULT_AVILABLE_COLOR

var _inventory_view: InventoryView

@warning_ignore("shadowed_variable")
func taken(offset: Vector2i) -> void:
	has_taken = true
	self.offset = offset
	state = State.TAKEN

func release() -> void:
	has_taken = false
	self.offset = Vector2i.ZERO
	state = State.EMPTY

@warning_ignore("shadowed_variable")
@warning_ignore("shadowed_variable_base_class")
func _init(inventoryView: InventoryView, grid_id: Vector2i,size: int, border_size: int, 
	border_color: Color, empty_color: Color, taken_color: Color, conflict_color: Color, avilable_color: Color):
		_avilable_color = avilable_color
		_inventory_view = inventoryView
		self.grid_id = grid_id
		_size = size
		_border_size = border_size
		_border_color = border_color
		_empty_color = empty_color
		_taken_color = taken_color
		_conflict_color = conflict_color
		custom_minimum_size = Vector2(_size, _size)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	_inventory_view.grid_hover(grid_id)

func _on_mouse_exited() -> void:
	_inventory_view.grid_lose_hover(grid_id)

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("inv_click") && get_global_rect().has_point(get_global_mouse_position()):
		if has_taken:
			if not GBIS.moving_item_service.moving_item:
				GBIS.moving_item_service.move_item(_inventory_view.inventory_name, grid_id, offset, _size)
			else:
				GBIS.inventory_service.stack_item(_inventory_view.inventory_name, grid_id)
			_on_mouse_entered()
		else:
			GBIS.inventory_service.place_moving_item(_inventory_view.inventory_name, grid_id)
	if event.is_action_pressed("inv_quick_move") && get_global_rect().has_point(get_global_mouse_position()):
		if has_taken:
			GBIS.inventory_service.quick_move(_inventory_view.inventory_name, grid_id)
	if event.is_action_pressed("inv_use") && get_global_rect().has_point(get_global_mouse_position()):
		if has_taken:
			GBIS.inventory_service.use_item(_inventory_view.inventory_name, grid_id)
	if event.is_action_pressed("inv_split") && get_global_rect().has_point(get_global_mouse_position()):
		if has_taken and not GBIS.moving_item_service.moving_item:
			GBIS.inventory_service.split_item(_inventory_view.inventory_name, grid_id, offset, _size)

func _draw() -> void:
	draw_rect(Rect2(0, 0, _size, _size), _border_color, true)
	var inner_size = _size - _border_size * 2
	var background_color = null
	match state:
		State.EMPTY:
			background_color = _empty_color
		State.TAKEN:
			background_color = _taken_color
		State.CONFLICT:
			background_color = _conflict_color
		State.AVILABLE:
			background_color = _avilable_color
	draw_rect(Rect2(_border_size, _border_size, inner_size, inner_size), background_color, true)
