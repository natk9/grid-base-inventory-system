@tool
extends Control
## 背包视图，控制背包的绘制
class_name InventoryView

@export_group("Inventory Settings")
## 背包名字，如果重复，则显示同一来源的数据
@export var inventory_name: String = GBIS.DEFAULT_INVENTORY_NAME
## 背包列数，如果背包名字重复，列数需要一样
@export var inventory_columns: int = 2:
	set(value):
		inventory_columns = value
		_recalculate_size()
## 背包行数，如果背包名字重复，行数需要一样
@export var inventory_rows: int = 2:
	set(value):
		inventory_rows = value
		_recalculate_size()
## 允许存放的物品类型，如果背包名字重复，可存放的物品类型需要一样
@export var avilable_types: Array[String] = ["ANY"]

@export_group("Grid Settings")
## 格子大小
@export var base_size: int = 32:
	set(value):
		base_size = value
		_recalculate_size()
## 格子边框大小
@export var grid_border_size: int = 1:
	set(value):
		grid_border_size = value
		queue_redraw()
## 格子边框颜色
@export var grid_border_color: Color = GridView.DEFAULT_BORDER_COLOR:
	set(value):
		grid_border_color = value
		queue_redraw()
## 格子空置颜色
@export var gird_background_color_empty: Color = GridView.DEFAULT_EMPTY_COLOR:
	set(value):
		gird_background_color_empty = value
		queue_redraw()
## 格子占用颜色
@export var gird_background_color_taken: Color = GridView.DEFAULT_TAKEN_COLOR:
	set(value):
		gird_background_color_taken = value
		queue_redraw()
## 格子冲突颜色
@export var gird_background_color_conflict: Color = GridView.DEFAULT_CONFLICT_COLOR:
	set(value):
		gird_background_color_conflict = value
		queue_redraw()
## 格子可用颜色
@export var grid_background_color_avilable: Color = GridView.DEFAULT_AVILABLE_COLOR:
	set(value):
		grid_background_color_avilable = value
		queue_redraw()

@export_group("Stack Settings")
## 堆叠数量的字体
@export var stack_num_font: Font:
	set(value):
		stack_num_font = value
		queue_redraw()
## 堆叠数量的字体大小
@export var stack_num_font_size: int = 16:
	set(value):
		stack_num_font_size = value
		queue_redraw()
## 堆叠数量的边距（右下角）
@export var stack_num_margin: int = 4:
	set(value):
		stack_num_margin = value
		queue_redraw()
## 堆叠数量的颜色
@export var stack_num_color: Color = Color.WHITE:
	set(value):
		stack_num_color = value
		queue_redraw()

## 格子容器
var _grid_container: GridContainer
## 物品容器
var _item_container: Control

## 所有物品的View
var _items: Array[ItemView]
## 物品到格子的映射（Array[Vector2i]）
var _item_grids_map: Dictionary[ItemView, Array]
## 格子到格子View的映射
var _grid_map: Dictionary[Vector2i, GridView]
## 格子到物品的映射
var _grid_item_map: Dictionary[Vector2i, ItemView]

## 格子高亮
func grid_hover(grid_id: Vector2i) -> void:
	if not GBIS.moving_item_service.moving_item:
		return
	
	var moving_item_view = GBIS.moving_item_service.moving_item_view
	moving_item_view.base_size = base_size
	moving_item_view.stack_num_color = stack_num_color
	moving_item_view.stack_num_font = stack_num_font
	moving_item_view.stack_num_font_size = stack_num_font_size
	moving_item_view.stack_num_margin = stack_num_margin
	
	var moving_item_offset = GBIS.moving_item_service.moving_item_offset
	var moving_item = GBIS.moving_item_service.moving_item
	var item_shape = moving_item.get_shape()
	var grids = _get_grids_by_shape(grid_id - moving_item_offset, item_shape)
	var has_conflict = item_shape.x * item_shape.y != grids.size() or not GBIS.inventory_service.get_inventory(inventory_name).is_item_avilable(moving_item)
	for grid in grids:
		if has_conflict:
			break 
		has_conflict = _grid_map[grid].has_taken
		var item_view = _grid_item_map.get(grid_id)
		if has_conflict and item_view:
			var item_data: ItemData = item_view.data
			if item_data is StackableData:
				if item_data.item_name == GBIS.moving_item_service.moving_item.item_name and not item_data.is_full():
					has_conflict = false
	for grid in grids:
		var grid_view = _grid_map[grid]
		grid_view.state = GridView.State.CONFLICT if has_conflict else GridView.State.AVILABLE

## 格子失去高亮
func grid_lose_hover(grid_id: Vector2i) -> void:
	if not GBIS.moving_item_service.moving_item:
		return
	
	var moving_item_offset = GBIS.moving_item_service.moving_item_offset
	var moving_item = GBIS.moving_item_service.moving_item
	var item_shape = moving_item.get_shape()
	var grids = _get_grids_by_shape(grid_id - moving_item_offset, item_shape)
	for grid in grids:
		var grid_view = _grid_map[grid]
		grid_view.state = GridView.State.TAKEN if grid_view.has_taken else GridView.State.EMPTY

## 刷新背包显示
func refresh() -> void:
	_clear_inv()
	var inv_data = GBIS.inventory_service.get_inventory(inventory_name)
	var handled_item: Dictionary[ItemData, ItemView]
	for grid in _grid_map.keys():
		var item_data = inv_data.grid_item_map[grid]
		if item_data and not handled_item.has(item_data):
			var grids = inv_data.item_grids_map[item_data]
			var item = _draw_item(item_data, grids[0])
			handled_item[item_data] = item
			_items.append(item)
			_item_grids_map[item] = grids
			for g in grids:
				_grid_map[g].taken(g - grids[0])
				_grid_item_map[g] = item
			continue
		elif item_data:
			_grid_item_map[grid] = handled_item[item_data]
		else:
			_grid_item_map[grid] = null
	pass

