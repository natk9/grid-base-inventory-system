extends Control
class_name GridView

enum State{
	EMPTY, TAKEN, CONFLICT
}

const DEFAULT_BORDER_COLOR: Color = Color.GRAY
const DEFAULT_EMPTY_COLOR: Color = Color.DARK_SLATE_GRAY
const DEFAULT_TAKEN_COLOR: Color = Color.LIGHT_SLATE_GRAY
const DEFAULT_CONFLICT_COLOR: Color = Color.INDIAN_RED

var state: State = State.EMPTY:
	set(value):
		state = value
		queue_redraw()

var coordinates: Vector2i = Vector2i.ZERO
var offset: Vector2i = Vector2i.ZERO
var has_taken: bool = false

var _size: int
var _border_size: int
var _border_color: Color
var _empty_color: Color
var _taken_color: Color
var _conflict_color: Color

var _inventory_view: InventoryView

func taken(offset: Vector2i) -> void:
	has_taken = true
	self.offset = offset
	state = State.TAKEN

func release() -> void:
	has_taken = false
	self.offset = Vector2i.ZERO
	state = State.EMPTY

func _init(inventoryView: InventoryView, coordinates: Vector2i,
	size: int = 32, border_size: int = 1, 
	border_color: Color = DEFAULT_BORDER_COLOR, empty_color: Color = DEFAULT_EMPTY_COLOR, 
	taken_color: Color = DEFAULT_TAKEN_COLOR, conflict_color: Color = DEFAULT_CONFLICT_COLOR):
		_inventory_view = inventoryView
		self.coordinates = coordinates
		_size = size
		_border_size = border_size
		_border_color = border_color
		_empty_color = empty_color
		_taken_color = taken_color
		_conflict_color = conflict_color
		custom_minimum_size = Vector2(_size, _size)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_click") && get_global_rect().has_point(get_global_mouse_position()):
		if has_taken:
			_inventory_view.move_item(coordinates, offset)
	if event.is_action_pressed("ui_quick_move") && get_global_rect().has_point(get_global_mouse_position()):
		pass
	if event.is_action_pressed("ui_use") && get_global_rect().has_point(get_global_mouse_position()):
		pass

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
	draw_rect(Rect2(_border_size, _border_size, inner_size, inner_size), background_color, true)
