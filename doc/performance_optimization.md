# 性能优化方案

## 背景

游戏到了后期（8 个超级武器 + 200-300 个敌人同时在场），帧数降至个位数（5-8 FPS），严重影响可玩性。经分析，瓶颈主要在 CPU 端（敌人查询的 O(N×M) 复杂度）而非 GPU 端。

## 优化目标

- 后期（8 超级武器 + 200-300 敌人）帧数从个位数提升到 **25-30 FPS**
- 超级武器的华丽 `_draw()` 特效**完全保留不动**
- 弹体仅做轻度视觉精简（删除螺旋粒子和旋转能量尖刺）

## 性能瓶颈分析

| 瓶颈 | 原因 | 每帧开销 |
|------|------|---------|
| 敌人查询 O(N×M) | 每个武器/弹体每帧遍历全部 300 敌人做距离判断 | 8武器×300敌人 = 2400+ 次距离计算/帧 |
| 持续伤害每帧计算 | bible/death_scythe 等旋转武器每帧对每个子体做碰撞伤害 | 12子体×300敌人×60帧 = 216000 次/秒 |
| 无条件重绘 | 300 敌人每帧 queue_redraw()，即使外观没变化 | 300 次无效重绘/帧 |
| 背景每帧重绘 | ~1000 个地砖每帧重绘，即使相机没动 | ~1000 draw_texture/帧 |
| 弹体 draw call 多 | 每颗弹体 ~70 个绘制操作，20 颗同时 = 1400/帧 | ~1400 draw call/帧 |

## 优化项总览

| 优化项 | 预估帧数提升 | 视觉影响 | 涉及文件数 |
|-------|-----------|---------|----------|
| 1. 空间哈希网格 | +10-15 FPS | 无 | ~20 文件 |
| 2. 持续伤害武器节流 | +5-8 FPS | 无 | 4 文件 |
| 3. 敌人/背景条件重绘 | +2-3 FPS | 无 | 2 文件 |
| 4. 弹体轻度精简 | +2-3 FPS | 极轻微 | 1 文件 |

---

## 优化项 1：空间哈希网格（最大收益）

### 问题

所有武器、弹体每帧遍历全部 300 个敌人做距离计算，复杂度 O(N×M)。

### 方案

创建全局 `SpatialGrid` Autoload（`scripts/spatial_grid.gd`），将敌人按位置存入 128px 网格，武器查询时只检测附近格子，将复杂度降至接近 O(1)。

### 关键设计

- **网格大小**：128px（大于最大武器范围，保证单次查询覆盖）
- **哈希键**：`cx * 73856093 + cy * 19349663`，降低冲突率
- **跨格检测**：敌人移动时比较新旧 cell key，未跨格不更新（减少哈希操作）
- **有效性过滤**：`get_nearby()` 和 `get_in_range()` 内部自动过滤已释放节点

### API

```gdscript
SpatialGrid.register(entity: Node2D)         # 注册实体
SpatialGrid.unregister(entity: Node2D)       # 注销实体
SpatialGrid.update_position(entity: Node2D)  # 更新位置（跨格才执行）
SpatialGrid.get_nearby(pos, radius) -> Array  # 快速获取附近实体（含有效性过滤）
SpatialGrid.get_in_range(pos, radius) -> Array # 精确距离过滤
SpatialGrid.get_nearest(pos, max_range) -> Node2D # 获取最近实体
```

### 涉及文件

- 新建 `scripts/spatial_grid.gd` — 空间哈希网格实现
- 修改 `project.godot` — 注册 SpatialGrid Autoload
- 修改 `scripts/enemy.gd` — `_ready` 注册、移动时更新、`_die` 注销
- 修改 `scripts/boss_enemy.gd` — 同上
- 修改 `scripts/weapons/weapon_base.gd` — `get_enemies_in_range`/`get_nearest_enemy` 改用 SpatialGrid
- 修改约 20 个武器文件 — 所有 `get_nodes_in_group("enemies")` + 距离过滤替换为 SpatialGrid 查询

---

## 优化项 2：持续伤害武器节流

### 问题

bible、divine_apocalypse、death_scythe、spin_blade 四个超级武器每帧对每个子体做碰撞伤害计算。

### 方案

添加 0.1 秒伤害间隔（`DMG_INTERVAL`），从每帧计算改为每 0.1 秒计算一次，减少 83% 的计算量。

### 实现模式

