extends Node
## 物品焦点业务类
class_name ItemFocusService

## 当前焦点目标
var _current_item_data: ItemData
var _current_container_name: String = ""

## 焦点物品
func focus_item(item_data: ItemData, container_name: String) -> void:
	# 如果当前有移动物品，则不允许焦点切换
	if GBIS.moving_item_service.moving_item:
		return
	
	# 如果焦点没有变化，直接返回
	if _current_item_data == item_data and _current_container_name == container_name:
		return
	
	# 设置新焦点
	_current_item_data = item_data
	_current_container_name = container_name
	GBIS.sig_item_focused.emit(item_data)

## 焦点丢失
func item_lose_focus() -> void:
	if not _current_item_data:
		return
	GBIS.sig_item_focus_lost.emit(_current_item_data.duplicate())
	_current_item_data = null
	_current_container_name = ""

## 窗口关闭时手动调用，防止关闭后提示信息一直存在
func lost_by_container_close(container_name: String) -> void:
	if _current_container_name != container_name:
		return
	item_lose_focus()
