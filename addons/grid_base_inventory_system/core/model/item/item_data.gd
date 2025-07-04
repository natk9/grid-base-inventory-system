extends Resource
## 物品数据基类，不要直接继承这个类
class_name ItemData

@export_group("Common Settings")
## 物品名称，需要唯一
@export var item_name: String = "Item Name"
## 物品类型，值为“ANY”表示所有类型
@export var type: String = "ANY"
@export_group("Display Settings")
## 物品图标
@export var icon: Texture2D
## 物品占的列数
@export var columns: int = 1
## 物品占的行数
@export var rows: int = 1

## 获取货品形状
func get_shape() -> Vector2i:
	return Vector2i(columns, rows)

## 丢弃物品时调用，需重写
func drop() -> void:
	push_warning("[Override this function] item [%s] dropped" % item_name)
