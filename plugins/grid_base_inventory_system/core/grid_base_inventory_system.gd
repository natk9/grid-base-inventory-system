extends Node
# 全局名称：GBIS

enum ItemType{
	ALL,             # 全部
	HELMET,          # 头盔
	ARMOR,           # 盔甲
	GLOVES,          # 手套
	PANTS,           # 裤子
	BOOTS,           # 靴子
	RING,            # 戒指
	AMULET,          # 项链
	SWORD,           # 剑
	AXE,             # 斧
	MACE,            # 锤
	DAGGER,          # 匕首
	STAFF,           # 法杖
	WAND,            # 魔杖
	BOW,             # 弓
	CROSSBOW,        # 弩
	SHIELD,          # 盾牌
	WINGS,           # 翅膀
	MOUNT,           # 坐骑
	CONSUMABLE,      # 消耗品
	QUEST_ITEM,      # 任务物品
	MATERIAL         # 材料
}

var inventory_controller: InventoryController = InventoryController.new()
var slot_controller: SlotController = SlotController.new()
var inventory_utils: InventoryUtils = InventoryUtils.new()

func regist_inventory(inv_name: String, columns: int, rows: int, avilable_types: Array[ItemType]) -> bool:
	return inventory_controller.regist_inventory(inv_name, columns, rows, avilable_types)

func add_item(inv_name: String, item_data: ItemData) -> void:
	inventory_controller.add_item(inv_name, item_data)

func move_item_start(inv_name: String, grid_id: Vector2i, offset: Vector2i) -> bool:
	return inventory_controller.move_item_start(inv_name, grid_id, offset)

func move_item_end(inv_name: String, grid_id: Vector2i) -> bool:
	return inventory_controller.move_item_end(inv_name, grid_id)

func quick_move(inv_name: String, grid_id: Vector2i) -> void:
	inventory_controller.quick_move(inv_name, grid_id)

func is_item_avilable(inv_name: String, item_data: ItemData) -> bool:
	return inventory_controller.is_item_avilable(inv_name, item_data)

func has_moving_item() -> bool:
	return inventory_controller.has_moving_item()

func get_moving_item() -> ItemData:
	return inventory_controller.get_moving_item()

func get_moving_item_offset() -> Vector2i:
	return inventory_controller.get_moving_item_offset()

func get_moving_item_layer() -> CanvasLayer:
	return inventory_utils.get_moving_item_layer(get_tree().root)

func clear_moving_item() -> void:
	inventory_utils.clear_moving_item()

func add_quick_move_relation(inv_name: String, target_inv_name: String) -> void:
	inventory_controller.add_quick_move_relation(inv_name, target_inv_name)

func remove_quick_move_relation(inv_name: String, target_inv_name: String) -> void:
	inventory_controller.remove_quick_move_relation(inv_name, target_inv_name)

# =========================

func regist_slot(slot_name: String, avilable_types: Array[GBIS.ItemType]) -> bool:
	return slot_controller.regist_slot(slot_name, avilable_types)

func try_equip(item_data: ItemData) -> bool:
	return slot_controller.try_equip(item_data)

func equip_to(slot_name, item_data: ItemData) -> bool:
	return slot_controller.equip_to(slot_name, item_data)

func unequip(slot_name) -> bool:
	return slot_controller.unequip(slot_name)
