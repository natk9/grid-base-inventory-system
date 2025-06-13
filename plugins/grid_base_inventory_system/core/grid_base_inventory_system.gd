extends Node
# 全局名称：GBIS

const DEFAULT_PLAYER: String = "player_1"
const DEFAULT_INVENTORY_NAME: String = "default"

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

var moving_item: ItemData
var moving_item_view: ItemView
var moving_item_offset: Vector2i = Vector2i.ZERO

var current_player: String = DEFAULT_PLAYER
var current_inventories: Array[String] = [DEFAULT_INVENTORY_NAME]

# =========================

func get_moving_item_layer() -> CanvasLayer:
	return inventory_utils.get_moving_item_layer(get_tree().root)

func clear_moving_item() -> void:
	inventory_utils.clear_moving_item()
	moving_item = null
	moving_item_view = null
	moving_item_offset = Vector2i.ZERO

@warning_ignore("shadowed_variable")
func draw_moving_item(item_data: ItemData, moving_item_offset: Vector2i, base_size: int) -> void:
	self.moving_item = item_data
	self.moving_item_offset = moving_item_offset
	self.moving_item_view = ItemView.new(item_data, base_size)
	get_moving_item_layer().add_child(moving_item_view)
	moving_item_view.move(moving_item_offset)

# =========================

func inv_regist(inv_name: String, columns: int, rows: int, avilable_types: Array[ItemType]) -> bool:
	return inventory_controller.regist_inventory(inv_name, columns, rows, avilable_types)

func inv_add_item(inv_name: String, item_data: ItemData) -> void:
	inventory_controller.add_item(inv_name, item_data)

func inv_move_item(inv_name: String, grid_id: Vector2i, offset: Vector2i, base_size: int) -> void:
	if moving_item:
		push_error("Already had moving item.")
	var item_data = inventory_controller.find_item_data_by_grid(inv_name, grid_id)
	if item_data:
		draw_moving_item(item_data, offset, base_size)
		inventory_controller.remove_item_by_data(inv_name, item_data)

func inv_place_moving_item(inv_name: String, grid_id: Vector2i) -> bool:
	if inventory_controller.place_to(inv_name, moving_item, grid_id):
		clear_moving_item()
		return true
	return false

func inv_quick_move(inv_name: String, grid_id: Vector2i) -> void:
	inventory_controller.quick_move(inv_name, grid_id)

func inv_is_item_avilable(inv_name: String, item_data: ItemData) -> bool:
	return inventory_controller.is_item_avilable(inv_name, item_data)

func inv_add_quick_move_relation(inv_name: String, target_inv_name: String) -> void:
	inventory_controller.add_quick_move_relation(inv_name, target_inv_name)

func inv_remove_quick_move_relation(inv_name: String, target_inv_name: String) -> void:
	inventory_controller.remove_quick_move_relation(inv_name, target_inv_name)

# =========================

func slot_regist(slot_name: String, avilable_types: Array[ItemType]) -> bool:
	return slot_controller.regist_slot(slot_name, avilable_types)

func slot_try_equip(inv_name: String, grid_id: Vector2i) -> bool:
	var item_data = inventory_controller.find_item_data_by_grid(inv_name, grid_id)
	if item_data:
		if slot_controller.try_equip(item_data):
			inventory_controller.remove_item_by_data(inv_name, item_data)
	return false

func slot_equip_moving_item(slot_name: String) -> bool:
	if slot_controller.equip_to(slot_name, moving_item):
		clear_moving_item()
		return true
	return false

func slot_unequip(slot_name) -> bool:
	for current_inventory in current_inventories:
		if not inventory_controller.is_inventory_existed(current_inventory):
			push_error("Cannot find inventory name [%s]. Please ensure GBIS.current_main_inventories contains valid inventory name." % current_inventory)
			return false
		var item_data = slot_controller.get_equipped_item(slot_name)
		if inventory_controller.add_item(current_inventory, item_data):
			slot_controller.unequip(slot_name)
			return true
	return false

func slot_move_item(slot_name: String, base_size: int) -> void:
	if moving_item:
		push_error("Already had moving item.")
		return
	var item_data = slot_controller.get_equipped_item(slot_name)
	if item_data:
		draw_moving_item(item_data, Vector2i.ZERO, base_size)
		slot_controller.unequip(slot_name)
