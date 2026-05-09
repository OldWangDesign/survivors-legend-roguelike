extends Node2D

var health: float = 10.0
var max_health: float = 10.0
var damage: int = 5
var speed: float = 50.0
var xp_value: int = 1
var enemy_size: float = 10.0
var color: Color = Color.RED
var enemy_type: String = "bat"

var elite_type: String = ""
var armor_reduction: float = 0.0

var _flash_timer: float = 0.0
var _dying: bool = false
var _slow_mult: float = 1.0
var _slow_timer: float = 0.0
var _sprite: Sprite2D
var _anim_frame: int = 0
var _anim_timer: float = 0.0
const ANIM_SPEED := 0.35

var _elite_aura_timer: float = 0.0
var _rush_mode: bool = false
var _rush_target: Vector2 = Vector2.ZERO
var _rush_speed_mult: float = 2.5
var _formation_delay: float = 0.0
const ELITE_AURA_COLORS: Dictionary = {
	"berserk": Color(1.0, 0.2, 0.1, 0.5),
	"armored": Color(0.2, 0.4, 1.0, 0.5),
	"splitter": Color(0.2, 1.0, 0.3, 0.5),
}

# 机制怪行为（PRD 5.10）
var _behavior: String = ""
var _base_modulate: Color = Color.WHITE
var _charge_damage: int = 0
var _charge_speed: float = 0.0
var _retreat_speed: float = 0.0
var _keep_distance: float = 140.0
var _shoot_interval: float = 2.5
# Charger 状态机：IDLE / WARNING / CHARGING / COOLDOWN
enum ChargerState { IDLE, WARNING, CHARGING, COOLDOWN }
var _charger_state: int = ChargerState.IDLE
var _charger_state_timer: float = 0.0
var _charger_charge_dir: Vector2 = Vector2.ZERO
var _charger_charge_dist: float = 0.0
# Ranged 状态
var _ranged_shoot_timer: float = 0.0


func _ready() -> void:
	add_to_group("enemies")
	SpatialGrid.register(self)


func setup(type_key: String, difficulty_mult: float = 1.0) -> void:
	enemy_type = type_key
	var data: Dictionary = GameData.ENEMY_TYPES[type_key]
	max_health = data["health"] * difficulty_mult
	health = max_health
	damage = int(data["damage"] * difficulty_mult)
	speed = data["speed"]
	xp_value = data["xp_value"]
	enemy_size = data["size"]
	color = data["color"]
	_behavior = data.get("behavior", "")
	# 机制怪参数
	if _behavior == "charger":
		_charge_damage = int(data.get("charge_damage", 16) * difficulty_mult)
		_charge_speed = data.get("charge_speed", 110.0)
		_charger_state = ChargerState.IDLE
		_charger_state_timer = randf_range(2.0, 4.0)
	elif _behavior == "ranged":
		_retreat_speed = data.get("retreat_speed", 36.0)
		_keep_distance = data.get("keep_distance", 140.0)
		_shoot_interval = data.get("shoot_interval", 2.5)
		_ranged_shoot_timer = randf_range(0.5, _shoot_interval)

	# 机制怪复用 sprite：charger -> zombie；ranged -> skeleton
	var sprite_key: String = type_key
	if _behavior == "charger":
		sprite_key = "zombie"
	elif _behavior == "ranged":
		sprite_key = "skeleton"

	_sprite = Sprite2D.new()
	var sprite_data = GameData.sprites.get(sprite_key)
	if sprite_data is Array and sprite_data.size() > 0:
		_sprite.texture = sprite_data[0]
	elif sprite_data is ImageTexture:
		_sprite.texture = sprite_data
	var sprite_base := 16.0 if sprite_key != "boss" else 24.0
	_sprite.scale = Vector2.ONE * (enemy_size * 2.0 / sprite_base)
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# 常驻 modulate（机制怪有彩色）
	if GameData.MECH_ENEMY_MODULATE.has(type_key):
		_base_modulate = GameData.MECH_ENEMY_MODULATE[type_key]
	elif type_key == "ghost":
		_base_modulate = Color(1, 1, 1, 0.75)
	else:
		_base_modulate = Color.WHITE
	_sprite.modulate = _base_modulate
	add_child(_sprite)

	_anim_timer = randf() * ANIM_SPEED