```gdscript
var _dmg_tick: float = 0.0
const DMG_INTERVAL := 0.1

func _process(delta: float) -> void:
    _dmg_tick += delta
    if _dmg_tick >= DMG_INTERVAL:
        _dmg_tick -= DMG_INTERVAL
        # 伤害逻辑移入此处
        for enemy in SpatialGrid.get_in_range(pos, hit_radius):
            enemy.take_damage(dmg * DMG_INTERVAL * multiplier)
```

### DPS 保持不变

原来 `enemy.take_damage(dmg * delta * 3.0)` 改为 `enemy.take_damage(dmg * DMG_INTERVAL * 3.0)`，总 DPS 数学等价。

### 涉及文件

- `scripts/weapons/bible.gd`
- `scripts/weapons/divine_apocalypse.gd`
- `scripts/weapons/death_scythe.gd`
- `scripts/weapons/spin_blade.gd`

---

## 优化项 3：条件重绘

### 3a. 敌人条件重绘

**问题**：300 个敌人每帧无条件 `queue_redraw()`，即使外观没变化。

**方案**：仅在需要时重绘（被击中闪白、精英光环动画、血量变化）。

```gdscript
# 将无条件 queue_redraw() 改为：
if _flash_timer > 0 or elite_type != "" or health < max_health:
    queue_redraw()
```

**文件**：`scripts/enemy.gd`

### 3b. 背景条件重绘

**问题**：背景每帧重绘 ~1000 个地砖，即使相机没动。

**方案**：仅在相机移动超过 16px 时重绘。

```gdscript
var _last_cam_pos: Vector2 = Vector2.INF
const REDRAW_THRESHOLD := 16.0

func _process(_delta: float) -> void:
    var cam_pos := get_viewport().get_camera_2d().global_position
    if _last_cam_pos.distance_squared_to(cam_pos) > REDRAW_THRESHOLD * REDRAW_THRESHOLD:
        _last_cam_pos = cam_pos
        queue_redraw()
```

**文件**：`scripts/background.gd`

---

## 优化项 4：弹体轻度视觉精简

### 问题

每颗弹体 ~70 个 draw call，20 颗同时存在时 = 1400 draw call/帧。

### 方案

删除"螺旋粒子"和"旋转能量尖刺"，保留拖尾线和核心光圈。

### 删除内容

1. **螺旋粒子**（`_draw` 中拖尾循环里的 `if i % 2 == 0` 块）：每段拖尾上 2 个环绕的小圆
2. **旋转能量尖刺**（`_draw` 末尾的 4 方向辐射线）：4 条旋转的线 + 端点圆

### 保留内容

- 三层拖尾线（外层光场 + 中层辉光 + 核心白线）
- 五层脉动能量核心（从外到内渐亮渐小）

### 效果

- 每颗弹体从 ~70 降到 ~47 draw call
- 20 颗弹体每帧省下 ~460 个绘制操作
- 视觉上几乎无感（玩家对单颗弹体关注度远低于超级武器）

**文件**：`scripts/weapons/projectile.gd`

---

## 额外修复

### 运行时崩溃修复

在实施优化后，发现以下运行时问题并修复：

1. **访问已释放对象**：`SpatialGrid.get_nearby()` 可能返回已被 `queue_free` 的敌人节点。修复：在 `get_nearby()` 内部增加 `is_instance_valid` 过滤。

2. **节点树繁忙时 add_child 失败**：`fireball.gd` 通过 `tree_exiting` 信号触发爆炸，此时场景树处于 blocked 状态，无法执行 `add_child()`。修复：改用 `call_deferred("_explode", ...)` 延迟执行。

---

## 预期效果

| 场景 | 优化前 | 优化后 |
|------|--------|--------|
| 一般后期（5-6 武器 + 150 敌人） | ~15 FPS | **30+ FPS** |
| 极限后期（8 超级武器 + 250+ 敌人） | 5-8 FPS | **25-30 FPS** |

- 超级武器视觉效果：**完全保留**
- 弹体视觉变化：保留拖尾和核心光圈，仅去掉小粒子和辐射线，实战几乎无感

## 实施顺序

```
空间哈希网格 → 伤害节流 → 条件重绘 → 弹体精简
```

空间哈希是基础设施，伤害节流依赖它；条件重绘和弹体精简相互独立。

## 未来可选优化

如果帧数仍需进一步提升，可考虑：

- **VFX 预算动态调整**：根据敌人数量动态减少粒子特效
- **敌人 LOD**：远处敌人减少绘制细节
- **对象池复用**：弹体和敌人节点池化，减少 GC 压力
- **MAX_ENEMIES 限制**：极端场景下限制同屏敌人上限（当前 300）
