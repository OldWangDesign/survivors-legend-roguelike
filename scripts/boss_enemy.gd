extends Node2D

signal boss_died(boss_id: String)

var boss_id: String = "bone_lord"
var health: float = 500.0
var max_health: float = 500.0
var damage: int = 20
var speed: float = 35.0
var xp_value: int = 100
var enemy_size: float = 28.0
var color: Color = Color(0.9, 0.1, 0.1)
var enemy_type: String = "boss"

var _flash_timer: float = 0.0
var _dying: bool = false
var _slow_mult: float = 1.0
var _slow_timer: float = 0.0
var _sprite: Sprite2D
var _anim_frame: int = 0
var _anim_timer: float = 0.0
const ANIM_SPEED := 0.4

# 登场演出（PRD 5.5.2）：3.2s 总时长
const ENTER_DURATION := 3.2
const ENTER_TITLE_TIME := 2.0      # 名称显示时刻
const ENTER_DARKEN_TIME := 1.5     # 屏幕变暗时刻
const ENTER_SHOCKWAVE_TIME := 3.2  # 到位释放冲击波

var _enraged: bool = false
var _enrage_pause_timer: float = 0.0  # 50% 狂暴暂停
var _undying_pause_timer: float = 0.0 # undying 暂停
var _skill_timers: Dictionary = {}
var _skill_cooldowns: Dictionary = {}
var _entering: bool = true
var _enter_timer: float = ENTER_DURATION
var _enter_start_pos: Vector2
var _enter_target_pos: Vector2
var _enter_title_shown: bool = false
var _enter_darken_shown: bool = false
var _enter_shockwave_done: bool = false
var _enter_overlay: ColorRect = null

var _undying_triggered: bool = false
var _aura_rotation: float = 0.0

# Pending skill warnings/animations
var _pending_skills: Array = []  # array of dicts: {fn: Callable, time: float, ...}


func _ready() -> void:
	add_to_group("enemies")
	add_to_group("bosses")
	SpatialGrid.register(self)
	z_index = GameData.Z_BOSS


func setup_boss(id: String, difficulty_mult: float = 1.0) -> void:
	boss_id = id
	var data: Dictionary = GameData.BOSS_DATA.get(id, {})
	if data.is_empty():
		data = GameData.BOSS_DATA["bone_lord"]
		boss_id = "bone_lord"

	var base_hp: float = GameData.ENEMY_TYPES["boss"]["health"]
	max_health = base_hp * data.get("health_mult", 2.5) * difficulty_mult
	health = max_health
	var raw_dmg := int(GameData.ENEMY_TYPES["boss"]["damage"] * data.get("damage_mult", 2.0) * sqrt(difficulty_mult))
	var cap: int = data.get("damage_cap", 28)
	damage = mini(raw_dmg, cap)
	speed = data.get("speed", 75.0)
	enemy_size = data.get("size", 28.0)
	xp_value = int(100.0 * data.get("health_mult", 2.5) / 2.5 * difficulty_mult)
	color = data.get("color", Color(0.9, 0.1, 0.1))

	var skills: Array = data.get("skills", [])
	for sk_name in skills:
		var cd: float = _get_skill_base_cooldown(sk_name)
		_skill_cooldowns[sk_name] = cd
		# 让首发时机错开（避免登场后立刻全技能爆发）
		_skill_timers[sk_name] = cd * 0.5

	_sprite = Sprite2D.new()
	# 按 boss_id 取专属 sprite，找不到再回落到通用 "boss"
	var sprite_data = GameData.sprites.get("boss_" + boss_id)
	if sprite_data == null:
		sprite_data = GameData.sprites.get("boss")
	if sprite_data is Array and sprite_data.size() > 0:
		_sprite.texture = sprite_data[0]
	elif sprite_data is ImageTexture:
		_sprite.texture = sprite_data
	_sprite.scale = Vector2.ONE * (enemy_size * 2.0 / 24.0)
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_sprite)

	_anim_timer = randf() * ANIM_SPEED
	_entering = true
	_enter_timer = ENTER_DURATION
	_enter_title_shown = false
	_enter_darken_shown = false
	_enter_shockwave_done = false


func _get_skill_base_cooldown(skill_name: String) -> float:
	match skill_name:
		"bone_spike": return 6.0
		"summon_skeleton": return 10.0
		"charge": return 8.0
		"soul_barrage": return 5.0
		"phantom_split": return 15.0
		"dark_field": return 12.0
		"moon_wrath": return 15.0
		"summon_elite": return 20.0
		"undying": return 999.0
	return 8.0