func setup_elite(type: String) -> void:
	elite_type = type
	match type:
		"berserk":
			speed *= 2.0
			damage = int(damage * 1.5)
			enemy_size *= 1.3
			xp_value *= 3
			if is_instance_valid(_sprite):
				_sprite.scale *= 1.3
		"armored":
			max_health *= 5.0
			health = max_health
			speed *= 0.7
			armor_reduction = 0.5
			xp_value *= 2
		"splitter":
			xp_value *= 2
			if is_instance_valid(_sprite):
				_sprite.modulate.a = 0.8


func setup_rush(target: Vector2) -> void:
	_rush_mode = true
	_rush_target = target


func setup_formation_delay(delay: float) -> void:
	_formation_delay = delay


func apply_formation_debuff(health_mult: float = 0.5, damage_mult: float = 0.5, xp_mult: float = 0.6) -> void:
	max_health = int(max_health * health_mult)
	health = max_health
	damage = maxi(1, int(damage * damage_mult))
	xp_value = maxi(1, int(xp_value * xp_mult))


func _physics_process(delta: float) -> void:
	if _dying:
		return
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return

	if _formation_delay > 0:
		_formation_delay -= delta
		return

	var move_dir: Vector2
	var move_speed: float = speed * _slow_mult

	if _behavior == "charger":
		move_dir = _update_charger(delta, player, move_speed)
	elif _behavior == "ranged":
		move_dir = _update_ranged(delta, player, move_speed)
	elif _rush_mode:
		var to_target := _rush_target - global_position
		if to_target.length() < 30.0:
			_rush_mode = false
			move_dir = (player.global_position - global_position).normalized()
		else:
			move_dir = to_target.normalized()
			move_speed *= _rush_speed_mult
		position += move_dir * move_speed * delta
	else:
		move_dir = (player.global_position - global_position).normalized()
		position += move_dir * move_speed * delta

	SpatialGrid.update_position(self)

	if _slow_timer > 0:
		_slow_timer -= delta
		if _slow_timer <= 0:
			_slow_mult = 1.0

	if is_instance_valid(_sprite):
		_sprite.flip_h = move_dir.x < -0.1

	if _flash_timer > 0:
		_flash_timer -= delta

	_anim_timer += delta
	if _anim_timer >= ANIM_SPEED:
		_anim_timer -= ANIM_SPEED
		_anim_frame = 1 - _anim_frame
		# 机制怪共用 zombie/skeleton sprite
		var anim_key: String = enemy_type
		if _behavior == "charger":
			anim_key = "zombie"
		elif _behavior == "ranged":
			anim_key = "skeleton"
		var anim_data = GameData.sprites.get(anim_key)
		if anim_data is Array and _anim_frame < anim_data.size():
			_sprite.texture = anim_data[_anim_frame]

	if is_instance_valid(_sprite):
		if _flash_timer > 0:
			_sprite.modulate = Color(3, 3, 3)
		elif _slow_mult < 1.0:
			_sprite.modulate = Color(0.5, 0.7, 1.0)
		elif elite_type == "splitter":
			var c := _base_modulate
			c.a = minf(0.8, c.a) if c.a > 0.001 else 0.8
			_sprite.modulate = c
		else:
			_sprite.modulate = _base_modulate

	if elite_type != "":
		_elite_aura_timer += delta

	# 机制怪、有 _draw 内容（charger 预警/标识符、ranged 标识符）需要每帧重绘
	if _flash_timer > 0 or elite_type != "" or health < max_health or _behavior != "":
		queue_redraw()


