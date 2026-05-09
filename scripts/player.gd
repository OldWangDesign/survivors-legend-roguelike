extends CharacterBody2D

signal health_changed(current_hp: int, max_hp: int)
signal xp_changed(current_xp: int, needed_xp: int, level: int)
signal leveled_up(new_level: int)
signal died
signal hurt(amount: int)

const BASE_SPEED := 200.0
const PICKUP_ATTRACT_RANGE := 120.0
const PICKUP_COLLECT_RANGE := 25.0
const ANIM_SPEED := 0.25

var hit_radius: float = 14.0
var max_health: int = 100
var current_health: int = 100
var xp: int = 0
var level: int = 1
var facing: Vector2 = Vector2.RIGHT

var speed_mult: float = 1.0
var damage_mult: float = 1.0
var area_mult: float = 1.0
var cooldown_mult: float = 1.0
var pickup_range_mult: float = 1.0
var armor: int = 0

var invincible: bool = false
var _invincible_timer: float = 0.0
var _flash_timer: float = 0.0
const INVINCIBLE_DURATION := 0.5

var weapons: Array = []
var consumed_weapons: Array = []

var _sprite: Sprite2D
var _anim_frame: int = 0
var _anim_timer: float = 0.0
var _visual_scale: float = 1.0

# Character & Passive state
var _char_id: String = ""
var _passive: String = ""
var _char_base_speed: float = 200.0
var _xp_bonus: float = 0.0
var _projectile_bonus: float = 0.0
# Bloodthirst (samurai)
var _bt_kill_counter: int = 0
var _bt_stacks: int = 0
var _bt_timer: float = 0.0
# Mana Surge (mage)
var _mana_surge_timer: float = 0.0
# Life Spring (sweetie)
var _life_spring_timer: float = 0.0
# Overclock (cyber)
var _move_duration: float = 0.0
var _overclock_active: bool = false
# Divine Protection (princess)
var _divine_cd: float = 0.0
var _divine_ready: bool = true
# Passive state for HUD display
var passive_status: String = ""

# 被动视觉计时器（PRD 5.2）
var _shield_flash_timer: float = 0.0   # iron_wall 受击闪亮
var _life_spring_visual_timer: float = 0.0  # sweetie 回血 "+1" 持续 0.5s
var _level_up_flash_timer: float = 0.0  # 升级金色发光 0.3s
var _aura_phase: float = 0.0  # 通用旋转相位（princess 环绕等）
var _arc_phase: float = 0.0  # cyber 电弧抖动相位
var _arc_seed: float = 0.0  # cyber 电弧 seed


func _ready() -> void:
	add_to_group("player")
	GameData.player_ref = self
	collision_layer = 0
	collision_mask = 0

	_apply_character_data()

	current_health = max_health
	z_index = GameData.Z_PLAYER

	_sprite = Sprite2D.new()
	var frames: Array = GameData.sprites.get("player", [])
	if frames.size() > 0:
		_sprite.texture = frames[0]
	_visual_scale = GameData.get_player_visual_scale()
	_sprite.scale = Vector2.ONE * (hit_radius * 2.0 / 16.0) * _visual_scale
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_sprite)

	var char_data: Dictionary = GameData.get_character_data()
	var init_weapon: int = char_data.get("weapon", 0)
	add_weapon(init_weapon)
	health_changed.emit(current_health, max_health)
	xp_changed.emit(xp, GameData.get_xp_for_level(level), level)


func _apply_character_data() -> void:
	var data: Dictionary = GameData.get_character_data()
	_char_id = GameData.selected_character
	_passive = data.get("passive", "")
	max_health = data.get("max_health", 100)
	_char_base_speed = data.get("base_speed", 200.0)
	damage_mult = data.get("damage_mult", 1.0)
	cooldown_mult = data.get("cooldown_mult", 1.0)
	pickup_range_mult = data.get("pickup_mult", 1.0)
	match _passive:
		"retro_luck":
			_xp_bonus = 0.2
		"eagle_eye":
			_projectile_bonus = 0.25
		"mana_surge":
			_mana_surge_timer = 25.0
		"life_spring":
			_life_spring_timer = 5.0


