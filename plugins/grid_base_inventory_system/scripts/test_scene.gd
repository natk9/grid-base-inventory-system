extends Control

@onready var inventory_label_1: Label = $Inventory1/InventoryLabel1
@onready var inventory_label_2: Label = $Inventory2/InventoryLabel2
@onready var inventory_label_3: Label = $Inventory3/InventoryLabel3

@onready var inventory_1: Inventory = $Inventory1
@onready var inventory_2: Inventory = $Inventory2
@onready var inventory_3: Inventory = $Inventory3

@onready var boots_slot: EquipmentSlot = $BootsSlot
@onready var weapon_slot: EquipmentSlot = $WeaponSlot
@onready var armor_slot: EquipmentSlot = $ArmorSlot


func _ready() -> void:
	$Button.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	var item1 = Item.new_item(load("res://plugins/grid_base_inventory_system/resources/armor_1.tres"))
	var item2 = Item.new_item(load("res://plugins/grid_base_inventory_system/resources/boots_1.tres"))
	var item3 = Item.new_item(load("res://plugins/grid_base_inventory_system/resources/sword_1.tres"))
	var item4 = Item.new_item(load("res://plugins/grid_base_inventory_system/resources/healing_bottle_1.tres"))
	
	inventory_1.add_item(item1)
	inventory_1.add_item(item2)
	inventory_1.add_item(item3)
	inventory_1.add_item(item4)
	
	inventory_1.add_quick_move_target(inventory_3)
	inventory_1.add_quick_move_target(inventory_2)
	
	inventory_2.add_quick_move_target(inventory_1)
	
	inventory_3.add_quick_move_target(inventory_1)
	
	InventorySystem.add_main_inventory(inventory_1)
	InventorySystem.add_equipment_slot(boots_slot)
	InventorySystem.add_equipment_slot(weapon_slot)
	InventorySystem.add_equipment_slot(armor_slot)

func _process(_delta: float) -> void:
	inventory_label_1.text = "物品数量：" + str(inventory_1._item_to_first_grid.size())
	inventory_label_2.text = "物品数量：" + str(inventory_2._item_to_first_grid.size())
	inventory_label_3.text = "物品数量：" + str(inventory_3._item_to_first_grid.size())
