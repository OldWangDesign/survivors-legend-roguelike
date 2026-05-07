extends Node

signal wave_warning()

const Formation = preload("res://scripts/enemy_formation.gd")

var _spawn_timer: float = 0.0
var _wave_timer: float = 0.0
var _wave_cooldown: float = 0.0
var _elite_timer: float = 0.0
var _boss_index: int = 0
var _active_boss: Node2D = null
var _boss_rest_timer: float = 0.0

var _wave_warn_timer: float = 0.0
var _wave_warn_active: bool = false
var _pending_swarm_time: float = 0.0
var _formation_timer: float = 0.0
var _spiral_queue: Array = []
var _spiral_spawn_timer: float = 0.0

const SPAWN_DISTANCE := 800.0

const BOSS_TIMES: Array = [300.0, 600.0, 900.0]
const BOSS_IDS: Array = ["bone_lord", "shadow_lich", "blood_moon"]

const WAVE_INTERVAL_BASE := 30.0
const WAVE_DURATION := 3.0
const WAVE_REST := 2.5
const WAVE_WARNING_DURATION := 1.5
const ELITE_START_TIME := 300.0
const ELITE_INTERVAL_BASE := 50.0

enum Phase { TRIAL, GROWTH, PRESSURE, FRENZY, HELL, ENDGAME }


func _physics_process(delta: float) -> void:
	var time := GameData.elapsed_time

	if _boss_rest_timer > 0:
		_boss_rest_timer -= delta
		return

	_process_spiral_queue(delta, time)

	if _wave_warn_active:
		_wave_warn_timer -= delta
		if _wave_warn_timer <= 0:
			_wave_warn_active = false
			_do_trigger_swarm(_pending_swarm_time)
			_wave_cooldown = WAVE_DURATION + WAVE_REST
		return

	var spawn_interval := _get_spawn_interval(time)
	_spawn_timer -= delta
	if _spawn_timer <= 0:
		_spawn_timer = spawn_interval
		_spawn_normal_wave(time)

	_update_wave_events(delta, time)
	_update_elite_spawns(delta, time)
	_update_formation_timer(delta, time)
	_check_boss_spawn(time)


func _get_phase(time: float) -> int:
	if time < 120.0: return Phase.TRIAL
	if time < 300.0: return Phase.GROWTH
	if time < 480.0: return Phase.PRESSURE
	if time < 720.0: return Phase.FRENZY
	if time < 900.0: return Phase.HELL
	return Phase.ENDGAME


func _get_spawn_interval(time: float) -> float:
	var phase := _get_phase(time)
	var scale: float = GameData.get_spawn_rate_scale()
	if not get_tree().get_nodes_in_group("bosses").is_empty():
		scale *= 0.65
	match phase:
		Phase.TRIAL: return 1.0 / scale
		Phase.GROWTH: return 0.6 / scale
		Phase.PRESSURE: return 0.4 / scale
		Phase.FRENZY: return 0.25 / scale
		Phase.HELL: return 0.15 / scale
		Phase.ENDGAME: return 0.10 / scale
	return 0.5


func _spawn_normal_wave(time: float) -> void:
	var enemies := get_tree().get_nodes_in_group("enemies")
	if enemies.size() >= GameData.get_enemy_cap():
		return

	var player := GameData.player_ref
	if not is_instance_valid(player):
		return

	var count := _get_spawn_count(time)
	var difficulty := GameData.get_difficulty_multiplier(time)

	for i in range(count):
		var type := _get_enemy_type(time)
		_spawn_enemy(type, player.global_position, difficulty)


func _get_normal_formation_chance(time: float) -> float:
	if time < 60.0: return 0.0
	if time < 120.0: return 0.15
	if time < 300.0: return 0.25
	if time < 480.0: return 0.35
	return 0.5


