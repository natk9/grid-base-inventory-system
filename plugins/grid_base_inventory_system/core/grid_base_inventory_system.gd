extends Node
# 全局名称：GBIS

@warning_ignore("unused_signal")
signal sig_inv_item_added(inv_name: String, item_data: ItemData, grids: Array[Vector2i])
@warning_ignore("unused_signal")
signal sig_inv_item_removed(inv_name: String, item_data: ItemData)
@warning_ignore("unused_signal")
signal sig_inv_item_updated_grid_id(inv_name: String, grid_id: Vector2i)
@warning_ignore("unused_signal")
signal sig_inv_item_updated_item_data(inv_name: String, item_data: ItemData)
@warning_ignore("unused_signal")
signal sig_inv_refresh
@warning_ignore("unused_signal")
signal sig_slot_refresh
@warning_ignore("unused_signal")
signal sig_slot_item_equipped(slot_name: String, item_data: ItemData)
@warning_ignore("unused_signal")
signal sig_slot_item_unequipped(slot_name: String, item_data: ItemData)

const DEFAULT_PLAYER: String = "player_1"
const DEFAULT_INVENTORY_NAME: String = "Inventory"
const DEFAULT_SLOT_NAME: String = "Equipment Slot"
const DEFAULT_SAVE_FOLDER: String = "res://plugins/grid_base_inventory_system/saves/"

var inventory_service: InventoryService = InventoryService.new()
var equipment_slot_service: EquipmentSlotService = EquipmentSlotService.new()
var moving_item_service: MovingItemService = MovingItemService.new()

var current_player: String = DEFAULT_PLAYER
var current_inventories: Array[String] = [DEFAULT_INVENTORY_NAME]
var current_save_path: String = DEFAULT_SAVE_FOLDER
var current_save_name: String = "default.tres"

func save() -> void:
	inventory_service.save()
	equipment_slot_service.save()

func load() -> void:
	await get_tree().process_frame
	inventory_service.load()
	equipment_slot_service.load()
	sig_inv_refresh.emit()
	sig_slot_refresh.emit()

func get_root() -> Node:
	return get_tree().root

func add_item(inv_name: String, item_data: ItemData) -> bool:
	return inventory_service.add_item(inv_name, item_data)
