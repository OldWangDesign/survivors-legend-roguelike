# 幸存者传说 (Survivors Legend)

一款使用 **Godot 4.5 + GDScript** 开发的 Vampire Survivors 风格 Roguelike 生存游戏。

控制角色在怪潮中存活，武器自动攻击，升级获取新技能，合成超级武器，挑战 20 个关卡。支持 Android 平台。

## 游戏特色

- **10 个可选角色** — 骑士、武士、法师、游侠等，各有独特被动技能和属性倾向
- **15 种基础武器** — 鞭子、火球术、闪电链、冰冻射线、旋风斩等
- **7 种超级武器** — 双满级武器合成，炼狱风暴、绝对零度、死神之镰等终极形态
- **5 种地图场景** — 草原、地下城、雪原、火山、霓虹城
- **20 个关卡** + 自由模式
- **Boss 系统** — 每 5 分钟出现，拥有独立 AI 和弹幕攻击
- **完整音效系统** — BGM、武器音效、UI 反馈

## 操控方式

| 平台 | 操作 |
|------|------|
| PC | WASD / 方向键移动，TAB 查看详细属性，ESC 暂停 |
| 移动端 | 虚拟摇杆移动 |

## 武器合成路线

```
火球术 + 陨石   → 炼狱风暴        鞭子 + 旋风斩   → 死神之镰
冰冻射线 + 圣水 → 绝对零度        闪电链 + 十字架  → 雷神之锤
毒雾 + 大蒜     → 瘟疫之王        圣经 + 护盾     → 天启圣光
吸血光环 + 魔杖 → 虚空吞噬
```

两个基础武器升至 **Lv.8** 后，升级时出现金色合成选项。

## 角色一览

| 角色 | 定位 | 初始武器 | 被动技能 |
|------|------|----------|----------|
| 神秘幸存者 | 默认 | 鞭子 | 求生本能 — 血量 <30% 时移速 +25% |
| 蓝甲骑士 | 坦克 | 鞭子 | 铁壁 — 受伤减少 20% |
| PICO-8 复古 | 平衡 | 火球术 | 复古幸运 — 经验值 +20% |
| 翠林游侠 | 远程 | 飞刀 | 鹰眼 — 投射物射程和飞速 +25% |
| 赤焰武士 | 近战 | 十字架 | 嗜血 — 击杀叠攻击力，最高 +45% |
| 暗夜法师 | 法师 | 魔杖 | 魔力涌动 — 每 25 秒所有武器额外攻击一次 |
| Sweetie 柔和 | 辅助 | 圣水 | 生命之泉 — 每 5 秒回复 1 HP |
| 赛博朋克 | 速攻 | 旋风斩 | 超频芯片 — 持续移动时冷却 +40% |
| 暗黑哥特 | 暴击 | 闪电链 | 灵魂汲取 — 击杀回复 1 HP |
| 公主婚礼 | 范围 | 圣经 | 神圣庇护 — 致命伤害免死一次（60s CD） |

## 项目结构

```
project.godot                  # Godot 项目配置
scenes/
  main_menu.tscn               # 主菜单
  char_select.tscn             # 角色选择
  stage_select.tscn            # 关卡选择
  game.tscn                    # 游戏主场景
scripts/
  game_data.gd                 # 全局数据（角色/武器/关卡配置）
  game_manager.gd              # 游戏流程管理
  audio_manager.gd             # 音效管理器
  player.gd                    # 玩家角色（属性/被动/碰撞）
  enemy.gd                     # 普通敌人
  boss_enemy.gd                # Boss 敌人
  enemy_spawner.gd             # 敌人生成器
  enemy_formation.gd           # 敌人阵型系统
  stage_spawner.gd             # 关卡波次配置
  experience_gem.gd            # 经验宝石
  treasure_chest.gd            # 宝箱
  background.gd                # 无限滚动背景
  bg_tile_gen.gd               # 背景瓦片生成
  sprite_gen.gd                # 像素精灵程序化生成
  sprite_gen_styles.gd         # 精灵风格定义
  sprite_gen_variants.gd       # 精灵变体
  sprite_loader.gd             # 精灵加载器
  vfx_pool.gd                  # 特效对象池
  weapons/
	weapon_base.gd             # 武器基类
	whip.gd                    # 鞭子
	magic_wand.gd              # 魔杖
	knife.gd                   # 飞刀
	garlic.gd                  # 大蒜
	holy_water.gd              # 圣水
	fireball.gd                # 火球术
	lightning.gd               # 闪电链
	cross.gd                   # 十字架
	spin_blade.gd              # 旋风斩
	bible.gd                   # 圣经
	freeze_ray.gd              # 冰冻射线
	poison_cloud.gd            # 毒雾
	shield.gd                  # 护盾
	meteor.gd                  # 陨石
	lifesteal_aura.gd          # 吸血光环
	inferno_storm.gd           # 超武：炼狱风暴
	absolute_zero.gd           # 超武：绝对零度
	death_scythe.gd            # 超武：死神之镰
	thor_hammer.gd             # 超武：雷神之锤
	plague_king.gd             # 超武：瘟疫之王
	divine_apocalypse.gd       # 超武：天启圣光
	void_devour.gd             # 超武：虚空吞噬
  ui/
	main_menu.gd               # 主菜单
	char_select.gd             # 角色选择界面
	stage_select.gd            # 关卡选择
	hud.gd                     # 游戏内 HUD
	level_up_panel.gd          # 升级选择面板
	game_over_screen.gd        # 结算画面
	pause_menu.gd              # 暂停菜单
	stats_panel.gd             # 属性详情面板
	debug_panel.gd             # 调试面板
	menu_bg.gd                 # 菜单背景
	virtual_joystick.gd        # 虚拟摇杆
  vfx/
	hit_flash.gd               # 受击闪白
	flash_rect.gd              # 全屏闪光
	float_text.gd              # 浮动文字
	ring_wave.gd               # 冲击波
	spark.gd                   # 火花粒子
	trail.gd                   # 拖尾效果
	line_attack.gd             # 线性攻击特效
assets/
  sprites/                     # 角色/敌人/道具精灵（9 种风格）
  bg/                          # 地图背景瓦片（5 种地形）
  fonts/                       # 字体（Noto Sans SC + Ark Pixel）
  icons/                       # 应用图标和启动画面
  audio/                       # 音效和 BGM
doc/                           # 设计文档
```

## 运行方式

1. 安装 [Godot 4.5](https://godotengine.org/download)
2. 克隆本仓库
   ```bash
   git clone https://github.com/OldWangDesign/survivors-legend-roguelike.git
   ```
3. 用 Godot 打开项目（导入 `project.godot` 所在文件夹）
4. 按 **F5** 运行

## 技术栈

- **引擎**：Godot 4.5（GL Compatibility 渲染器）
- **语言**：GDScript
- **分辨率**：1280×720，canvas_items 缩放模式
- **目标平台**：Android (arm64-v8a)、PC

## License

MIT