func _get_spawn_count(time: float) -> int:
	var phase := _get_phase(time)
	var boss_scale := 0.55 if not get_tree().get_nodes_in_group("bosses").is_empty() else 1.0
	match phase:
		Phase.TRIAL: return maxi(1, int(float(randi_range(2, 3)) * boss_scale))
		Phase.GROWTH: return maxi(1, int(float(randi_range(3, 5)) * boss_scale))
		Phase.PRESSURE: return maxi(2, int(float(randi_range(4, 8)) * boss_scale))
		Phase.FRENZY: return maxi(3, int(float(randi_range(6, 10)) * boss_scale))
		Phase.HELL: return maxi(4, int(float(randi_range(8, 14)) * boss_scale))
		Phase.ENDGAME: return maxi(5, int(float(randi_range(10, 18)) * boss_scale))
	return 3


func _get_enemy_type(time: float) -> String:
	var phase := _get_phase(time)
	var pool: Array[String]
	match phase:
		Phase.TRIAL:
			pool = ["bat"]
		Phase.GROWTH:
			pool = ["bat", "bat", "skeleton"]
		Phase.PRESSURE:
			pool = ["bat", "skeleton", "skeleton", "ghost"]
		Phase.FRENZY:
			pool = ["bat", "skeleton", "zombie", "ghost"]
		Phase.HELL:
			pool = ["skeleton", "zombie", "ghost", "ghost"]
		Phase.ENDGAME:
			pool = ["skeleton", "zombie", "ghost", "ghost"]
		_:
			pool = ["bat"]
	return pool.pick_random()


func _update_wave_events(delta: float, time: float) -> void:
	if time < 90.0:
		return

	if _wave_cooldown > 0:
		_wave_cooldown -= delta
		return

	_wave_timer += delta
	var interval: float = WAVE_INTERVAL_BASE - clampf(time / 60.0, 0.0, 15.0)
	interval = maxf(interval, 12.0)

	if _wave_timer >= interval:
		_wave_timer = 0.0
		_start_wave_warning(time)


func _start_wave_warning(time: float) -> void:
	_wave_warn_active = true
	_wave_warn_timer = WAVE_WARNING_DURATION
	_pending_swarm_time = time
	wave_warning.emit()
	VfxPool.screen_flash(Color(0.8, 0.2, 0.2, 0.06), 0.15)
	AudioManager.play("wave_warning")


func _do_trigger_swarm(time: float) -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return

	var enemies := get_tree().get_nodes_in_group("enemies")
	if enemies.size() >= GameData.get_enemy_cap():
		return

	var difficulty := GameData.get_difficulty_multiplier(time)
	var phase := _get_phase(time)
	var swarm_count: int = 10
	match phase:
		Phase.GROWTH: swarm_count = 10
		Phase.PRESSURE: swarm_count = 16
		Phase.FRENZY: swarm_count = 24
		Phase.HELL: swarm_count = 32
		Phase.ENDGAME: swarm_count = 40
	swarm_count = maxi(4, int(float(swarm_count) * GameData.get_swarm_count_scale()))

	var use_formation := _should_use_formation(phase)
	if use_formation:
		var available := _get_available_formations(phase)
		var formation := Formation.pick_formation(available)
		_spawn_formation(formation, player.global_position, swarm_count, time, difficulty)
	else:
		for i in range(swarm_count):
			var type := _get_enemy_type(time)
			_spawn_enemy(type, player.global_position, difficulty)

	VfxPool.screen_flash(Color(0.8, 0.2, 0.2, 0.08), 0.15)


func _should_use_formation(phase: int) -> bool:
	match phase:
		Phase.TRIAL: return randf() < 0.5
		Phase.GROWTH: return randf() < 0.6
		Phase.PRESSURE: return randf() < 0.8
		Phase.FRENZY: return randf() < 0.9
		Phase.HELL: return true
		Phase.ENDGAME: return true
	return false


func _get_available_formations(phase: int) -> Array:
	match phase:
		Phase.TRIAL:
			return [Formation.Type.LINE]
		Phase.GROWTH:
			return [Formation.Type.LINE, Formation.Type.CIRCLE]
		Phase.PRESSURE:
			return [Formation.Type.LINE, Formation.Type.CIRCLE, Formation.Type.V_SHAPE, Formation.Type.PINCER]
		_:
			return [Formation.Type.LINE, Formation.Type.CIRCLE, Formation.Type.PINCER,
					Formation.Type.RUSH, Formation.Type.V_SHAPE, Formation.Type.SPIRAL]


