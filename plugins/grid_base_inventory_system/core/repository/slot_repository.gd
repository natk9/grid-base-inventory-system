extends Node
class_name SlotRepository

@export_storage var _slot_data_map: Dictionary[String, EquipmentSlotData]

static var instance: SlotRepository:
	get:
		if not instance:
			instance = SlotRepository.new()
		return instance

func get_slot(slot_name: String) -> EquipmentSlotData:
	return _slot_data_map.get(slot_name)

func add_slot(slot_name: String, avilable_types: Array[String]) -> bool:
	var slot = get_slot(slot_name)
	if not slot:
		_slot_data_map[slot_name] = EquipmentSlotData.new(slot_name, avilable_types)
		return true
	return false

func try_equip(item_data: ItemData) -> EquipmentSlotData:
	for slot in _slot_data_map.values():
		if slot.equip(item_data):
			return slot
	return null
