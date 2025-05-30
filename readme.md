# 物品库存系统 - Godot 实现

这是一个基于 Godot 引擎的物品库存系统实现，包含完整的背包、装备槽、物品拖拽等功能。

## v1.0.2 更新
- 移动所有内容到 plugins 文件夹，方便集成
- 增加 EquipmentResourceData.gd，用于装备属性和穿戴校验（test_need()）
- InventorySystem 增加穿戴（sig_equipped）和脱装备（sig_unequipped）信号
- InventorySystem 增加 get_all_equipments() 方法，返回所以已装备物品的 EquipmentResourceData 数组，可用于计算属性

## 功能特性

- 🎒 可配置的背包系统（行列布局）
- 🛡️ 装备槽系统（特殊类型物品槽）
- 🖱️ 物品拖拽放置功能
- 🔄 物品快速转移功能
- 🏷️ 物品类型系统
- 🖼️ 物品图标和尺寸支持

## 核心脚本说明

### 1. `inventory.gd` - 基础背包系统
- 管理背包格子布局
- 处理物品的添加/移除
- 实现物品拖拽逻辑
- 支持物品快速转移

### 2. `equipment_slot.gd` - 装备槽系统
- 继承自基础背包
- 支持装备/卸下物品
- 提供装备有效性验证
- 可视化反馈（有效/无效颜色）

### 3. `inventory_system.gd` - 库存管理系统
- 全局管理所有库存和装备槽
- 处理物品移动状态
- 提供装备/卸下接口

### 4. `inventroy_grid.gd` - 库存格子
- 单个格子的状态管理
- 处理鼠标交互
- 提供视觉反馈

### 5. `item.gd` - 物品基类
- 物品基础功能
- 拖拽移动实现
- 物品数据管理

### 6. `item_resource_data.gd` - 物品数据
- 定义物品类型枚举
- 存储物品属性（尺寸、图标等）

## 使用方法

1. 创建库存界面：
   - 实例化 `Inventory` 场景
   - 设置行列数和允许的物品类型

2. 创建装备槽：
   - 实例化 `EquipmentSlot` 场景
   - 设置背景图和有效/无效颜色

3. 注册到库存系统：
   - 通过 `InventorySystem.add_main_inventory()` 注册主背包
   - 通过 `InventorySystem.add_equipment_slot()` 注册装备槽

4. 创建物品：
   - 使用 `Item.new_item()` 工厂方法
   - 提供 `ItemResourceData` 资源

## 输入控制

- **左键点击（ui_click）**：选择/移动物品
- **右键点击（ui_equip_unequip）**：装备/卸下物品
- **快捷键（ui_quick_move）**：快速转移物品

## 依赖

- Godot 4.0+

## 作者

B站：Java已死游戏当立

## 许可证

[MIT]
