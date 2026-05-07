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

var _enraged: bool = false
var _skill_timers: Dictionary = {}
var _skill_cooldowns: Dictionary = {}
var _entering: bool = true
var _enter_timer: float = 2.0
var _enter_start_pos: Vector2
var _enter_target_pos: Vector2

var _undying_triggered: bool = false


func _ready() -> void:
	add_to_group("enemies")
	add_to_group("bosses")
	SpatialGrid.register(self)


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
		_skill_timers[sk_name] = cd * 0.5

	_sprite = Sprite2D.new()
	var sprite_data = GameData.sprites.get("boss")
	if sprite_data is Array and sprite_data.size() > 0:
		_sprite.texture = sprite_data[0]
	elif sprite_data is ImageTexture:
		_sprite.texture = sprite_data
	_sprite.scale = Vector2.ONE * (enemy_size * 2.0 / 24.0)
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_sprite)

	_anim_timer = randf() * ANIM_SPEED
	_entering = true
	_enter_timer = 2.0


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

	if _entering:
		_enter_timer -= delta
		if _enter_timer <= 0:
			_entering = false
		else:
			var t: float = 1.0 - (_enter_timer / 2.0)
			global_position = _enter_start_pos.lerp(_enter_target_pos, t)
			SpatialGrid.update_position(self)
			queue_redraw()
			return

	var player := GameData.player_ref
	if not is_instance_valid(player):
		return

	var dir := (player.global_position - global_position).normalized()
	position += dir * speed * _slow_mult * delta
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
		var anim_data = GameData.sprites.get("boss")
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


func _check_enrage() -> void:
	if _enraged:
		return
	if health <= max_health * 0.5:
		_enraged = true
		speed *= 1.3
		for sk in _skill_cooldowns:
			_skill_cooldowns[sk] *= 0.7
		VfxPool.ring_wave(global_position, Color(1.0, 0.3, 0.1), enemy_size * 5.0, 0.6)
		AudioManager.play("level_up")


func _update_skills(delta: float) -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return

	for sk_name in _skill_timers.keys():
		_skill_timers[sk_name] -= delta
		if _skill_timers[sk_name] <= 0:
			_skill_timers[sk_name] = _skill_cooldowns[sk_name]
			_use_skill(sk_name)


func _use_skill(skill_name: String) -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return

	match skill_name:
		"bone_spike":
			_skill_bone_spike(player)
		"summon_skeleton":
			_skill_summon_minions("skeleton", 3)
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


func _skill_bone_spike(player: CharacterBody2D) -> void:
	var dir := (player.global_position - global_position).normalized()
	VfxPool.line_attack(global_position, dir, 300.0, 40.0, Color(0.9, 0.8, 0.6), 1.0)
	var dist := global_position.distance_to(player.global_position)
	if dist < 300.0:
		var perp := Vector2(-dir.y, dir.x)
		var perp_dist := absf((player.global_position - global_position).dot(perp))
		if perp_dist < 40.0:
			player.take_damage(damage)


func _skill_summon_minions(type_key: String, count: int) -> void:
	var container := GameData.enemies_container
	if not container or not is_instance_valid(container):
		return
	for i in range(count):
		var minion := Node2D.new()
		minion.set_script(preload("res://scripts/enemy.gd"))
		var angle: float = TAU * float(i) / float(count)
		minion.global_position = global_position + Vector2(cos(angle), sin(angle)) * 40.0
		container.add_child(minion)
		var diff: float = max_health / (GameData.ENEMY_TYPES["boss"]["health"] * 2.5)
		minion.setup(type_key, diff)
	VfxPool.ring_wave(global_position, Color(0.8, 0.8, 0.6), 60.0, 0.3)


func _skill_charge(player: CharacterBody2D) -> void:
	var dir := (player.global_position - global_position).normalized()
	var charge_tween := create_tween()
	var target_pos := global_position + dir * 250.0
	charge_tween.tween_property(self, "global_position", target_pos, 0.3).set_trans(Tween.TRANS_BACK)
	VfxPool.spark_burst(global_position, 6, Color(0.8, 0.2, 0.2), 80.0, 0.3)

	var dist := global_position.distance_to(player.global_position)
	if dist < 80.0:
		player.take_damage(int(damage * 1.2))
		player.apply_knockback(dir * 200.0)


func _skill_soul_barrage(player: CharacterBody2D) -> void:
	var base_dir := (player.global_position - global_position).normalized()
	for i in range(5):
		var angle_offset: float = (float(i) - 2.0) * 0.15
		var dir := base_dir.rotated(angle_offset)
		var proj := _create_boss_projectile(dir, 150.0, int(damage * 0.3))
		proj.global_position = global_position + dir * 20.0
	AudioManager.play("enemy_hit")


