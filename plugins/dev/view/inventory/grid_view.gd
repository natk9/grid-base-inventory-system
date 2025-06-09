extends Control
class_name GridView

enum State{
	EMPTY, TAKEN, CONFLICT
}

var state = State.EMPTY

var _size: int
var _border_size: int
var _border_color: Color
var _empty_color: Color
var _taken_color: Color
var _conflict_color: Color

func _init(size: int = 32, border_size: int = 1, border_color: Color = Color.GRAY, empty_color: Color = Color.DARK_SLATE_GRAY, taken_color: Color = Color.SKY_BLUE, conflict_color: Color = Color.INDIAN_RED):
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
	draw_rect(Rect2(_border_size, _border_size, inner_size, inner_size), _empty_color, true)