func _update_formation_timer(delta: float, time: float) -> void:
	if time < 90.0:
		return

	_formation_timer += delta
	var phase := _get_phase(time)
	var interval: float
	match phase:
		Phase.TRIAL: interval = 18.0
		Phase.GROWTH: interval = 15.0
		Phase.PRESSURE: interval = 12.0
		Phase.FRENZY: interval = 10.0
		Phase.HELL: interval = 8.0
		Phase.ENDGAME: interval = 6.0
		_: interval = 15.0

	if _formation_timer >= interval:
		_formation_timer = 0.0
		var player := GameData.player_ref
		if not is_instance_valid(player):
			return
		var enemies := get_tree().get_nodes_in_group("enemies")
		if enemies.size() >= GameData.get_enemy_cap():
			return
		var difficulty := GameData.get_difficulty_multiplier(time)
		var available := _get_available_formations(phase)
		var formation := Formation.pick_formation(available)
		var count := _get_formation_count(phase)
		_spawn_formation(formation, player.global_position, count, time, difficulty)
		VfxPool.screen_flash(Color(0.9, 0.5, 0.1, 0.06), 0.1)
		AudioManager.play("wave_warning")


func _get_formation_count(phase: int) -> int:
	var scale: float = GameData.get_formation_count_scale()
	match phase:
		Phase.TRIAL: return maxi(6, int(float(randi_range(12, 15)) * scale))
		Phase.GROWTH: return maxi(8, int(float(randi_range(15, 20)) * scale))
		Phase.PRESSURE: return maxi(10, int(float(randi_range(20, 25)) * scale))
		Phase.FRENZY: return maxi(12, int(float(randi_range(25, 30)) * scale))
		Phase.HELL: return maxi(14, int(float(randi_range(30, 40)) * scale))
		Phase.ENDGAME: return maxi(16, int(float(randi_range(35, 50)) * scale))
	return 12


func _spawn_formation(formation: int, player_pos: Vector2, count: int, time: float, difficulty: float) -> void:
	var positions := Formation.get_positions(formation, player_pos, count)
	var container := GameData.enemies_container
	if not container or not is_instance_valid(container):
		return

	for data in positions:
		var delay: float = data.get("delay", 0.0)
		if delay > 0.01:
			_spiral_queue.append({
				"pos": data["pos"],
				"rush_target": data["rush_target"],
				"time": time,
				"difficulty": difficulty,
				"delay": delay,
			})
			continue

		var type := _get_enemy_type(time)
		var enemy := Node2D.new()
		enemy.set_script(preload("res://scripts/enemy.gd"))
		enemy.global_position = data["pos"]
		container.add_child(enemy)
		enemy.setup(type, difficulty)
		enemy.apply_formation_debuff()
		enemy.setup_formation_delay(0.8)
		var rush_target: Vector2 = data.get("rush_target", Vector2.ZERO)
		if rush_target != Vector2.ZERO:
			enemy.setup_rush(rush_target)


func _process_spiral_queue(delta: float, _time: float) -> void:
	if _spiral_queue.is_empty():
		return

	_spiral_spawn_timer += delta
	var container := GameData.enemies_container
	if not container or not is_instance_valid(container):
		return

	var remaining: Array = []
	for data in _spiral_queue:
		data["delay"] -= delta
		if data["delay"] <= 0:
			var type := _get_enemy_type(data["time"])
			var enemy := Node2D.new()
			enemy.set_script(preload("res://scripts/enemy.gd"))
			enemy.global_position = data["pos"]
			container.add_child(enemy)
			enemy.setup(type, data["difficulty"])
			enemy.apply_formation_debuff()
			enemy.setup_formation_delay(0.5)
			var rush_target: Vector2 = data.get("rush_target", Vector2.ZERO)
			if rush_target != Vector2.ZERO:
				enemy.setup_rush(rush_target)
		else:
			remaining.append(data)
	_spiral_queue = remaining