func _skill_phantom_split() -> void:
	VfxPool.ring_wave(global_position, Color(0.5, 0.3, 0.8), enemy_size * 4.0, 0.5)
	for i in range(2):
		var angle: float = TAU * float(i) / 2.0 + randf() * 0.5
		var offset := Vector2(cos(angle), sin(angle)) * 80.0
		var phantom := Node2D.new()
		phantom.set_script(preload("res://scripts/enemy.gd"))
		phantom.global_position = global_position + offset
		var container := GameData.enemies_container
		if container and is_instance_valid(container):
			container.add_child(phantom)
			phantom.setup("ghost", max_health / (GameData.ENEMY_TYPES["ghost"]["health"] * 3.0))
			phantom.enemy_size = enemy_size * 0.8
			if is_instance_valid(phantom._sprite):
				phantom._sprite.scale *= 1.5
				phantom._sprite.modulate.a = 0.5


func _skill_dark_field() -> void:
	VfxPool.ring_wave(global_position, Color(0.2, 0.0, 0.3), 120.0, 4.0)
	var player := GameData.player_ref
	if is_instance_valid(player):
		if global_position.distance_to(player.global_position) < 120.0:
			player.apply_slow(0.5, 4.0)


func _skill_moon_wrath() -> void:
	VfxPool.screen_flash(Color(0.8, 0.1, 0.1, 0.15), 0.3)
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return
	if player.global_position.distance_to(global_position) > 80.0:
		player.take_damage(int(damage * 1.2))
	VfxPool.ring_wave(global_position, Color(0.9, 0.1, 0.1), 300.0, 0.5)
	VfxPool.ring_wave(global_position, Color(0.2, 1.0, 0.2, 0.3), 80.0, 0.5)


func _skill_summon_elites() -> void:
	var container := GameData.enemies_container
	if not container or not is_instance_valid(container):
		return
	var elite_types := ["berserk", "armored"]
	for i in range(2):
		var minion := Node2D.new()
		minion.set_script(preload("res://scripts/enemy.gd"))
		var angle: float = TAU * float(i) / 2.0
		minion.global_position = global_position + Vector2(cos(angle), sin(angle)) * 60.0
		container.add_child(minion)
		var types := ["skeleton", "zombie", "ghost"]
		var diff: float = max_health / (GameData.ENEMY_TYPES["boss"]["health"] * 2.5)
		minion.setup(types[i % types.size()], diff)
		minion.setup_elite(elite_types[i])
	VfxPool.ring_wave(global_position, Color(0.8, 0.1, 0.1), 80.0, 0.4)


func _skill_undying() -> void:
	if _undying_triggered:
		return
	if health <= max_health * 0.3:
		_undying_triggered = true
		health = max_health * 0.5
		VfxPool.screen_flash(Color(0.8, 0.0, 0.0, 0.3), 0.5)
		VfxPool.ring_wave(global_position, Color(1.0, 0.0, 0.0), enemy_size * 6.0, 0.8)
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


func _draw() -> void:
	if _dying:
		return

	var aura_pulse: float = (sin(Time.get_ticks_msec() * 0.003) + 1.0) * 0.5
	var aura_radius: float = enemy_size * 2.0
	var aura_color := Color(color.r, color.g, color.b, 0.1 + aura_pulse * 0.1)
	draw_circle(Vector2.ZERO, aura_radius, aura_color)

	if _enraged:
		var rage_color := Color(1.0, 0.2, 0.0, 0.15 + aura_pulse * 0.1)
		draw_circle(Vector2.ZERO, aura_radius * 1.3, rage_color)

	if _entering:
		var enter_alpha: float = 1.0 - (_enter_timer / 2.0)
		var warn_color := Color(1.0, 0.1, 0.1, enter_alpha * 0.3)
		draw_circle(Vector2.ZERO, enemy_size * 3.0 * (1.0 - enter_alpha * 0.5), warn_color)


func take_damage(amount: float) -> void:
	if _dying:
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


func apply_knockback(_force: Vector2) -> void:
	pass


func _die() -> void:
	_dying = true
	SpatialGrid.unregister(self)
	remove_from_group("enemies")
	remove_from_group("bosses")
	GameData.total_kills += 1
	GameData.boss_kills_this_stage += 1
	var p = GameData.player_ref
	if is_instance_valid(p) and p.has_method("on_enemy_killed"):
		p.on_enemy_killed()
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
	var gem_count := 3
	for i in range(gem_count):
		var gem_script := preload("res://scripts/experience_gem.gd")
		var gem := Node2D.new()
		gem.set_script(gem_script)
		var angle: float = TAU * float(i) / float(gem_count)
		gem.global_position = global_position + Vector2(cos(angle), sin(angle)) * 34.0
		gem.xp_value = maxi(20, int(ceil(float(xp_value) / float(gem_count))))
		var pickup_container := GameData.pickups_container
		if pickup_container and is_instance_valid(pickup_container):
			pickup_container.add_child(gem)

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
	VfxPool.float_text(global_position + Vector2(0, -enemy_size * 2.0), "Boss奖励: 大量经验 + 宝箱", GameData.UI_GOLD, 18.0, true)
	for hud in get_tree().get_nodes_in_group("hud"):
		if hud.has_method("show_reward_notice"):
			hud.show_reward_notice("Boss奖励: 大量经验 + 宝箱", GameData.UI_GOLD, 2.2)