# 冲锋怪：状态机 IDLE → WARNING → CHARGING → COOLDOWN
func _update_charger(delta: float, player: Node2D, base_speed: float) -> Vector2:
	var to_player: Vector2 = player.global_position - global_position
	var move_dir: Vector2 = to_player.normalized()
	_charger_state_timer -= delta

	match _charger_state:
		ChargerState.IDLE:
			# 普通追击；CD 到了切到 WARNING
			position += move_dir * base_speed * delta
			if _charger_state_timer <= 0:
				_charger_state = ChargerState.WARNING
				_charger_state_timer = 0.9
				_charger_charge_dir = move_dir
		ChargerState.WARNING:
			# 站住预警（红色闪烁）；预警结束开始冲刺
			if _charger_state_timer <= 0:
				_charger_state = ChargerState.CHARGING
				_charger_state_timer = 1.6
				_charger_charge_dist = 0.0
				_charger_charge_dir = move_dir
		ChargerState.CHARGING:
			var cspd: float = _charge_speed * _slow_mult
			var step: float = cspd * delta
			position += _charger_charge_dir * step
			_charger_charge_dist += step
			# 命中判定：途中触碰玩家
			if global_position.distance_to(player.global_position) < player.hit_radius + enemy_size:
				if not player.invincible:
					player.take_damage(_charge_damage)
					player.apply_knockback(_charger_charge_dir * 100.0)
				_charger_state = ChargerState.COOLDOWN
				_charger_state_timer = 3.5
			# 距离到了或超时：扑空回 COOLDOWN
			elif _charger_charge_dist >= 180.0 or _charger_state_timer <= 0:
				_charger_state = ChargerState.COOLDOWN
				_charger_state_timer = 3.0  # 扑空后 CD
		ChargerState.COOLDOWN:
			# 普通追击
			position += move_dir * base_speed * delta
			if _charger_state_timer <= 0:
				_charger_state = ChargerState.IDLE
				_charger_state_timer = randf_range(2.5, 4.0)
	return move_dir


# 远程怪：保持距离 + 低频弹幕；被追近后撤
func _update_ranged(delta: float, player: Node2D, _base_speed: float) -> Vector2:
	var to_player: Vector2 = player.global_position - global_position
	var d: float = to_player.length()
	var move_dir: Vector2 = to_player.normalized() if d > 0.01 else Vector2.RIGHT
	# 距离 < 80：后撤；80-120：靠近；120-160：停下射击；>160：靠近
	if d < 80.0:
		# 后撤；如果接近屏幕边缘则停下原地射击（PRD 5.10.4 v0.6）
		if not _is_near_screen_edge():
			position -= move_dir * _retreat_speed * delta * _slow_mult
	elif d < 120.0:
		# 速度慢移
		position += move_dir * speed * 0.5 * delta * _slow_mult
	elif d > 160.0:
		# 靠近
		position += move_dir * speed * delta * _slow_mult

	# 射击计时
	_ranged_shoot_timer -= delta
	if _ranged_shoot_timer <= 0 and d < 320.0:
		_ranged_shoot_timer = _shoot_interval
		_shoot_at(player)

	return move_dir


func _is_near_screen_edge() -> bool:
	var camera := get_viewport().get_camera_2d()
	if not camera:
		return false
	var vp_size: Vector2 = get_viewport().get_visible_rect().size
	var cam_pos: Vector2 = camera.global_position
	var local: Vector2 = global_position - cam_pos
	var margin: float = 100.0
	return abs(local.x) > vp_size.x * 0.5 - margin or abs(local.y) > vp_size.y * 0.5 - margin


func _shoot_at(player: Node2D) -> void:
	var container := GameData.enemies_container
	if not container or not is_instance_valid(container):
		return
	var dir: Vector2 = (player.global_position - global_position).normalized()
	var proj := Node2D.new()
	proj.set_script(preload("res://scripts/weapons/enemy_projectile.gd"))
	proj.direction = dir
	proj.proj_speed = 180.0
	proj.proj_damage = damage
	proj.proj_color = _base_modulate
	proj.global_position = global_position + dir * (enemy_size + 4.0)
	container.add_child(proj)
	AudioManager.play("enemy_hit")