func _physics_process(delta: float) -> void:
	var input_dir := Vector2.ZERO
	var joy: Control = GameData.joystick_ref
	if joy and joy.get("direction") and joy.direction != Vector2.ZERO:
		input_dir = joy.direction
	else:
		input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	var effective_speed := _char_base_speed * speed_mult
	# Survival Instinct passive
	if _passive == "survival_instinct" and float(current_health) / float(maxi(max_health, 1)) < 0.3:
		effective_speed *= 1.25
		passive_status = "加速中"
	elif _passive == "survival_instinct":
		passive_status = ""

	# Overclock passive
	if _passive == "overclock":
		if input_dir.length_squared() > 0.01:
			_move_duration += delta
		else:
			_move_duration = 0.0
		_overclock_active = _move_duration >= 2.0
		if _overclock_active:
			passive_status = "超频中"
		else:
			passive_status = ""

	velocity = input_dir * effective_speed
	if input_dir != Vector2.ZERO:
		facing = input_dir.normalized()
	move_and_slide()

	if invincible:
		_invincible_timer -= delta
		_flash_timer -= delta
		if _invincible_timer <= 0.0:
			invincible = false

	# Passive timers
	_update_passives(delta)

	# Animation
	var moving := input_dir.length_squared() > 0.01
	if moving:
		_anim_timer += delta
		if _anim_timer >= ANIM_SPEED:
			_anim_timer -= ANIM_SPEED
			_anim_frame = 1 - _anim_frame
			var frames: Array = GameData.sprites.get("player", [])
			if _anim_frame < frames.size():
				_sprite.texture = frames[_anim_frame]
	else:
		if _anim_frame != 0:
			_anim_frame = 0
			_anim_timer = 0.0
			var frames: Array = GameData.sprites.get("player", [])
			if frames.size() > 0:
				_sprite.texture = frames[0]

	_sprite.flip_h = facing.x < -0.1

	if invincible and _flash_timer > 0:
		_sprite.modulate = Color(3, 3, 3)
	elif invincible:
		_sprite.modulate.a = 0.5 + 0.5 * sin(_invincible_timer * 20.0)
	elif _level_up_flash_timer > 0:
		# 升级金色发光
		var lu_t: float = _level_up_flash_timer / 0.3
		_sprite.modulate = Color(1.0, 1.0, 1.0).lerp(Color(2.0, 1.7, 0.6), lu_t)
	elif _passive == "bloodthirst" and _bt_stacks >= 3:
		# 嗜血 3 层身体微红染色
		_sprite.modulate = Color(1.15, 0.8, 0.8)
	else:
		_sprite.modulate = Color.WHITE

	# 推进各类被动视觉计时器/相位
	_aura_phase += delta
	_arc_phase += delta
	if _shield_flash_timer > 0:
		_shield_flash_timer -= delta
	if _life_spring_visual_timer > 0:
		_life_spring_visual_timer -= delta
	if _level_up_flash_timer > 0:
		_level_up_flash_timer -= delta

	_collect_gems()
	_collect_chests()
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2(2, 3), hit_radius * 0.7, Color(0, 0, 0, 0.2))
	# 识别环不跟随视觉缩放（PRD 5.1）：跟物理一致比跟视觉一致更有用
	var marker_radius := hit_radius * 1.15
	draw_circle(Vector2.ZERO, marker_radius, Color(0.2, 0.65, 1.0, GameData.PLAYER_MARKER_ALPHA * 0.35))
	draw_arc(Vector2.ZERO, marker_radius, 0.0, TAU, 32, Color(0.35, 0.85, 1.0, GameData.PLAYER_MARKER_ALPHA), 2.0)

	# 被动视觉（PRD 5.2）
	_draw_passive_visual()

	# 低血量红色脉动（PRD 5.2.2）：< 30% 时呼吸光，无敌期间避让
	var hp_ratio: float = float(current_health) / float(maxi(max_health, 1))
	if hp_ratio < 0.3 and not invincible and current_health > 0:
		var freq: float = 5.0 + (1.0 - hp_ratio / 0.3) * 8.0  # 越低频率越快
		var alpha: float = 0.25 + 0.25 * sin(_aura_phase * freq)
		draw_circle(Vector2.ZERO, hit_radius * 1.5, Color(1.0, 0.1, 0.1, alpha))

	# 升级金色发光（PRD 5.2.2）：包裹一层金色环
	if _level_up_flash_timer > 0:
		var lu_t: float = _level_up_flash_timer / 0.3
		draw_circle(Vector2.ZERO, hit_radius * (1.5 + (1.0 - lu_t) * 0.6), Color(1.0, 0.85, 0.3, lu_t * 0.45))

	# Health bar above head (same style as enemies)
	var bar_w := hit_radius * 2.5
	var bar_h := 3.0
	var bar_y := -hit_radius - 8.0
	draw_rect(Rect2(-bar_w / 2, bar_y, bar_w, bar_h), Color(0.08, 0.08, 0.12, 0.8))
	var fill_pct := float(current_health) / float(maxi(max_health, 1))
	var fill_w := bar_w * fill_pct
	var bar_color := Color(0.2, 0.85, 0.3) if fill_pct > 0.5 else (Color(1.0, 0.8, 0.0) if fill_pct > 0.25 else Color(0.85, 0.2, 0.2))
	draw_rect(Rect2(-bar_w / 2, bar_y, fill_w, bar_h), bar_color)


