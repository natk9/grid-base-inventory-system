extends Resource
class_name ItemResourceData

enum Type{
	ALL,             # 全部
	HELMET,          # 头盔
	ARMOR,           # 盔甲
	GLOVES,          # 手套
	PANTS,           # 裤子
	BOOTS,           # 靴子
	RING,            # 戒指
	AMULET,          # 项链
	SWORD,           # 剑
	AXE,             # 斧
	MACE,            # 锤
	DAGGER,          # 匕首
	STAFF,           # 法杖
	WAND,            # 魔杖
	BOW,             # 弓
	CROSSBOW,        # 弩
	SHIELD,          # 盾牌
	WINGS,           # 翅膀
	MOUNT,           # 坐骑
	CONSUMABLE,      # 消耗品
	QUEST_ITEM,      # 任务物品
	MATERIAL         # 材料
}

## 物品的图片
@export var image: Texture2D
## 物品所占的列数
@export_range(1, 6) var column: int = 1
## 物品所占的行数
@export_range(1, 6) var row: int = 1
## 物品类型
@export var type: Type

## 使用条件
func test_need() -> bool:
	return true

## 消耗
func consume() -> bool:
	print("消耗")
	return true