func _physics_process(delta: float) -> void:
	if _dying:
		return

	_aura_rotation += delta

	# 登场期：演出推进 + 不可受击 + 不接触伤害
	if _entering:
		_update_entering(delta)
		queue_redraw()
		return

	# 处理已激活技能的延迟阶段（蓄力、预警延迟等）
	_process_pending_skills(delta)

	# 狂暴/undying 暂停期间冻结主行为
	if _enrage_pause_timer > 0:
		_enrage_pause_timer -= delta
		queue_redraw()
		return
	if _undying_pause_timer > 0:
		_undying_pause_timer -= delta
		queue_redraw()
		return

	var player := GameData.player_ref
	if not is_instance_valid(player):
		return

	var dir := (player.global_position - global_position).normalized()
	position += dir * speed * _slow_mult * delta

	# 软推开：玩家不能站进 Boss 身体里（PRD 5.5.4）
	if is_instance_valid(player):
		var to_player := player.global_position - global_position
		var min_dist: float = enemy_size + player.hit_radius
		var d := to_player.length()
		if d < min_dist and d > 0.01:
			var push := to_player.normalized() * (min_dist - d)
			player.global_position += push

	SpatialGrid.update_position(self)

	if is_instance_valid(_sprite):
		_sprite.flip_h = dir.x < -0.1

	if _slow_timer > 0:
		_slow_timer -= delta
		if _slow_timer <= 0:
			_slow_mult = 1.0

	if _flash_timer > 0:
		_flash_timer -= delta

	_anim_timer += delta
	if _anim_timer >= ANIM_SPEED:
		_anim_timer -= ANIM_SPEED
		_anim_frame = 1 - _anim_frame
		var anim_data = GameData.sprites.get("boss_" + boss_id)
		if anim_data == null:
			anim_data = GameData.sprites.get("boss")
		if anim_data is Array and _anim_frame < anim_data.size():
			_sprite.texture = anim_data[_anim_frame]

	if is_instance_valid(_sprite):
		if _flash_timer > 0:
			_sprite.modulate = Color(3, 3, 3)
		elif _slow_mult < 1.0:
			_sprite.modulate = Color(0.5, 0.7, 1.0)
		elif _enraged:
			var pulse: float = (sin(Time.get_ticks_msec() * 0.01) + 1.0) * 0.5
			_sprite.modulate = Color(1.0, 0.6 + pulse * 0.4, 0.6 + pulse * 0.4)
		else:
			_sprite.modulate = Color.WHITE

	if not health <= 0:
		_check_enrage()
		_update_skills(delta)

	queue_redraw()


func _update_entering(delta: float) -> void:
	_enter_timer -= delta
	var elapsed: float = ENTER_DURATION - _enter_timer

	# 1.5s：屏幕变暗（半透明遮罩）
	if not _enter_darken_shown and elapsed >= ENTER_DARKEN_TIME:
		_enter_darken_shown = true
		_show_enter_overlay()

	# 2.0s：Boss 名称大字
	if not _enter_title_shown and elapsed >= ENTER_TITLE_TIME:
		_enter_title_shown = true
		var data: Dictionary = GameData.BOSS_DATA.get(boss_id, {})
		var bname: String = data.get("name", "Boss")
		_show_boss_name_banner(bname)

	# 在登场窗口内，沿 lerp 移动 Boss
	if _enter_timer > 0:
		var t: float = clampf(elapsed / ENTER_DURATION, 0.0, 1.0)
		# 用 ease-in-out 让最后一段更稳
		var ease_t: float = t * t * (3.0 - 2.0 * t)
		global_position = _enter_start_pos.lerp(_enter_target_pos, ease_t)
		SpatialGrid.update_position(self)

	# 3.2s 到位：释放冲击波，演出结束
	if _enter_timer <= 0 and not _enter_shockwave_done:
		_enter_shockwave_done = true
		_entering = false
		VfxPool.ring_wave(global_position, color, enemy_size * 5.0, 0.5, 4.0)
		VfxPool.ring_wave(global_position, GameData.UI_GOLD, enemy_size * 3.0, 0.35, 2.0)
		VfxPool.screen_flash(Color(color.r, color.g, color.b, 0.18), 0.2)
		_hide_enter_overlay()