func _draw_passive_visual() -> void:
	match _passive:
		"survival_instinct":
			# 求生本能：低血量时白色风速线（沿移动反方向）
			var ratio: float = float(current_health) / float(maxi(max_health, 1))
			if ratio < 0.3:
				var back := -facing
				for i in range(3):
					var off: float = float(i) - 1.0
					var perp := Vector2(-back.y, back.x) * (off * 5.0)
					var center := perp + back * (hit_radius * 0.4)
					var arc_color := Color(1.0, 1.0, 1.0, 0.5)
					draw_arc(center, hit_radius * (0.6 + i * 0.08),
						back.angle() - 0.6, back.angle() + 0.6, 8, arc_color, 1.5)
		"iron_wall":
			# 铁壁：淡蓝六边形护盾轮廓（常驻），受击瞬间闪亮
			var alpha: float = 0.25
			if _shield_flash_timer > 0:
				alpha = 0.6 * (_shield_flash_timer / 0.15) + 0.25
			var hex_r: float = hit_radius * 1.55
			for i in range(6):
				var a1: float = TAU * float(i) / 6.0
				var a2: float = TAU * float(i + 1) / 6.0
				var p1: Vector2 = Vector2(cos(a1), sin(a1)) * hex_r
				var p2: Vector2 = Vector2(cos(a2), sin(a2)) * hex_r
				draw_line(p1, p2, Color(0.45, 0.7, 1.0, alpha), 1.8)
		"eagle_eye":
			# 鹰眼：沿 facing 方向的淡绿色十字准星
			var dist: float = hit_radius * 2.0
			var center: Vector2 = facing * dist
			var size_h: float = 5.0
			var c := Color(0.5, 1.0, 0.4, 0.35)
			draw_line(center + Vector2(-size_h, 0), center + Vector2(size_h, 0), c, 1.5)
			draw_line(center + Vector2(0, -size_h), center + Vector2(0, size_h), c, 1.5)
			draw_arc(center, size_h * 1.2, 0.0, TAU, 12, c, 1.0)
		"bloodthirst":
			# 嗜血：1-3 层红色火焰环，半径递增
			if _bt_stacks > 0:
				for i in range(_bt_stacks):
					var ring_r: float = hit_radius * (1.2 + float(i) * 0.25)
					var ring_a: float = 0.25 + float(i) * 0.18
					var pulse: float = sin(_aura_phase * 3.0 + i) * 0.1 + 1.0
					draw_arc(Vector2.ZERO, ring_r * pulse, 0.0, TAU, 28,
						Color(1.0, 0.25, 0.1, ring_a), 2.0)
		"mana_surge":
			# 魔力涌动：最后 3s 紫色粒子向内汇聚（用 _draw 模拟）
			if _mana_surge_timer > 0 and _mana_surge_timer <= 3.0:
				var charge_t: float = 1.0 - _mana_surge_timer / 3.0  # 0 -> 1
				for i in range(8):
					var ang: float = TAU * float(i) / 8.0 + _aura_phase * 1.5
					var radius: float = hit_radius * (2.5 - charge_t * 1.8)
					var p: Vector2 = Vector2(cos(ang), sin(ang)) * radius
					draw_circle(p, 2.0, Color(0.7, 0.3, 1.0, 0.3 + charge_t * 0.5))
		"life_spring":
			# 生命之泉：回血时绿色十字 + "+1" 自管理小字 0.5s
			if _life_spring_visual_timer > 0:
				var t: float = _life_spring_visual_timer / 0.5
				var rise: float = (1.0 - t) * 8.0
				var pos := Vector2(0, -hit_radius - 4.0 - rise)
				var c := Color(0.4, 1.0, 0.5, t)
				draw_line(pos + Vector2(-4, 0), pos + Vector2(4, 0), c, 2.0)
				draw_line(pos + Vector2(0, -4), pos + Vector2(0, 4), c, 2.0)
				var font: Font = ThemeDB.fallback_font
				draw_string(font, pos + Vector2(6, 4), "+1", HORIZONTAL_ALIGNMENT_LEFT, -1, 11,
					Color(0.6, 1.0, 0.6, t))
		"overclock":
			# 超频：激活后青色电弧锯齿线
			if _overclock_active:
				for s in range(3):
					var seed_offset: float = floor(_arc_phase * 30.0) + float(s) * 17.0
					var pts := PackedVector2Array()
					var seg_count := 6
					var base_a: float = TAU * float(s) / 3.0 + _arc_phase * 1.2
					var ang_span: float = 0.7
					for i in range(seg_count + 1):
						var f: float = float(i) / float(seg_count)
						var ang: float = base_a + (f - 0.5) * ang_span
						var noise: float = sin(seed_offset + i * 13.7) * 3.0
						var r: float = hit_radius * 1.5 + noise
						pts.append(Vector2(cos(ang), sin(ang)) * r)
					for i in range(pts.size() - 1):
						draw_line(pts[i], pts[i + 1], Color(0.4, 0.9, 1.0, 0.85), 1.4)
		"divine_protection":
			# 神圣庇护：就绪态金色光点缓慢环绕脚底环
			if _divine_ready:
				var orbit_r: float = hit_radius * 1.3
				for i in range(3):
					var ang: float = _aura_phase * 1.0 + TAU * float(i) / 3.0
					var p := Vector2(cos(ang), sin(ang)) * orbit_r + Vector2(0, 2)
					draw_circle(p, 2.5, Color(1.0, 0.92, 0.5, 0.85))
					draw_circle(p, 4.0, Color(1.0, 0.85, 0.3, 0.25))
		_:
			pass


