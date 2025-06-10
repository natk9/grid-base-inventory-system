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

var _size: int
var _border_size: int
var _border_color: Color
var _empty_color: Color
var _taken_color: Color
var _conflict_color: Color

func _init(size: int = 32, border_size: int = 1, 
	border_color: Color = DEFAULT_BORDER_COLOR, empty_color: Color = DEFAULT_EMPTY_COLOR, 
	taken_color: Color = DEFAULT_TAKEN_COLOR, conflict_color: Color = DEFAULT_CONFLICT_COLOR):
		_size = size
		_border_size = border_size
		_border_color = border_color
		_empty_color = empty_color
		_taken_color = taken_color
		_conflict_color = conflict_color
		custom_minimum_size = Vector2(_size, _size)

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
