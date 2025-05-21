extends Node

## 格子大小
const GRID_SIZE: int = 32

## 正在移动的物品
var _moving_item: Item
## 正在移动的物品的偏移量
var _moving_offset: Vector2i
## 正在移动物品的显示层（顶层）
var _moving_item_layer: CanvasLayer
## 装备槽列表
var _equipment_slots: Array[EquipmentSlot]
## 主库存，一般是角色随身背包，用于右键脱装备
var _main_inventories: Array[Inventory]

# =====Getter=====
func get_moving_item() -> Item: return _moving_item
func get_moving_offset() -> Vector2i: return _moving_offset
func get_moving_item_layer() -> CanvasLayer:
	if not _moving_item_layer: 
		_moving_item_layer = CanvasLayer.new()
		_moving_item_layer.layer = 128
		get_tree().root.add_child(_moving_item_layer)
	return _moving_item_layer
# ================

## 增加装备槽
func add_equipment_slot(slot: EquipmentSlot) -> void:
	_equipment_slots.append(slot)

## 增加主背包
func add_main_inventory(inventory: Inventory) -> void:
	_main_inventories.append(inventory)

## 尝试装备
func equip(item: Item, inventory: Inventory) -> void:
	for slot in _equipment_slots:
		if slot.add_item(item):
			inventory.remove_item(item)
			return

## 尝试脱掉装备
func unequip(item: Item, slot: EquipmentSlot) -> void:
	for inventory in _main_inventories:
		if inventory.add_item(item):
			slot.remove_item(item)
			return

## 是否有物品正在移动
func has_moving_item() -> bool: return _moving_item != null

## 移动物品
func move_item(item: Item, offset: Vector2i, force_item_position: bool = false) -> void:
	item.start_moving(force_item_position)
	_moving_item = item
	_moving_offset = offset
	item.reparent(get_moving_item_layer()) if item.get_parent() else get_moving_item_layer().add_child(item)

## 停止移动物品
func stop_move_item()-> void:
	_moving_item.stop_moving()
	_moving_item = null