func take_damage(amount: int) -> void:
	if invincible:
		return
	# Iron Wall passive
	var actual_f := float(maxi(amount - armor, 1))
	if _passive == "iron_wall":
		actual_f *= 0.8
		_shield_flash_timer = 0.15  # 受击闪亮
	var actual := maxi(int(actual_f), 1)
	current_health -= actual
	current_health = maxi(current_health, 0)

	# Divine Protection passive
	if current_health <= 0 and _passive == "divine_protection" and _divine_ready:
		current_health = maxi(int(max_health * 0.3), 1)
		_divine_ready = false
		_divine_cd = 60.0
		passive_status = "冷却 60s"
		# 触发：金色全屏爆闪 + 冲击波
		VfxPool.screen_flash(Color(1.0, 0.85, 0.3, 0.5), 0.3)
		VfxPool.ring_wave(global_position, GameData.UI_GOLD, hit_radius * 6.0, 0.5, 4.0)
		VfxPool.spark_burst(global_position, 16, GameData.UI_GOLD, 180.0, 0.5)

	invincible = true
	_invincible_timer = INVINCIBLE_DURATION
	_flash_timer = 0.1
	health_changed.emit(current_health, max_health)
	hurt.emit(actual)
	AudioManager.play("player_hurt")
	if current_health <= 0:
		AudioManager.play("player_die")
		died.emit()


