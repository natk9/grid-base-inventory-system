extends ItemData
class_name EquipmentData

func test_need(slot_name: String) -> bool:
	push_warning("[Override this function] [%s]:[%s] Equipment slot test passed. 
		If you have multiple players, you should test whether this slot belongs to GBIS.current_player. 
		Don't forget to change GBIS.current_player to the player that is currently being modified." % [GBIS.current_player, slot_name])
	return true

func equipped(slot_name: String) -> void:
	push_warning("[Override this function] [%s] equipped item [%s] at slot [%s]" % [GBIS.current_player, item_name, slot_name])

func unequipped(slot_name: String) -> void:
	push_warning("[Override this function] [%s] unequipped item [%s] at slot [%s]" % [GBIS.current_player, item_name, slot_name])