## 通过格子ID获取物品视图
func find_item_view_by_grid(grid_id: Vector2i) -> ItemView:
	return _grid_item_map.get(grid_id)

## 初始化
func _ready() -> void:
	if Engine.is_editor_hint():
		call_deferred("_recalculate_size")
		return
	
	if not inventory_name:
		push_error("Inventory must have a name.")
		return
	
	var ret = GBIS.inventory_service.regist_inventory(inventory_name, inventory_columns, inventory_rows, avilable_types)
	if not ret:
		push_error("Inventory regist error.")
		return
	
	mouse_filter = Control.MOUSE_FILTER_PASS
	_init_grid_container()
	_init_item_container()
	_init_grids()
	GBIS.sig_inv_item_added.connect(_on_item_added)
	GBIS.sig_inv_item_removed.connect(_on_item_removed)
	GBIS.sig_inv_item_updated.connect(_on_inv_item_updated)
	GBIS.sig_inv_refresh.connect(refresh)
	
	visibility_changed.connect(_on_visible_changed)
	
	if not stack_num_font:
		stack_num_font = get_theme_font("font")
	
	call_deferred("refresh")

func _on_visible_changed() -> void:
	if is_visible_in_tree():
		# 需要等待GirdContainer处理完成，否则其下的所有grid没有position信息
		await get_tree().process_frame
		refresh()

## 清空背包显示
## 注意，只清空显示，不清空数据库
func _clear_inv() -> void:
	for item in _items:
		item.queue_free()
	_items = []
	_item_grids_map = {}
	for grid in _grid_map.values():
		grid.release()
	_grid_item_map = {}

## 从指定格子开始，获取形状覆盖的格子
func _get_grids_by_shape(start: Vector2i, shape: Vector2i) -> Array[Vector2i]:
	var ret: Array[Vector2i] = []
	for row in shape.y:
		for col in shape.x:
			var grid_id = Vector2i(start.x + col, start.y + row)
			if _grid_map.has(grid_id):
				ret.append(grid_id)
	return ret

## 监听添加物品
func _on_item_added(inv_name:String, item_data: ItemData, grids: Array[Vector2i]) -> void:
	if not inv_name == inventory_name:
		return
	if not is_visible_in_tree():
		return
	
	var item = _draw_item(item_data, grids[0])
	_items.append(item)
	_item_grids_map[item] = grids
	for grid in grids:
		_grid_map[grid].taken(grid - grids[0])
		_grid_item_map[grid] = item

## 监听移除物品
func _on_item_removed(inv_name:String, item_data: ItemData) -> void:
	if not inv_name == inventory_name:
		return
	if not is_visible_in_tree():
		return
	
	for i in range(_items.size() - 1, -1, -1):
		var item = _items[i]
		if item.data == item_data:
			var grids = _item_grids_map[item]
			for grid in grids:
				_grid_map[grid].release()
				_grid_item_map[grid] = null
			item.queue_free()
			_items.remove_at(i)
			break

## 监听更新物品
func _on_inv_item_updated(inv_name: String, grid_id: Vector2i) -> void:
	if not inv_name == inventory_name:
		return
	if not is_visible_in_tree():
		return
	
	_grid_item_map[grid_id].queue_redraw()

## 绘制物品
func _draw_item(item_data: ItemData, first_grid: Vector2i) -> ItemView:
	var item = ItemView.new(item_data, base_size, stack_num_font, stack_num_font_size, stack_num_margin, stack_num_color)
	_item_container.add_child(item)
	item.global_position = _grid_map[first_grid].global_position
	return item

## 初始化格子容器
func _init_grid_container() -> void:
	_grid_container = GridContainer.new()
	_grid_container.add_theme_constant_override("h_separation", 0)
	_grid_container.add_theme_constant_override("v_separation", 0)
	_grid_container.columns = inventory_columns
	_grid_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_grid_container)

## 初始化物品容器
func _init_item_container() -> void:
	_item_container = Control.new()
	add_child(_item_container)

## 初始化格子View
func _init_grids() -> void:
	for row in inventory_rows:
		for col in inventory_columns:
			var grid_id = Vector2i(col, row)
			var grid = GridView.new(self, grid_id, base_size, grid_border_size, grid_border_color, 
				gird_background_color_empty, gird_background_color_taken, gird_background_color_conflict, grid_background_color_avilable)
			_grid_container.add_child(grid)
			_grid_map[grid_id] = grid

## 编辑器中绘制示例
func _draw() -> void:
	if Engine.is_editor_hint():
		var inner_size = base_size - grid_border_size * 2
		for row in inventory_rows:
			for col in inventory_columns:
				draw_rect(Rect2(col * base_size, row * base_size, base_size, base_size), grid_border_color, true)
				draw_rect(Rect2(col * base_size + grid_border_size, row * base_size + grid_border_size, inner_size, inner_size), gird_background_color_empty, true)
				var font = stack_num_font if stack_num_font else get_theme_font("font")
				var text_size = font.get_string_size("99", HORIZONTAL_ALIGNMENT_RIGHT, -1, stack_num_font_size)
				var pos = Vector2(
					base_size - text_size.x - stack_num_margin,
					base_size - font.get_descent(stack_num_font_size) - stack_num_margin
				)
				pos += Vector2(col * base_size, row * base_size)
				draw_string(font, pos, "99", HORIZONTAL_ALIGNMENT_RIGHT, -1, stack_num_font_size, stack_num_color)

## 重新计算大小
func _recalculate_size() -> void:
		size = Vector2(inventory_columns * base_size, inventory_rows * base_size)
		queue_redraw()
