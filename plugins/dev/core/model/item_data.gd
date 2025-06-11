extends Resource
class_name ItemData

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

@export var icon: Texture2D
@export var columns: int = 1
@export var rows: int = 1
@export var type: Type = Type.ALL

func get_shape() -> Vector2i:
	return Vector2i(columns, rows)
