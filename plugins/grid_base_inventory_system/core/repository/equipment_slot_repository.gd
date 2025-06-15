extends Resource
class_name EquipmentSlotRepository

const PREFIX: String = "equipment_slot_"

@export_storage var _slot_data_map: Dictionary[String, EquipmentSlotData]

static var instance: EquipmentSlotRepository:
	get:
		if not instance:
			instance = EquipmentSlotRepository.new()
		return instance

func save() -> void:
	ResourceSaver.save(self, GBIS.current_save_path + PREFIX + GBIS.current_save_name)

func load() -> void:
	for slot_name in _slot_data_map.keys():
		var item_data = _slot_data_map[slot_name].equipped_item
		if item_data:
			item_data.unequipped(slot_name)
	
	var saved_repository: EquipmentSlotRepository = load(GBIS.current_save_path + PREFIX + GBIS.current_save_name)
	if not saved_repository:
		return
	for slot_name in saved_repository._slot_data_map.keys():
		_slot_data_map[slot_name] = saved_repository._slot_data_map[slot_name].duplicate(true)
		var item_data = _slot_data_map[slot_name].equipped_item
		if item_data:
			item_data.equipped(slot_name)

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