func heal(amount: int) -> void:
	current_health = mini(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)
	AudioManager.play("heal")


func apply_slow(mult: float, duration: float) -> void:
	speed_mult = minf(speed_mult, mult)
	var tw := create_tween()
	tw.tween_interval(duration)
	tw.tween_callback(func(): speed_mult = 1.0)


func apply_knockback(force: Vector2) -> void:
	position += force


func add_xp(amount: int) -> void:
	var bonus_amount := int(float(amount) * (1.0 + _xp_bonus))
	xp += bonus_amount
	var needed := GameData.get_xp_for_level(level)
	while xp >= needed:
		xp -= needed
		level += 1
		max_health += 3
		current_health = mini(current_health + 3, max_health)
		damage_mult += 0.01
		area_mult += 0.005
		cooldown_mult = maxf(0.3, cooldown_mult - 0.003)
		AudioManager.play("level_up")
		# 升级金色闪光（PRD 5.2.2）：全身金色 0.3s + ring_wave
		_level_up_flash_timer = 0.3
		VfxPool.ring_wave(global_position, GameData.UI_GOLD, hit_radius * 4.0, 0.4, 3.0)
		leveled_up.emit(level)
		needed = GameData.get_xp_for_level(level)
	xp_changed.emit(xp, needed, level)


func _update_passives(delta: float) -> void:
	# Bloodthirst decay
	if _passive == "bloodthirst" and _bt_stacks > 0:
		_bt_timer -= delta
		if _bt_timer <= 0.0:
			_bt_stacks = 0
		passive_status = "x%d %.1fs" % [_bt_stacks, maxf(_bt_timer, 0.0)]

	# Mana Surge timer
	if _passive == "mana_surge":
		_mana_surge_timer -= delta
		passive_status = "%.0fs" % maxf(_mana_surge_timer, 0.0)
		if _mana_surge_timer <= 0.0:
			_mana_surge_timer = 25.0
			_trigger_mana_surge()

	# Life Spring regen
	if _passive == "life_spring":
		_life_spring_timer -= delta
		if _life_spring_timer <= 0.0:
			_life_spring_timer = 5.0
			if current_health < max_health:
				heal(1)
				_life_spring_visual_timer = 0.5
		passive_status = "每5秒+1"

	# Divine Protection cooldown
	if _passive == "divine_protection":
		if not _divine_ready:
			_divine_cd -= delta
			if _divine_cd <= 0.0:
				_divine_ready = true
			passive_status = "冷却 %ds" % maxi(int(_divine_cd), 0) if not _divine_ready else "就绪"
		else:
			passive_status = "就绪"

	# Iron wall / retro luck / eagle eye are permanent
	if _passive == "iron_wall":
		passive_status = "伤害-20%"
	elif _passive == "retro_luck":
		passive_status = "经验+20%"
	elif _passive == "eagle_eye":
		passive_status = "射程+25%"


func _trigger_mana_surge() -> void:
	# 释放瞬间紫色冲击波（PRD 5.2 #6）
	VfxPool.ring_wave(global_position, Color(0.7, 0.3, 1.0), hit_radius * 5.0, 0.4, 3.5)
	VfxPool.spark_burst(global_position, 10, Color(0.7, 0.3, 1.0), 140.0, 0.4)
	for w in weapons:
		var node = w.get("node")
		if node and is_instance_valid(node) and node.has_method("force_attack"):
			node.force_attack()