func _show_enter_overlay() -> void:
	var scene := get_tree().current_scene
	if not scene:
		return
	var layer := CanvasLayer.new()
	layer.layer = GameData.Z_BANNER - 1
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	scene.add_child(layer)
	_enter_overlay = ColorRect.new()
	_enter_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_enter_overlay.color = Color(0, 0, 0, 0)
	_enter_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_enter_overlay)
	var tw := _enter_overlay.create_tween()
	tw.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tw.tween_property(_enter_overlay, "color:a", 0.3, 0.3)


func _hide_enter_overlay() -> void:
	if not is_instance_valid(_enter_overlay):
		return
	var ov := _enter_overlay
	_enter_overlay = null
	var tw := ov.create_tween()
	tw.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tw.tween_property(ov, "color:a", 0.0, 0.4)
	tw.tween_callback(func() -> void:
		var parent := ov.get_parent()
		if is_instance_valid(parent):
			parent.queue_free()
	)


func _show_boss_name_banner(bname: String) -> void:
	var scene := get_tree().current_scene
	if not scene:
		return
	var layer := CanvasLayer.new()
	layer.layer = GameData.Z_BANNER
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	scene.add_child(layer)

	var vp_size: Vector2 = scene.get_viewport().get_visible_rect().size
	var center := Control.new()
	center.position = vp_size * 0.5
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(center)

	var lbl := Label.new()
	lbl.text = bname
	lbl.add_theme_font_size_override("font_size", 64)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	lbl.add_theme_constant_override("shadow_offset_x", 3)
	lbl.add_theme_constant_override("shadow_offset_y", 3)
	lbl.add_theme_constant_override("outline_size", 4)
	lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.95))
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.size = Vector2(vp_size.x, 80.0)
	lbl.position = Vector2(-vp_size.x * 0.5, -40.0)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(lbl)

	center.scale = Vector2(0.5, 0.5)
	var tw := center.create_tween()
	tw.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tw.tween_property(center, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(1.2)
	tw.tween_property(center, "modulate:a", 0.0, 0.4)
	tw.tween_callback(func() -> void:
		if is_instance_valid(layer):
			layer.queue_free()
	)


func _check_enrage() -> void:
	if _enraged:
		return
	if health <= max_health * 0.5:
		_enraged = true
		# 0.5s 暂停 + 红闪 + 放大弹回 + 大冲击波 + 横幅
		_enrage_pause_timer = 0.5
		speed *= 1.3
		for sk in _skill_cooldowns:
			_skill_cooldowns[sk] *= 0.7
		VfxPool.screen_flash(Color(0.95, 0.1, 0.1, 0.32), 0.25)
		# 子 sprite 缩放 1.3 后弹回（不改 hit_radius）
		if is_instance_valid(_sprite):
			var base_scale: Vector2 = _sprite.scale
			var tw := _sprite.create_tween()
			tw.tween_property(_sprite, "scale", base_scale * 1.3, 0.15).set_trans(Tween.TRANS_BACK)
			tw.tween_property(_sprite, "scale", base_scale, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		# 大冲击波
		_pending_skills.append({"fn": "_enrage_shockwave", "time": 0.2})
		_show_banner("Boss 狂暴！", Color(0.95, 0.2, 0.2), 1.5)
		AudioManager.play("level_up")


func _enrage_shockwave() -> void:
	VfxPool.ring_wave(global_position, Color(1.0, 0.3, 0.1), enemy_size * 8.0, 0.6, 5.0)
	VfxPool.ring_wave(global_position, Color(1.0, 0.6, 0.2, 0.8), enemy_size * 5.0, 0.45, 3.0)


func _show_banner(text: String, color: Color, duration: float = 1.5) -> void:
	for hud in get_tree().get_nodes_in_group("hud"):
		if hud.has_method("show_banner"):
			hud.show_banner(text, color, duration)
			return
		elif hud.has_method("show_reward_notice"):
			hud.show_reward_notice(text, color, duration)
			return


func _update_skills(delta: float) -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return

	for sk_name in _skill_timers.keys():
		_skill_timers[sk_name] -= delta
		if _skill_timers[sk_name] <= 0:
			_skill_timers[sk_name] = _skill_cooldowns[sk_name]
			_use_skill(sk_name)


func _process_pending_skills(delta: float) -> void:
	if _pending_skills.is_empty():
		return
	var remaining: Array = []
	for entry in _pending_skills:
		entry["time"] -= delta
		if entry["time"] <= 0:
			var fn_name: String = entry.get("fn", "")
			match fn_name:
				"_enrage_shockwave":
					_enrage_shockwave()
				"_bone_spike_fire":
					_bone_spike_fire(entry.get("dir", Vector2.RIGHT))
				"_summon_skeleton_fire":
					_summon_skeleton_fire(entry.get("positions", []))
				"_phantom_split_fire":
					_phantom_split_fire()
				"_summon_elite_fire":
					_summon_elite_fire(entry.get("positions", []))
				"_moon_wrath_fire":
					_moon_wrath_fire()
				"_undying_fire":
					_undying_fire()
		else:
			remaining.append(entry)
	_pending_skills = remaining


func _use_skill(skill_name: String) -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return

	match skill_name:
		"bone_spike":
			_skill_bone_spike(player)
		"summon_skeleton":
			_skill_summon_skeleton()
		"charge":
			_skill_charge(player)
		"soul_barrage":
			_skill_soul_barrage(player)
		"phantom_split":
			_skill_phantom_split()
		"dark_field":
			_skill_dark_field()
		"moon_wrath":
			_skill_moon_wrath()
		"summon_elite":
			_skill_summon_elites()
		"undying":
			_skill_undying()


# ============ 技能实现 ============

func _skill_bone_spike(player: CharacterBody2D) -> void:
	var dir := (player.global_position - global_position).normalized()
	# 0.4s 地面裂纹预警（红色虚线）
	VfxPool.line_attack(global_position, dir, 300.0, 40.0, Color(1.0, 0.2, 0.1, 0.55), 0.4)
	_pending_skills.append({"fn": "_bone_spike_fire", "time": 0.4, "dir": dir})


func _bone_spike_fire(dir: Vector2) -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return
	# 实际骨刺：白色亮线 + 命中判定
	VfxPool.line_attack(global_position, dir, 300.0, 40.0, Color(0.95, 0.9, 0.7), 0.6)
	var dist := global_position.distance_to(player.global_position)
	if dist < 300.0:
		var perp := Vector2(-dir.y, dir.x)
		var perp_dist := absf((player.global_position - global_position).dot(perp))
		if perp_dist < 40.0:
			player.take_damage(damage)


func _skill_summon_skeleton() -> void:
	# 0.6s 预警 3 个生成位置（绿色虚线圆）
	var positions: Array = []
	for i in range(3):
		var angle: float = TAU * float(i) / 3.0 + randf() * 0.4
		var pos: Vector2 = global_position + Vector2(cos(angle), sin(angle)) * 60.0
		positions.append(pos)
		VfxPool.ring_wave(pos, Color(0.4, 1.0, 0.3, 0.6), 28.0, 0.6, 2.0)
	# Boss 脚下白色召唤法阵（用 ring_wave 替代）
	VfxPool.ring_wave(global_position, Color(0.95, 0.9, 0.7, 0.7), enemy_size * 1.5, 0.5, 2.5)
	_pending_skills.append({"fn": "_summon_skeleton_fire", "time": 0.6, "positions": positions})


func _summon_skeleton_fire(positions: Array) -> void:
	var container := GameData.enemies_container
	if not container or not is_instance_valid(container):
		return
	for pos in positions:
		# 生成位置爆白色骨片 spark
		VfxPool.spark_burst(pos, 12, Color(0.95, 0.9, 0.7), 80.0, 0.4)
		var minion := Node2D.new()
		minion.set_script(preload("res://scripts/enemy.gd"))
		minion.global_position = pos
		container.add_child(minion)
		var diff: float = max_health / (GameData.ENEMY_TYPES["boss"]["health"] * 2.5)
		minion.setup("skeleton", diff)
		# 弹入动画：scale 0 -> 1
		minion.scale = Vector2.ZERO
		var tw := minion.create_tween()
		tw.tween_property(minion, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK)


func _skill_charge(player: CharacterBody2D) -> void:
	var dir := (player.global_position - global_position).normalized()
	var charge_tween := create_tween()
	var target_pos := global_position + dir * 250.0
	charge_tween.tween_property(self, "global_position", target_pos, 0.3).set_trans(Tween.TRANS_BACK)
	# 残影：3-4 个渐隐 Boss 影像
	for i in range(4):
		var t: float = float(i) / 4.0
		var ghost_pos: Vector2 = global_position.lerp(target_pos, t)
		_spawn_charge_ghost(ghost_pos, t)
	VfxPool.spark_burst(global_position, 6, Color(0.8, 0.2, 0.2), 80.0, 0.3)

	var dist := global_position.distance_to(player.global_position)
	if dist < 80.0:
		player.take_damage(int(damage * 1.2))
		player.apply_knockback(dir * 200.0)


func _spawn_charge_ghost(pos: Vector2, t: float) -> void:
	if not is_instance_valid(_sprite) or not _sprite.texture:
		return
	var scene := get_tree().current_scene
	if not scene:
		return
	var ghost := Sprite2D.new()
	ghost.texture = _sprite.texture
	ghost.scale = _sprite.scale
	ghost.global_position = pos
	ghost.modulate = Color(color.r, color.g, color.b, 0.4 - t * 0.3)
	ghost.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ghost.z_index = GameData.Z_BOSS - 1
	scene.add_child(ghost)
	var tw := ghost.create_tween()
	tw.tween_property(ghost, "modulate:a", 0.0, 0.4)
	tw.tween_callback(ghost.queue_free)


func _skill_soul_barrage(player: CharacterBody2D) -> void:
	var base_dir := (player.global_position - global_position).normalized()
	for i in range(5):
		var angle_offset: float = (float(i) - 2.0) * 0.15
		var dir := base_dir.rotated(angle_offset)
		var proj := _create_boss_projectile(dir, 150.0, int(damage * 0.3))
		proj.global_position = global_position + dir * 20.0
		# 短拖尾（3-4 帧）
		if proj:
			VfxPool.trail_attach(proj, color.lightened(0.3), 4, 3.0)
	AudioManager.play("enemy_hit")


func _skill_phantom_split() -> void:
	# 0.8s 蓄力：暗能量向内汇聚（用 ring_wave 模拟）
	VfxPool.ring_wave(global_position, Color(0.5, 0.3, 0.8, 0.4), enemy_size * 2.5, 0.8, 2.5)
	VfxPool.ring_wave(global_position, Color(0.7, 0.4, 1.0, 0.5), enemy_size * 1.7, 0.7, 2.0)
	_pending_skills.append({"fn": "_phantom_split_fire", "time": 0.8})


func _phantom_split_fire() -> void:
	# 闪烁 + 紫色细线射向分身位置 + 分身淡入
	VfxPool.screen_flash(Color(0.6, 0.3, 0.9, 0.18), 0.15)
	var container := GameData.enemies_container
	if not container or not is_instance_valid(container):
		return
	for i in range(2):
		var angle: float = TAU * float(i) / 2.0 + randf() * 0.5
		var offset := Vector2(cos(angle), sin(angle)) * 80.0
		var dst := global_position + offset
		VfxPool.line_attack(global_position, offset.normalized(), offset.length(), 6.0, Color(0.7, 0.4, 1.0, 0.8), 0.3)
		var phantom := Node2D.new()
		phantom.set_script(preload("res://scripts/enemy.gd"))
		phantom.global_position = dst
		container.add_child(phantom)
		phantom.setup("ghost", max_health / (GameData.ENEMY_TYPES["ghost"]["health"] * 3.0))
		phantom.enemy_size = enemy_size * 0.8
		if is_instance_valid(phantom._sprite):
			phantom._sprite.scale *= 1.5
			phantom._sprite.modulate.a = 0.0
			# alpha 0->0.5 淡入 0.4s
			var tw: Tween = phantom._sprite.create_tween()
			tw.tween_property(phantom._sprite, "modulate:a", 0.5, 0.4)
		VfxPool.spark_burst(dst, 8, Color(0.6, 0.3, 0.9), 80.0, 0.5)


func _skill_dark_field() -> void:
	# 持续可见的紫色半透明区域：在场景里生成一个 dark_field 节点
	var scene := get_tree().current_scene
	if not scene:
		return
	var field := Node2D.new()
	field.set_script(preload("res://scripts/world/dark_field_zone.gd"))
	field.global_position = global_position
	field.set("zone_radius", 120.0)
	field.set("life_time", 4.0)
	scene.add_child(field)
	VfxPool.ring_wave(global_position, Color(0.2, 0.0, 0.3, 0.8), 120.0, 0.4, 4.0)


func _skill_moon_wrath() -> void:
	# 1s 蓄力（Boss 缩小再膨胀 + 地面预警圆）
	if is_instance_valid(_sprite):
		var base_scale: Vector2 = _sprite.scale
		var tw := _sprite.create_tween()
		tw.tween_property(_sprite, "scale", base_scale * 0.8, 0.4).set_trans(Tween.TRANS_SINE)
		tw.tween_property(_sprite, "scale", base_scale * 1.15, 0.4).set_trans(Tween.TRANS_BACK)
		tw.tween_property(_sprite, "scale", base_scale, 0.2)
	VfxPool.ring_wave(global_position, Color(1.0, 0.1, 0.1, 0.55), 300.0, 1.0, 4.0)
	# 安全区指示
	VfxPool.ring_wave(global_position, Color(0.2, 1.0, 0.3, 0.4), 80.0, 1.0, 3.0)
	_pending_skills.append({"fn": "_moon_wrath_fire", "time": 1.0})


func _moon_wrath_fire() -> void:
	VfxPool.screen_flash(Color(0.85, 0.1, 0.1, 0.22), 0.3)
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return
	if player.global_position.distance_to(global_position) > 80.0:
		player.take_damage(int(damage * 1.2))
	VfxPool.ring_wave(global_position, Color(0.95, 0.1, 0.1), 300.0, 0.5, 5.0)


func _skill_summon_elites() -> void:
	# 0.8s 暗红血池预警
	var positions: Array = []
	for i in range(2):
		var angle: float = TAU * float(i) / 2.0
		var pos: Vector2 = global_position + Vector2(cos(angle), sin(angle)) * 60.0
		positions.append(pos)
		VfxPool.ring_wave(pos, Color(0.6, 0.05, 0.1, 0.7), 32.0, 0.8, 3.0)
	VfxPool.screen_flash(Color(0.7, 0.05, 0.1, 0.18), 0.15)
	_pending_skills.append({"fn": "_summon_elite_fire", "time": 0.8, "positions": positions})


func _summon_elite_fire(positions: Array) -> void:
	var container := GameData.enemies_container
	if not container or not is_instance_valid(container):
		return
	var elite_types := ["berserk", "armored"]
	var types := ["skeleton", "zombie", "ghost"]
	for i in range(positions.size()):
		var pos: Vector2 = positions[i]
		VfxPool.spark_burst(pos, 14, Color(0.7, 0.05, 0.1), 100.0, 0.5)
		var minion := Node2D.new()
		minion.set_script(preload("res://scripts/enemy.gd"))
		minion.global_position = pos
		container.add_child(minion)
		var diff: float = max_health / (GameData.ENEMY_TYPES["boss"]["health"] * 2.5)
		minion.setup(types[i % types.size()], diff)
		minion.setup_elite(elite_types[i % elite_types.size()])
		# scale 0 + alpha 0 升起 0.5s
		minion.scale = Vector2.ZERO
		minion.modulate.a = 0.0
		var tw := minion.create_tween()
		tw.set_parallel(true)
		tw.tween_property(minion, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK)
		tw.tween_property(minion, "modulate:a", 1.0, 0.5)


func _skill_undying() -> void:
	if _undying_triggered:
		return
	if health <= max_health * 0.3:
		_undying_triggered = true
		health = max_health * 0.5
		# 第二阶段转换演出（PRD 5.5.6 #9）
		_undying_pause_timer = 0.8
		_show_enter_overlay()  # 屏幕变暗（复用登场遮罩）
		# 0.8s 后真正释放
		_pending_skills.append({"fn": "_undying_fire", "time": 0.8})


func _undying_fire() -> void:
	_hide_enter_overlay()
	# Boss 升空（短暂位移）+ 红色光柱（用 line_attack 模拟从地面射入 Boss）
	VfxPool.line_attack(global_position + Vector2(0, 200), Vector2(0, -1), 200.0, 30.0, Color(1.0, 0.1, 0.1, 0.85), 0.6)
	VfxPool.line_attack(global_position + Vector2(0, 200), Vector2(0, -1), 200.0, 18.0, Color(1.0, 0.4, 0.3, 0.95), 0.6)
	VfxPool.screen_flash(Color(0.9, 0.05, 0.1, 0.4), 0.5)
	VfxPool.ring_wave(global_position, Color(1.0, 0.0, 0.0), enemy_size * 8.0, 0.8, 6.0)
	VfxPool.ring_wave(global_position, Color(1.0, 0.4, 0.2), enemy_size * 5.0, 0.6, 4.0)
	# 二次狂暴 buff
	speed *= 1.2
	for sk in _skill_cooldowns:
		_skill_cooldowns[sk] *= 0.8
	# 横幅
	_show_banner("血月之力觉醒！", Color(0.7, 0.0, 0.05), 1.8)
	AudioManager.play("level_up")


func _create_boss_projectile(dir: Vector2, spd: float, dmg: int) -> Node2D:
	var proj := Node2D.new()
	proj.set_script(preload("res://scripts/boss_projectile.gd"))
	proj.direction = dir
	proj.proj_speed = spd
	proj.proj_damage = dmg
	proj.proj_color = color
	var container := GameData.enemies_container
	if container and is_instance_valid(container):
		container.add_child(proj)
	return proj


# ============ 光环绘制（PRD 5.5.5 专属光环） ============

func _draw() -> void:
	if _dying:
		return

	_draw_signature_aura()

	if _entering:
		var enter_alpha: float = 1.0 - clampf(_enter_timer / ENTER_DURATION, 0.0, 1.0)
		var warn_color := Color(color.r, color.g, color.b, (1.0 - enter_alpha) * 0.45)
		# 全身发光描边
		draw_circle(Vector2.ZERO, enemy_size * 1.6, warn_color)
		var rim := Color(color.r * 1.2, color.g * 1.2, color.b * 1.2, 0.7 * (1.0 - enter_alpha))
		draw_arc(Vector2.ZERO, enemy_size * 1.7, 0.0, TAU, 40, rim, 3.5)


func _draw_signature_aura() -> void:
	var pulse: float = (sin(Time.get_ticks_msec() * 0.003) + 1.0) * 0.5
	var enrage_boost: float = 1.5 if _enraged else 1.0
	var radius_scale: float = 1.0 if not _enraged else 1.2
	match boss_id:
		"bone_lord":
			# 骨白色 + 旋转骨片
			var aura_color := Color(0.95, 0.92, 0.78, 0.12 + pulse * 0.08)
			draw_circle(Vector2.ZERO, enemy_size * 1.9 * radius_scale, aura_color)
			var rot_speed: float = 0.5 * enrage_boost
			for i in range(4):
				var a: float = _aura_rotation * rot_speed + TAU * float(i) / 4.0
				var bone_pos: Vector2 = Vector2(cos(a), sin(a)) * (enemy_size * 1.6)
				var bone_alpha: float = 0.55 + sin(_aura_rotation * 4.0 + i) * 0.25
				var bc := Color(1.0, 0.97, 0.85, bone_alpha)
				# 菱形骨片
				var s := 4.5
				var pts := PackedVector2Array([
					bone_pos + Vector2(0, -s),
					bone_pos + Vector2(s * 0.6, 0),
					bone_pos + Vector2(0, s),
					bone_pos + Vector2(-s * 0.6, 0),
				])
				draw_colored_polygon(pts, bc)
		"shadow_lich":
			# 紫色暗能量漩涡（双层螺旋）
			var aura_color := Color(0.45, 0.18, 0.7, 0.13 + pulse * 0.1)
			draw_circle(Vector2.ZERO, enemy_size * 1.9 * radius_scale, aura_color)
			var rot_outer: float = _aura_rotation * 0.8 * enrage_boost
			var rot_inner: float = -_aura_rotation * 1.2 * enrage_boost
			for i in range(12):
				var a_out: float = rot_outer + TAU * float(i) / 12.0
				var p_out: Vector2 = Vector2(cos(a_out), sin(a_out)) * (enemy_size * 1.7)
				draw_circle(p_out, 2.5, Color(0.7, 0.35, 0.95, 0.6))
			for i in range(8):
				var a_in: float = rot_inner + TAU * float(i) / 8.0
				var p_in: Vector2 = Vector2(cos(a_in), sin(a_in)) * (enemy_size * 1.2)
				draw_circle(p_in, 2.0, Color(0.85, 0.5, 1.0, 0.7))
		"blood_moon":
			# 红色血焰脉动（不规则边缘）
			var pulse2: float = (sin(Time.get_ticks_msec() * 0.006) + 1.0) * 0.5
			var aura_color := Color(0.85, 0.05, 0.12, 0.15 + pulse2 * 0.13)
			draw_circle(Vector2.ZERO, enemy_size * 1.85 * radius_scale, aura_color)
			# 火焰边缘：12 段不规则线
			var segs := 16
			for i in range(segs):
				var a1: float = TAU * float(i) / float(segs)
				var a2: float = TAU * float(i + 1) / float(segs)
				var noise1: float = sin(_aura_rotation * 3.0 + i * 1.7) * 0.25 + sin(_aura_rotation * 5.0 + i * 0.5) * 0.15
				var noise2: float = sin(_aura_rotation * 3.0 + (i + 1) * 1.7) * 0.25 + sin(_aura_rotation * 5.0 + (i + 1) * 0.5) * 0.15
				var r1: float = enemy_size * (2.0 + noise1) * radius_scale
				var r2: float = enemy_size * (2.0 + noise2) * radius_scale
				var p1: Vector2 = Vector2(cos(a1), sin(a1)) * r1
				var p2: Vector2 = Vector2(cos(a2), sin(a2)) * r2
				draw_line(p1, p2, Color(1.0, 0.3, 0.1, 0.7 + pulse2 * 0.3), 2.5)
		_:
			var aura_color := Color(color.r, color.g, color.b, 0.1 + pulse * 0.1)
			draw_circle(Vector2.ZERO, enemy_size * 2.0, aura_color)


func take_damage(amount: float) -> void:
	if _dying:
		return
	# 登场期不可受击（PRD 5.5.2）
	if _entering:
		return
	health -= amount
	_flash_timer = 0.08
	AudioManager.play("enemy_hit")
	VfxPool.hit_flash(global_position, color, 15.0 + amount * 0.2)

	if not _undying_triggered and boss_id == "blood_moon" and health <= max_health * 0.3:
		_skill_undying()

	if health <= 0:
		_die()


func apply_slow(mult: float, duration: float) -> void:
	_slow_mult = minf(_slow_mult, mult)
	_slow_timer = maxf(_slow_timer, duration)


func apply_knockback(force: Vector2) -> void:
	# Boss 击退真正生效（PRD 5.5.4）；登场/死亡期不生效
	if _entering or _dying:
		return
	# Boss 击退抗性：受力减半，避免被秒推开屏
	position += force * 0.5


func _die() -> void:
	_dying = true
	# 清理可能残留的登场/undying 遮罩
	if is_instance_valid(_enter_overlay):
		_hide_enter_overlay()
	SpatialGrid.unregister(self)
	remove_from_group("enemies")
	remove_from_group("bosses")
	GameData.total_kills += 1
	GameData.boss_kills_this_stage += 1
	var p = GameData.player_ref
	if is_instance_valid(p) and p.has_method("on_enemy_killed"):
		p.on_enemy_killed()
		if p.has_method("spawn_soul_drain_visual"):
			p.spawn_soul_drain_visual(global_position)
	AudioManager.play("enemy_die")

	VfxPool.screen_flash(Color(1.0, 0.9, 0.5, 0.3), 0.3)
	VfxPool.spark_burst(global_position, 24, color, 200.0, 0.8)
	VfxPool.ring_wave(global_position, color, enemy_size * 6.0, 0.6)
	VfxPool.ring_wave(global_position, GameData.UI_GOLD, enemy_size * 4.0, 0.4)

	_spawn_boss_loot()
	boss_died.emit(boss_id)

	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_BACK)
	tween.tween_callback(queue_free)


func _spawn_boss_loot() -> void:
	# 8 颗大经验球（PRD 5.4 公式）：xp_per_gem = max(20, ceil(xp_value / 8))
	var gem_count := 8
	var xp_per_gem: int = maxi(20, int(ceil(float(xp_value) / float(gem_count))))
	for i in range(gem_count):
		var gem_script := preload("res://scripts/experience_gem.gd")
		var gem := Node2D.new()
		gem.set_script(gem_script)
		var angle: float = TAU * float(i) / float(gem_count) + randf() * 0.2
		var radius: float = randf_range(30.0, 40.0)
		gem.global_position = global_position + Vector2(cos(angle), sin(angle)) * radius
		gem.xp_value = xp_per_gem
		var pickup_container := GameData.pickups_container
		if pickup_container and is_instance_valid(pickup_container):
			pickup_container.add_child(gem)

	# 必掉宝箱（60% 史诗 / 40% 稀有）
	var chest_script := preload("res://scripts/treasure_chest.gd")
	var chest := Node2D.new()
	chest.set_script(chest_script)
	chest.global_position = global_position
	chest.setup_random()
	if randf() < 0.6:
		chest.rarity = chest_script.ChestRarity.EPIC
	else:
		chest.rarity = chest_script.ChestRarity.RARE
	var loot_container := GameData.pickups_container
	if loot_container and is_instance_valid(loot_container):
		loot_container.add_child(chest)
		AudioManager.play("chest_spawn")
	# HUD 中央横幅（PRD 5.5.0 通用规格）
	for hud in get_tree().get_nodes_in_group("hud"):
		if hud.has_method("show_banner"):
			hud.show_banner("Boss 掉落大量经验！", GameData.UI_GOLD, 2.0)
		elif hud.has_method("show_reward_notice"):
			hud.show_reward_notice("Boss 掉落大量经验！", GameData.UI_GOLD, 2.0)
