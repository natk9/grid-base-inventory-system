extends Resource
class_name SlotData

var item: ItemData
var avilable_types: Array[GBIS.ItemType]
var slot_name: String

func equip(item_data: ItemData) -> bool:
	if is_item_avilable(item_data):
		if not item:
			item = item_data
			return true
	return false

func unequip() -> ItemData:
	var ret = item
	item = null
	return ret

func is_item_avilable(item_data: ItemData) -> bool:
	return avilable_types.has(GBIS.ItemType.ALL) or avilable_types.has(item_data.type)

func _init(slot_name: String, avilable_types: Array[GBIS.ItemType]) -> void:
	self.slot_name = slot_name
	self.avilable_types = avilable_types