func _update_elite_spawns(delta: float, time: float) -> void:
	if time < ELITE_START_TIME:
		return

	_elite_timer += delta
	var interval: float = ELITE_INTERVAL_BASE - clampf((time - ELITE_START_TIME) / 30.0, 0.0, 30.0)
	interval = maxf(interval, 15.0)

	if _elite_timer >= interval:
		_elite_timer = 0.0
		_spawn_elite(time)


func _spawn_elite(time: float) -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return

	AudioManager.play("elite_warning")

	var difficulty := GameData.get_difficulty_multiplier(time)
	var type := _get_enemy_type(time)
	var elite_types := ["berserk", "armored", "splitter"]
	var elite_type: String = elite_types.pick_random()

	var angle := randf() * TAU
	var spawn_pos := player.global_position + Vector2(cos(angle), sin(angle)) * SPAWN_DISTANCE

	var enemy := Node2D.new()
	enemy.set_script(preload("res://scripts/enemy.gd"))
	enemy.global_position = spawn_pos

	var container := GameData.enemies_container
	if container and is_instance_valid(container):
		container.add_child(enemy)
		enemy.setup(type, difficulty * 1.5)
		enemy.setup_elite(elite_type)

	var phase := _get_phase(time)
	if phase >= Phase.HELL:
		var angle2 := angle + PI
		var spawn_pos2 := player.global_position + Vector2(cos(angle2), sin(angle2)) * SPAWN_DISTANCE
		var enemy2 := Node2D.new()
		enemy2.set_script(preload("res://scripts/enemy.gd"))
		enemy2.global_position = spawn_pos2
		if container and is_instance_valid(container):
			container.add_child(enemy2)
			enemy2.setup(_get_enemy_type(time), difficulty * 1.5)
			enemy2.setup_elite(elite_types.pick_random())


func _check_boss_spawn(time: float) -> void:
	if is_instance_valid(_active_boss):
		return

	if _boss_index < BOSS_TIMES.size() and time >= BOSS_TIMES[_boss_index]:
		_spawn_boss(BOSS_IDS[_boss_index] if _boss_index < BOSS_IDS.size() else "bone_lord", time)
		_boss_index += 1
	elif _boss_index >= BOSS_TIMES.size():
		var next_time: float = BOSS_TIMES[-1] + (_boss_index - BOSS_TIMES.size() + 1) * 300.0
		if time >= next_time:
			var cycle_idx: int = (_boss_index - BOSS_TIMES.size()) % BOSS_IDS.size()
			_spawn_boss(BOSS_IDS[cycle_idx], time)
			_boss_index += 1


func _spawn_boss(id: String, time: float) -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return

	VfxPool.screen_flash(Color(0.8, 0.1, 0.1, 0.12), 0.3)
	AudioManager.start_boss_bgm()

	var difficulty := GameData.get_difficulty_multiplier(time)
	var angle := randf() * TAU
	var spawn_pos := player.global_position + Vector2(cos(angle), sin(angle)) * SPAWN_DISTANCE

	var boss := Node2D.new()
	boss.set_script(preload("res://scripts/boss_enemy.gd"))
	boss.global_position = spawn_pos
	boss._enter_start_pos = spawn_pos
	boss._enter_target_pos = player.global_position + Vector2(cos(angle), sin(angle)) * 200.0

	var container := GameData.enemies_container
	if container and is_instance_valid(container):
		container.add_child(boss)
		boss.setup_boss(id, difficulty)
		boss.boss_died.connect(_on_boss_died)
		_active_boss = boss


func _on_boss_died(_boss_id: String) -> void:
	_active_boss = null
	_boss_rest_timer = 5.0
	AudioManager.stop_boss_bgm()


func _spawn_enemy(type_key: String, player_pos: Vector2, difficulty: float) -> void:
	var angle := randf() * TAU
	var spawn_pos := player_pos + Vector2(cos(angle), sin(angle)) * SPAWN_DISTANCE

	var enemy := Node2D.new()
	enemy.set_script(preload("res://scripts/enemy.gd"))
	enemy.global_position = spawn_pos

	var container := GameData.enemies_container
	if container and is_instance_valid(container):
		container.add_child(enemy)
		enemy.setup(type_key, difficulty)
