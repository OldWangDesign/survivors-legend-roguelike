# 幸存者传说 (Survivor Legend)

一款使用 Godot 4.5.1 + GDScript 开发的 Vampire Survivors 风格游戏。

## 玩法

- **WASD / 方向键** 控制角色移动
- 武器自动攻击附近的敌人
- 击杀敌人获得经验宝石，升级后选择新武器或强化
- 存活 20 分钟即为胜利

## 武器系统

| 武器 | 描述 |
|------|------|
| 鞭子 | 初始武器，水平横扫，穿透敌人 |
| 魔杖 | 向最近的敌人发射弹幕 |
| 飞刀 | 向面朝方向快速投掷，可穿透 |
| 大蒜 | 对周围敌人持续造成范围伤害 |
| 圣水 | 在地面生成持续伤害区域 |

所有武器最高可升至 8 级，升级提升伤害、缩短冷却、扩大范围。

## 敌人类型

- **蝙蝠** — 速度快、血量低
- **骷髅** — 中等速度和血量
- **僵尸** — 速度慢、血量高
- **幽灵** — 速度极快
- **Boss** — 每 5 分钟出现，高血量高伤害

## 升级选项

升级时可选择：
- 获取新武器
- 升级已有武器
- 属性强化（生命值、移速、伤害、范围、冷却、拾取范围）

## 运行方式

1. 安装 [Godot 4.5.1](https://godotengine.org/download)
2. 打开 Godot，导入项目（选择 `project.godot` 所在文件夹）
3. 按 F5 运行游戏

## 项目结构

```
project.godot              # 项目配置
scenes/
  main_menu.tscn           # 主菜单场景
  game.tscn                # 游戏主场景
scripts/
  game_data.gd             # 全局数据（自动加载）
  game_manager.gd          # 游戏流程管理
  player.gd                # 玩家角色
  enemy.gd                 # 敌人
  enemy_spawner.gd         # 敌人生成器
  experience_gem.gd        # 经验宝石
  damage_number.gd         # 浮动伤害数字
  background.gd            # 背景网格
  weapons/
	weapon_base.gd         # 武器基类
	whip.gd                # 鞭子
	magic_wand.gd          # 魔杖
	knife.gd               # 飞刀
	garlic.gd              # 大蒜
	holy_water.gd          # 圣水
	holy_water_zone.gd     # 圣水地面区域
	projectile.gd          # 通用弹幕
  ui/
	hud.gd                 # 游戏内HUD
	level_up_panel.gd      # 升级选择面板
	game_over_screen.gd    # 游戏结束/胜利画面
	main_menu.gd           # 主菜单
```