func on_enemy_killed() -> void:
	# Soul Drain passive
	if _passive == "soul_drain" and current_health < max_health:
		heal(1)
	# Bloodthirst passive
	if _passive == "bloodthirst":
		_bt_kill_counter += 1
		if _bt_kill_counter >= 10:
			_bt_kill_counter = 0
			_bt_stacks = mini(_bt_stacks + 1, 3)
			_bt_timer = 5.0


# 灵魂汲取：紫色小灵魂飞向主角（PRD 5.2 #9，飞行需 is_instance_valid 检查）
func spawn_soul_drain_visual(from_pos: Vector2) -> void:
	if _passive != "soul_drain":
		return
	var scene := get_tree().current_scene
	if not scene:
		return
	var soul := Node2D.new()
	soul.set_script(preload("res://scripts/vfx/soul_orb.gd"))
	soul.global_position = from_pos
	soul.z_index = GameData.Z_VFX_HIGH
	scene.add_child(soul)


func get_effective_damage_mult() -> float:
	var mult := damage_mult
	if _passive == "bloodthirst" and _bt_stacks > 0:
		mult *= (1.0 + _bt_stacks * 0.15)
	return mult


func get_effective_cooldown_mult() -> float:
	var mult := cooldown_mult
	if _passive == "overclock" and _overclock_active:
		mult *= 0.6
	return mult


func add_weapon(weapon_type: int) -> void:
	var weapon_script: GDScript
	match weapon_type:
		GameData.WeaponType.WHIP:
			weapon_script = preload("res://scripts/weapons/whip.gd")
		GameData.WeaponType.MAGIC_WAND:
			weapon_script = preload("res://scripts/weapons/magic_wand.gd")
		GameData.WeaponType.KNIFE:
			weapon_script = preload("res://scripts/weapons/knife.gd")
		GameData.WeaponType.GARLIC:
			weapon_script = preload("res://scripts/weapons/garlic.gd")
		GameData.WeaponType.HOLY_WATER:
			weapon_script = preload("res://scripts/weapons/holy_water.gd")
		GameData.WeaponType.FIREBALL:
			weapon_script = preload("res://scripts/weapons/fireball.gd")
		GameData.WeaponType.LIGHTNING:
			weapon_script = preload("res://scripts/weapons/lightning.gd")
		GameData.WeaponType.CROSS:
			weapon_script = preload("res://scripts/weapons/cross.gd")
		GameData.WeaponType.SPIN_BLADE:
			weapon_script = preload("res://scripts/weapons/spin_blade.gd")
		GameData.WeaponType.BIBLE:
			weapon_script = preload("res://scripts/weapons/bible.gd")
		GameData.WeaponType.FREEZE_RAY:
			weapon_script = preload("res://scripts/weapons/freeze_ray.gd")
		GameData.WeaponType.POISON_CLOUD:
			weapon_script = preload("res://scripts/weapons/poison_cloud.gd")
		GameData.WeaponType.SHIELD:
			weapon_script = preload("res://scripts/weapons/shield.gd")
		GameData.WeaponType.METEOR:
			weapon_script = preload("res://scripts/weapons/meteor.gd")
		GameData.WeaponType.LIFESTEAL_AURA:
			weapon_script = preload("res://scripts/weapons/lifesteal_aura.gd")
		GameData.WeaponType.INFERNO_STORM:
			weapon_script = preload("res://scripts/weapons/inferno_storm.gd")
		GameData.WeaponType.ABSOLUTE_ZERO:
			weapon_script = preload("res://scripts/weapons/absolute_zero.gd")
		GameData.WeaponType.DEATH_SCYTHE:
			weapon_script = preload("res://scripts/weapons/death_scythe.gd")
		GameData.WeaponType.THOR_HAMMER:
			weapon_script = preload("res://scripts/weapons/thor_hammer.gd")
		GameData.WeaponType.PLAGUE_KING:
			weapon_script = preload("res://scripts/weapons/plague_king.gd")
		GameData.WeaponType.DIVINE_APOCALYPSE:
			weapon_script = preload("res://scripts/weapons/divine_apocalypse.gd")
		GameData.WeaponType.VOID_DEVOUR:
			weapon_script = preload("res://scripts/weapons/void_devour.gd")
	var weapon_node := Node2D.new()
	weapon_node.set_script(weapon_script)
	add_child(weapon_node)
	weapons.append({"type": weapon_type, "level": 1, "node": weapon_node})