func _draw() -> void:
	var reduce_detail: bool = GameData.should_reduce_enemy_detail()
	var player := GameData.player_ref
	var far_from_player := false
	if is_instance_valid(player):
		far_from_player = global_position.distance_squared_to(player.global_position) > 520.0 * 520.0

	if elite_type != "" and not _dying and not (reduce_detail and far_from_player):
		_draw_elite_aura()

	# 冲锋怪预警：WARNING 阶段红色闪烁圆环
	if _behavior == "charger" and _charger_state == ChargerState.WARNING:
		var pulse: float = (sin(Time.get_ticks_msec() * 0.025) + 1.0) * 0.5
		draw_arc(Vector2.ZERO, enemy_size * 1.6, 0.0, TAU, 24,
			Color(1.0, 0.2, 0.1, 0.5 + pulse * 0.4), 2.0)
		# 冲刺方向预警箭头
		var arrow_end: Vector2 = _charger_charge_dir * (enemy_size * 2.0)
		draw_line(Vector2.ZERO, arrow_end, Color(1.0, 0.3, 0.1, 0.85), 2.5)

	# 机制怪头顶标识符
	if _behavior == "charger":
		_draw_marker_exclamation()
	elif _behavior == "ranged":
		_draw_marker_bow()

	if health < max_health and not _dying and not (reduce_detail and elite_type == "" and far_from_player):
		var bar_w := enemy_size * 2.0
		var bar_h := 3.0
		var bar_y := -enemy_size - 6.0
		if elite_type != "":
			bar_h = 4.0
			bar_y -= 2.0
		draw_rect(Rect2(-bar_w / 2, bar_y, bar_w, bar_h), Color(0.08, 0.08, 0.12, 0.8))
		var fill_w := bar_w * (health / max_health)
		var bar_color := Color(0.85, 0.2, 0.2)
		if elite_type != "":
			bar_color = ELITE_AURA_COLORS.get(elite_type, bar_color)
			bar_color.a = 1.0
		draw_rect(Rect2(-bar_w / 2, bar_y, fill_w, bar_h), bar_color)


func _draw_marker_exclamation() -> void:
	# 红色感叹号（高 4px，距头顶 6px）
	var top_y: float = -enemy_size - 6.0
	var c := Color(1.0, 0.25, 0.15, 0.95)
	draw_rect(Rect2(-1.0, top_y - 4.0, 2.0, 3.0), c)
	draw_rect(Rect2(-1.0, top_y, 2.0, 1.0), c)


func _draw_marker_bow() -> void:
	# 紫色弓箭符号（简化为三角箭头）
	var top_y: float = -enemy_size - 6.0
	var c := Color(0.7, 0.4, 1.0, 0.95)
	var pts := PackedVector2Array([
		Vector2(0, top_y - 4.0),
		Vector2(-3.0, top_y),
		Vector2(3.0, top_y),
	])
	draw_colored_polygon(pts, c)


func _draw_elite_aura() -> void:
	var aura_color: Color = ELITE_AURA_COLORS.get(elite_type, Color.WHITE)
	var pulse: float = 0.3 + (sin(_elite_aura_timer * 3.0) + 1.0) * 0.2
	aura_color.a = pulse
	var radius: float = enemy_size * 1.6
	draw_circle(Vector2.ZERO, radius, aura_color)
	var ring_color := aura_color
	ring_color.a = pulse * 0.6
	var segments := 16
	for i in range(segments):
		var a1: float = TAU * float(i) / float(segments)
		var a2: float = TAU * float(i + 1) / float(segments)
		var p1 := Vector2(cos(a1), sin(a1)) * radius
		var p2 := Vector2(cos(a2), sin(a2)) * radius
		draw_line(p1, p2, ring_color, 1.5)


