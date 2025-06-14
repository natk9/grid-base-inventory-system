extends Node
# 全局名称：GBIS

@warning_ignore("unused_signal")
signal sig_inv_item_added(inv_name: String, item_data: ItemData, grids: Array[Vector2i])
@warning_ignore("unused_signal")
signal sig_inv_item_removed(inv_name: String, item_data: ItemData)
@warning_ignore("unused_signal")
signal sig_inv_item_used(inv_name: String, grid_id: Vector2i, item_data: ItemData)
@warning_ignore("unused_signal")
signal sig_slot_item_equipped(slot_name: String, item_data: ItemData)
@warning_ignore("unused_signal")
signal sig_slot_item_unequipped(slot_name: String, item_data: ItemData)

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
	MATERIAL,        # 材料
	SKILL            # 技能
}

const DEFAULT_PLAYER: String = "player_1"
const DEFAULT_INVENTORY_NAME: String = "default"

var inventory_service: InventoryService = InventoryService.new()
var slot_service: SlotService = SlotService.new()
var inventory_utils: InventoryUtils = InventoryUtils.new()

var moving_item: ItemData
var moving_item_view: ItemView
var moving_item_offset: Vector2i = Vector2i.ZERO

var current_player: String = DEFAULT_PLAYER
var current_inventories: Array[String] = [DEFAULT_INVENTORY_NAME]

var useable_types: Array[ItemType] = [ItemType.CONSUMABLE, ItemType.SKILL]
var equippable_types: Array[ItemType] = [ItemType.HELMET, ItemType.ARMOR, ItemType.GLOVES, 
										ItemType.PANTS, ItemType.BOOTS, ItemType.RING, ItemType.AMULET, 
										ItemType.SWORD, ItemType.AXE, ItemType.MACE, ItemType.DAGGER, 
										ItemType.STAFF, ItemType.WAND, ItemType.BOW, ItemType.CROSSBOW, 
										ItemType.SHIELD, ItemType.WINGS, ItemType.MOUNT]

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
	return inventory_service.regist_inventory(inv_name, columns, rows, avilable_types)

func inv_find_item_data(inv_name: String, grid_id: Vector2i) -> ItemData:
	return inventory_service.find_item_data_by_grid(inv_name, grid_id)

func inv_add_item(inv_name: String, item_data: ItemData) -> void:
	inventory_service.add_item(inv_name, item_data)

func inv_stack_item(inv_name: String, grid_id: Vector2i) -> void:
	pass

func inv_move_item(inv_name: String, grid_id: Vector2i, offset: Vector2i, base_size: int) -> void:
	if moving_item:
		push_error("Already had moving item.")
		return
	var item_data = inventory_service.find_item_data_by_grid(inv_name, grid_id)
	if item_data:
		draw_moving_item(item_data, offset, base_size)
		inventory_service.remove_item_by_data(inv_name, item_data)

func inv_place_moving_item(inv_name: String, grid_id: Vector2i) -> bool:
	if inventory_service.place_to(inv_name, moving_item, grid_id):
		clear_moving_item()
		return true
	return false

func inv_quick_move(inv_name: String, grid_id: Vector2i) -> void:
	inventory_service.quick_move(inv_name, grid_id)

func inv_is_item_avilable(inv_name: String, item_data: ItemData) -> bool:
	return inventory_service.is_item_avilable(inv_name, item_data)

func inv_add_quick_move_relation(inv_name: String, target_inv_name: String) -> void:
	inventory_service.add_quick_move_relation(inv_name, target_inv_name)

func inv_remove_quick_move_relation(inv_name: String, target_inv_name: String) -> void:
	inventory_service.remove_quick_move_relation(inv_name, target_inv_name)

func inv_use(inv_name: String, grid_id: Vector2i) -> bool:
	var item_data = inventory_service.find_item_data_by_grid(inv_name, grid_id)
	if equippable_types.has(item_data.type):
		return _inv_try_equip(inv_name, item_data)
	elif useable_types.has(item_data.type):
		return _inv_try_use(inv_name, grid_id, item_data)
	return false

func _inv_try_equip(inv_name: String, item_data: ItemData) -> bool:
	if item_data:
		if slot_service.try_equip(item_data):
			inventory_service.remove_item_by_data(inv_name, item_data)
			return true
	return false

func _inv_try_use(inv_name: String, grid_id: Vector2i, item_data: ItemData) -> bool:
	if item_data:
		if item_data.use():
			inventory_service.remove_item_by_data(inv_name, item_data)
			return true
		else:
			inventory_service.sig_inv_item_used.emit(inv_name, grid_id, item_data)
			return true
	return false
# =========================

func slot_regist(slot_name: String, avilable_types: Array[ItemType]) -> bool:
	return slot_service.regist_slot(slot_name, avilable_types)

func slot_equip_moving_item(slot_name: String) -> bool:
	if slot_service.equip_to(slot_name, moving_item):
		clear_moving_item()
		return true
	return false

func slot_unequip(slot_name) -> bool:
	for current_inventory in current_inventories:
		if not inventory_service.is_inventory_existed(current_inventory):
			push_error("Cannot find inventory name [%s]. Please ensure GBIS.current_main_inventories contains valid inventory name." % current_inventory)
			return false
		var item_data = slot_service.get_equipped_item(slot_name)
		if inventory_service.add_item(current_inventory, item_data):
			slot_service.unequip(slot_name)
			return true
	return false

func slot_move_item(slot_name: String, base_size: int) -> void:
	if moving_item:
		push_error("Already had moving item.")
		return
	var item_data = slot_service.get_equipped_item(slot_name)
	if item_data:
		draw_moving_item(item_data, Vector2i.ZERO, base_size)
		slot_service.unequip(slot_name)
