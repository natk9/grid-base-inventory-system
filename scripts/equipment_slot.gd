@tool
extends Inventory
class_name EquipmentSlot

@export var valid_color = Color.GREEN
@export var invalid_color = Color.RED
@export var background_image: Texture2D:
	set(value):
		background_image = value
		if _background_image:
			_background_image.texture = value

@onready var _filter: ColorRect = $Filter
@onready var _background_image: TextureRect = $BackgroundImage

## 移除物品
func remove_item(item: Item, hover: bool = false) -> void:
	_item_to_first_grid.erase(item)
	if item.get_parent() == _item_container: 
		_item_container.remove_child(item)
	for grid in _grids:
		grid.clear_grid()
		if hover: 
			grid.hover(false)

func try_equip_unequip(item: Item) -> void:
	InventorySystem.unequip(item, self)

## 处理格子的hover和lose hover
func on_grid_hover(_grid: InventoryGrid, is_hover: bool) -> void:
	if is_hover:
		if InventorySystem.has_moving_item():
			_filter.show()
			var is_conflict = not _is_valid(InventorySystem.get_moving_item()) or not _item_to_first_grid.is_empty()
			if not is_conflict:
				_filter.color = valid_color
			else:
				_filter.color = invalid_color
	else:
		_filter.hide()

func _ready() -> void:
	super._ready()
	_filter.hide()
	_background_image.texture = background_image

## 物品是否可以放在这个Slot
func _is_valid(item: Item) -> bool:
	if _item_to_first_grid.is_empty():
		return super._is_valid(item)
	return false

## 处理格子点击时的物品放置逻辑
func _handle_item_placement(_grid: InventoryGrid) -> void:
	var moving_item = InventorySystem.get_moving_item()
	if not _is_valid(moving_item):
		return
	if _item_to_first_grid.is_empty():
		_place_item(moving_item, _grids)
		InventorySystem.stop_move_item()

## 放置物品，更新格子状态
func _place_item(item: Item, grids: Array[InventoryGrid]) -> void:
	item.reparent(_item_container) if item.get_parent() else _item_container.add_child(item)
	# 把物品加入库存
	_item_to_first_grid[item] =  grids[0]
	for grid in _grids:
		grid.taken(item, Vector2i.ZERO, grids)
		item.global_position = Vector2(size.x / 2 + global_position.x - item.size.x / 2, size.y / 2 + global_position.y - item.size.y / 2)

## 处理格子点击时的物品移动逻辑
func _handle_item_moving(grid: InventoryGrid) -> void:
	var item = grid.get_stored_item()
	InventorySystem.move_item(item, grid.get_local_offset(), true)
	# 从这个库存中删除正在移动的物品
	remove_item(item, true)
