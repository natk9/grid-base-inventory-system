extends Node
class_name SlotRepository

var _slot_data_map: Dictionary[String, SlotData]

static var instance: SlotRepository:
	get:
		if not instance:
			instance = SlotRepository.new()
		return instance

func get_slot(slot_name: String) -> SlotData:
	return _slot_data_map.get(slot_name)

func add_slot(slot_name: String, avilable_types: Array[GBIS.ItemType]) -> bool:
	var slot = get_slot(slot_name)
	if not slot:
		_slot_data_map[slot_name] = SlotData.new(slot_name, avilable_types)
		return true
	return false

func try_equip(item_data: ItemData) -> SlotData:
	for slot in _slot_data_map.values():
		if slot.equip(item_data):
			return slot
	return null

func equip_to(slot_name, item_data: ItemData) -> bool:
	var slot = get_slot(slot_name)
	if slot:
		return slot.equip(item_data)
	return false

func unequip(slot_name) -> ItemData:
	var slot = get_slot(slot_name)
	if slot:
		return slot.unequip()
	return null
