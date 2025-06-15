extends Node
class_name EquipmentSlotService

var _slot_repository: SlotRepository = SlotRepository.instance

func regist_slot(slot_name: String, avilable_types: Array[String]) -> bool:
	var slot_data = _slot_repository.get_slot(slot_name)
	if slot_data:
		var is_same_avilable_types = avilable_types.size() == slot_data.avilable_types.size()
		if is_same_avilable_types:
			for i in range(avilable_types.size()):
				is_same_avilable_types = avilable_types[i] == slot_data.avilable_types[i]
				if not is_same_avilable_types:
					break
		return is_same_avilable_types
	else:
		return _slot_repository.add_slot(slot_name, avilable_types)

func get_equipped_item(slot_name: String) -> ItemData:
	var slot = _slot_repository.get_slot(slot_name)
	return slot.equipped_item if slot else null

func try_equip(item_data: ItemData) -> bool:
	if not item_data:
		return false
	var slot = _slot_repository.try_equip(item_data)
	if slot:
		GBIS.sig_slot_item_equipped.emit(slot.slot_name, item_data)
		return true
	return false

func equip_moving_item(slot_name: String) -> bool:
	if equip_to(slot_name, GBIS.moving_item_service.moving_item):
		GBIS.moving_item_service.clear_moving_item()
		return true
	return false

func equip_to(slot_name, item_data: ItemData) -> bool:
	if _slot_repository.get_slot(slot_name).equip(item_data):
		GBIS.sig_slot_item_equipped.emit(slot_name, item_data)
		return true
	return false

func unequip(slot_name) -> ItemData:
	for current_inventory in GBIS.current_inventories:
		if not GBIS.inventory_service.is_inventory_existed(current_inventory):
			push_error("Cannot find inventory name [%s]. Please ensure GBIS.current_main_inventories contains valid inventory name." % current_inventory)
			return null
		var item_data = get_equipped_item(slot_name)
		if item_data and GBIS.inventory_service.add_item(current_inventory, item_data):
			_slot_repository.get_slot(slot_name).unequip()
			GBIS.sig_slot_item_unequipped.emit(slot_name, item_data)
			return item_data
	return null

func move_item(slot_name: String, base_size: int) -> void:
	if GBIS.moving_item_service.moving_item:
		push_error("Already had moving item.")
		return
	var item_data = get_equipped_item(slot_name)
	if item_data:
		GBIS.moving_item_service.draw_moving_item(item_data, Vector2i.ZERO, base_size)
		_slot_repository.get_slot(slot_name).unequip()
		GBIS.sig_slot_item_unequipped.emit(slot_name, item_data)