func upgrade_weapon(weapon_type: int) -> bool:
	for w in weapons:
		if w["type"] == weapon_type:
			if w["level"] < 8:
				w["level"] += 1
				w["node"].set_weapon_level(w["level"])
				return true
	return false


func has_weapon(weapon_type: int) -> bool:
	for w in weapons:
		if w["type"] == weapon_type:
			return true
	return false


func get_weapon_level(weapon_type: int) -> int:
	for w in weapons:
		if w["type"] == weapon_type:
			return w["level"]
	return 0


func is_weapon_consumed(weapon_type: int) -> bool:
	return weapon_type in consumed_weapons


func can_evolve(evolution_type: int) -> bool:
	if not GameData.EVOLUTION_RECIPES.has(evolution_type):
		return false
	if has_weapon(evolution_type):
		return false
	var recipe: Array = GameData.EVOLUTION_RECIPES[evolution_type]
	for base_type in recipe:
		if get_weapon_level(base_type) < 8:
			return false
	return true


func get_available_evolutions() -> Array:
	var result: Array = []
	for evo_type in GameData.EVOLUTION_RECIPES.keys():
		if can_evolve(evo_type):
			result.append(evo_type)
	return result


func evolve_weapon(evolution_type: int) -> bool:
	if not can_evolve(evolution_type):
		return false
	var recipe: Array = GameData.EVOLUTION_RECIPES[evolution_type]
	for base_type in recipe:
		consumed_weapons.append(base_type)
		_remove_weapon(base_type)
	add_weapon(evolution_type)
	for w in weapons:
		if w["type"] == evolution_type:
			w["node"].start_cooldown()
			break
	return true


func _remove_weapon(weapon_type: int) -> void:
	for i in range(weapons.size()):
		if weapons[i]["type"] == weapon_type:
			var node: Node2D = weapons[i]["node"]
			if is_instance_valid(node):
				node.queue_free()
			weapons.remove_at(i)
			return


func _collect_gems() -> void:
	var gems := get_tree().get_nodes_in_group("gems")
	var attract_range_sq := pow(PICKUP_ATTRACT_RANGE * pickup_range_mult, 2)
	var collect_range_sq := pow(PICKUP_COLLECT_RANGE, 2)
	for gem in gems:
		if not is_instance_valid(gem):
			continue
		var dist_sq := global_position.distance_squared_to(gem.global_position)
		if dist_sq < collect_range_sq:
			add_xp(gem.xp_value)
			AudioManager.play("xp_pickup")
			# PICO-8 复古幸运：拾取经验球时金色 spark（事件触发，PRD 5.2 #3）
			if _passive == "retro_luck":
				VfxPool.spark_burst(global_position, 3, GameData.UI_GOLD, 60.0, 0.3)
			gem.queue_free()
		elif dist_sq < attract_range_sq:
			gem.start_attract(global_position)


func _collect_chests() -> void:
	var chests := get_tree().get_nodes_in_group("chests")
	var collect_sq := pow(35.0, 2)
	for chest in chests:
		if not is_instance_valid(chest):
			continue
		var dist_sq := global_position.distance_squared_to(chest.global_position)
		if dist_sq < collect_sq:
			chest.open(self)
