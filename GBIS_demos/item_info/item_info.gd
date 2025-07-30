extends ColorRect

@onready var item_name_label: Label = %ItemNameLabel

func _ready() -> void:
	hide()
	GBIS.sig_item_focused.connect(func(item_data: ItemData): 
		show()
		item_name_label.text = item_data.item_name)
	GBIS.sig_item_focus_lost.connect(func(_item_data: ItemData): hide())

func _process(_delta: float) -> void:
	position = get_global_mouse_position() + Vector2(5, 5)