func take_damage(amount: float) -> void:
	if _dying:
		return
	var effective_amount := amount
	if armor_reduction > 0:
		effective_amount *= (1.0 - armor_reduction)
	health -= effective_amount
	_flash_timer = 0.08
	AudioManager.play("enemy_hit")
	# 普通命中 hit_flash size 砍到 8（PRD 5.9.2）；暴击/精英命中保留原强度
	var is_crit: bool = amount >= 20
	if not GameData.is_low_fx_mode() or elite_type != "" or is_crit:
		var flash_size: float
		if is_crit or elite_type != "":
			flash_size = 10.0 + amount * 0.3
		else:
			flash_size = 6.0 + amount * 0.2
		VfxPool.hit_flash(global_position, color, flash_size)
	if health <= 0:
		_die()


func apply_slow(mult: float, duration: float) -> void:
	_slow_mult = minf(_slow_mult, mult)
	_slow_timer = maxf(_slow_timer, duration)


func apply_knockback(force: Vector2) -> void:
	position += force


func _die() -> void:
	_dying = true
	SpatialGrid.unregister(self)
	remove_from_group("enemies")
	GameData.total_kills += 1
	if enemy_type == "boss":
		GameData.boss_kills_this_stage += 1
	var p = GameData.player_ref
	if is_instance_valid(p) and p.has_method("on_enemy_killed"):
		p.on_enemy_killed()
		if p.has_method("spawn_soul_drain_visual"):
			p.spawn_soul_drain_visual(global_position)
	AudioManager.play("enemy_die")

	if elite_type != "":
		VfxPool.spark_burst(global_position, 16, color, 150.0, 0.6)
		VfxPool.ring_wave(global_position, color, enemy_size * 4.0, 0.4)
	else:
		VfxPool.spark_burst(global_position, 8, color, 100.0, 0.4)
		VfxPool.ring_wave(global_position, color, enemy_size * 3.0, 0.25)

	_spawn_gem()
	_try_spawn_chest()

	if elite_type == "splitter":
		_spawn_split_children()

	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	tween.tween_callback(queue_free)


func _spawn_split_children() -> void:
	var container := GameData.enemies_container
	if not container or not is_instance_valid(container):
		return
	for i in range(3):
		var child := Node2D.new()
		child.set_script(preload("res://scripts/enemy.gd"))
		var angle: float = TAU * float(i) / 3.0
		child.global_position = global_position + Vector2(cos(angle), sin(angle)) * 20.0
		container.add_child(child)
		var diff: float = max_health / (GameData.ENEMY_TYPES[enemy_type]["health"] * 5.0)
		child.setup(enemy_type, diff * 0.5)
		child.enemy_size *= 0.7
		if is_instance_valid(child._sprite):
			child._sprite.scale *= 0.7


func _spawn_gem() -> void:
	var gem_script := preload("res://scripts/experience_gem.gd")
	var gem := Node2D.new()
	gem.set_script(gem_script)
	gem.global_position = global_position
	gem.xp_value = xp_value
	var container := GameData.pickups_container
	if container and is_instance_valid(container):
		container.add_child(gem)


func _try_spawn_chest() -> void:
	var base_chance: float
	if enemy_type == "boss":
		base_chance = GameData.CHEST_DROP_CHANCE_BOSS
	elif elite_type == "armored":
		base_chance = 1.0
	elif elite_type != "":
		base_chance = 0.15
	else:
		base_chance = GameData.CHEST_DROP_CHANCE_NORMAL
	if randf() > base_chance:
		return
	var chest_script := preload("res://scripts/treasure_chest.gd")
	var chest := Node2D.new()
	chest.set_script(chest_script)
	chest.global_position = global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
	chest.setup_random()
	if enemy_type == "boss":
		if randf() < 0.6:
			chest.rarity = chest_script.ChestRarity.EPIC
		else:
			chest.rarity = chest_script.ChestRarity.RARE
	elif elite_type == "armored":
		chest.rarity = chest_script.ChestRarity.RARE
	var container := GameData.pickups_container
	if container and is_instance_valid(container):
		container.add_child(chest)
		AudioManager.play("chest_spawn")
