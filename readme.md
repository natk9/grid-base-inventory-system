# 🎮 网格基础物品系统 - Godot插件

[![Godot 4.x](https://img.shields.io/badge/Godot-4.x-%23478cbf)](https://godotengine.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

一个功能完整的网格基础物品库存系统插件，为Godot游戏提供背包、装备槽、物品拖拽等核心功能。

## ✨ 功能特性

- 🧳 多背包系统支持
- ⚔️ 装备槽与装备系统
- 🖱️ 物品拖拽交互
- 🔢 可堆叠物品支持
- 🧪 消耗品系统
- 🔄 背包间快速转移
- 🎮 多角色物品管理

## 🚀 快速开始

### 安装方式

1. **作为模板项目**  
   直接使用本项目作为起始模板

2. **作为插件使用**  
   将`addons/grid_base_inventory_system`文件夹复制到您的Godot项目中

### 基本配置

1. **项目入口**
```gdscript
# 在项目设置 -> 全局添加
# res://addons/grid_base_inventory_system/core/grid_base_inventory_system.gd
# 名称必须设置为 "GBIS"
```
2. **输入配置**
项目输入中需要配置四个输入，默认为：
* inv_click：鼠标左键点击
* inv_quick_move：shift + 鼠标右键
* inv_use：鼠标右键
* inv_split：鼠标中键

如果输入的名字和默认不一致，请在启动时更新GBIS中的以下属性
```gdscript
GBIS.input_click = "你的输入名字"
GBIS.input_quick_move = "你的输入名字"
GBIS.input_use = "你的输入名字"
GBIS.input_split = "你的输入名字"
```

## 🛠️ 使用指南

### 初始化设置

```gdscript
# 添加背包间快速移动关系
GBIS.add_quick_move_relation("背包A", "背包B")

# 设置当前背包列表（用于装备脱卸）
GBIS.current_inventories = ["背包A", "背包B"]
```

### 物品信息展示

监听以下信号来显示鼠标悬停物品信息：

```gdscript
GBIS.sig_item_focused.connect(显示物品信息的方法)
GBIS.sig_item_focus_lost.connect(清除物品信息的方法)
```

### 自定义物品类型

1. **装备类物品**  
   继承`EquipmentData`并重写关键方法：

```gdscript
extends EquipmentData

func test_need():
	# 装备需求检查逻辑
	return true

func equipped():
	# 装备时效果

func unequipped():
	# 卸下时效果
```

2. **可堆叠物品**  
   继承`StackableData`

3. **消耗品类**  
   继承`ConsumableData`并重写`consume()`方法

### 添加物品到背包

```gdscript
var my_item = preload("res://path/to/your_item.tres")
GBIS.add_item("主背包", my_item)
```

### 多角色支持

切换操作角色时更新：

```gdscript
GBIS.current_player = new_player
GBIS.current_inventories = new_player_inventories
```

## 📂 项目结构

```
addons/grid_base_inventory_system/
├── core/
│   ├── model/         # 数据模型
│   ├── repository/    # 数据存储
│   ├── service/       # 业务逻辑
│   ├── view/          # 视图组件
└── saves/             # 默认存档
```

## 🖼️ 示例截图
![物品系统示例](GBIS_demos/assets/screenshots/Snipaste_2025-06-16_14-12-21.png)  
*截图*

## 👥 贡献指南

欢迎提交Pull Request或Issue报告问题。请确保代码风格与现有项目一致。

## 🙏 作者（请关注）
- [B站: Java已死游戏当立](https://space.bilibili.com/3546831153793300)

## 📜 许可证

MIT License

Copyright (c) 2025 Cabbage0211

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
