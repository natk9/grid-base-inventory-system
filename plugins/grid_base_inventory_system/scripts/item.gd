extends Control
class_name Item

## 物品场景
static var ITEM_SCENE: PackedScene = preload("res://plugins/grid_base_inventory_system/scenes/item.tscn")

## 是否正在移动
var _is_moving := false
## 和鼠标的偏移量
var _position_offset := Vector2.ZERO
## 物品数据
var _item_data: ItemResourceData

## 物品的Icon
@onready var item_image: TextureRect = $ItemImage

# =====Getter=====
func get_item_type() -> ItemResourceData.Type: return _item_data.type
func get_item_shape() -> Vector2i: return Vector2i(_item_data.column, _item_data.row)
func get_item_data() -> ItemResourceData: return _item_data
# ================

## 工厂方法，新建一个物品
static func new_item(data: ItemResourceData, duplicate_data: bool = true) -> Item:
	var item = ITEM_SCENE.instantiate()
	item._item_data = data.duplicate() if duplicate_data else data
	return item

## 开始移动物品
func start_moving(force_item_position: bool = false) ->void:
	_is_moving = true
	if force_item_position:
		_position_offset = Vector2(size.x / _item_data.column / 2, size.y / _item_data.row / 2)
	else:
		_position_offset = get_global_mouse_position() - global_position

## 停止移动物品
func stop_moving() -> void:
	_is_moving = false

## 更新物品大小
func update_size(grid_size: int) -> void:
	var new_size = Vector2(grid_size * _item_data.column, grid_size * _item_data.row)
	var new_scale = new_size / size
	size = new_size
	_position_offset *= new_scale

## 设置物品的大小和图片
func _ready() -> void:
	item_image.texture = _item_data.image
	
## 处理物品跟随鼠标
func _process(_delta: float) -> void:
	if _is_moving:
		global_position = get_global_mouse_position() - _position_offset
