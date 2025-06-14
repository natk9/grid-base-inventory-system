extends Resource
class_name SlotData

var equipped_item: ItemData
var avilable_types: Array[GBIS.ItemType]
var slot_name: String

func equip(item_data: ItemData) -> bool:
	if not equipped_item:
		if is_item_avilable(item_data):
			equipped_item = item_data
			equipped_item.equipped(slot_name)
			return true
	return false

func unequip() -> ItemData:
	var ret = equipped_item
	ret.unequipped(slot_name)
	equipped_item = null
	return ret

func is_item_avilable(item_data: ItemData) -> bool:
	if avilable_types.has(GBIS.ItemType.ALL) or avilable_types.has(item_data.type):
		return item_data.test_need(slot_name)
	return false

@warning_ignore("shadowed_variable")
func _init(slot_name: String, avilable_types: Array[GBIS.ItemType]) -> void:
	self.slot_name = slot_name
	self.avilable_types = avilable_types
