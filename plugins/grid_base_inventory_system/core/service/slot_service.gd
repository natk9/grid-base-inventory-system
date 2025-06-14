extends Node
class_name SlotService

var _slot_repository: SlotRepository = SlotRepository.instance

## 注册槽位
func regist_slot(slot_name: String, avilable_types: Array[GBIS.ItemType]) -> bool:
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

func equip_to(slot_name, item_data: ItemData) -> bool:
	if _slot_repository.equip_to(slot_name, item_data):
		GBIS.sig_slot_item_equipped.emit(slot_name, item_data)
		return true
	return true

func unequip(slot_name) -> ItemData:
	var item = _slot_repository.unequip(slot_name)
	if item:
		GBIS.sig_slot_item_unequipped.emit(slot_name, item)
	return item
