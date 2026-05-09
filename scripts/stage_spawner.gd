extends Node

signal wave_warning()
signal elite_champion_warning()
signal boss_warning_started()

const Formation = preload("res://scripts/enemy_formation.gd")

var _spawn_timer: float = 0.0
var _boss_spawned: int = 0
var _stage: Dictionary = {}
var _wave_timer: float = 0.0
var _wave_cooldown: float = 0.0
var _elite_timer: float = 0.0
var _boss_warning_timer: float = 0.0
var _boss_warning_active: bool = false
var _active_boss: Node2D = null
var _boss_rest_timer: float = 0.0

var _champion_spawned: bool = false
var _wave_warn_timer: float = 0.0
var _wave_warn_active: bool = false
var _pending_swarm: bool = false
var _formation_timer: float = 0.0
var _spiral_queue: Array = []

const SPAWN_DISTANCE := 800.0
const BASE_INTERVAL := 1.0
const WAVE_INTERVAL := 25.0
const WAVE_SWARM_COUNT := 10
const WAVE_REST := 2.0
const BOSS_WARNING_DURATION := 3.0
const WAVE_WARNING_DURATION := 1.5
const CHAMPION_TIME_RATIO := 0.7


func _ready() -> void:
	_stage = GameData.get_stage_data()
	_boss_spawned = 0


func _physics_process(delta: float) -> void:
	if _stage.is_empty():
		return

	var time: float = GameData.elapsed_time

	if _boss_rest_timer > 0:
		_boss_rest_timer -= delta
		return

	_process_spiral_queue(delta)

	if _boss_warning_active:
		_boss_warning_timer -= delta
		if _boss_warning_timer <= 0:
			_boss_warning_active = false
			_do_spawn_boss()
		return

	if _wave_warn_active:
		_wave_warn_timer -= delta
		if _wave_warn_timer <= 0:
			_wave_warn_active = false
			if _pending_swarm:
				_pending_swarm = false
				_do_trigger_swarm(time)
				_wave_cooldown = 3.0 + WAVE_REST
		return

	var rate: float = _stage.get("spawn_rate", 1.0)
	var spawn_scale: float = GameData.get_spawn_rate_scale()
	if not get_tree().get_nodes_in_group("bosses").is_empty():
		spawn_scale *= 0.65
	var interval: float = maxf(0.15, BASE_INTERVAL / (rate * spawn_scale))

	_spawn_timer -= delta
	if _spawn_timer <= 0:
		_spawn_timer = interval
		_spawn_wave(time)

	_update_wave_events(delta, time)
	_update_elite_spawns(delta, time)
	_update_formation_timer(delta, time)
	_check_champion_spawn(time)
	_check_boss_spawn(time)


func _spawn_wave(time: float) -> void:
	var enemies: Array = get_tree().get_nodes_in_group("enemies")
	if enemies.size() >= GameData.get_enemy_cap():
		return
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return

	var difficulty: float = _stage.get("difficulty_mult", 1.0)
	var time_scale: float = 1.0 + time / _stage.get("duration", 120.0) * 0.5
	var eff_difficulty: float = difficulty * time_scale

	var count: int = _get_spawn_count()
	var pool: Array = _stage.get("enemy_pool", ["bat"])
	# 闯关模式按 mech_enemy_chance 替换为机制怪（PRD 5.10.3）
	var mech_chance: float = _stage.get("mech_enemy_chance", 0.0)
	for i in range(count):
		var type_key: String = pool[randi() % pool.size()]
		if mech_chance > 0.0 and randf() < mech_chance:
			type_key = ["charger", "ranged"].pick_random()
		_spawn_enemy(type_key, player.global_position, eff_difficulty)


func _get_spawn_count() -> int:
	var rate: float = _stage.get("spawn_rate", 1.0)
	var base: int = maxi(1, int(rate))
	var count := randi_range(base, base + 2)
	if not get_tree().get_nodes_in_group("bosses").is_empty():
		count = maxi(1, int(float(count) * 0.55))
	return count


# ── Wave events with warning ──

func _update_wave_events(delta: float, time: float) -> void:
	var duration: float = _stage.get("duration", 120.0)
	if time < duration * 0.15:
		return

	if _wave_cooldown > 0:
		_wave_cooldown -= delta
		return

	_wave_timer += delta
	var rate: float = _stage.get("spawn_rate", 1.0)
	var interval: float = maxf(10.0, WAVE_INTERVAL / rate)

	if _wave_timer >= interval:
		_wave_timer = 0.0
		_start_wave_warning(time)


func _start_wave_warning(_time: float) -> void:
	_wave_warn_active = true
	_wave_warn_timer = WAVE_WARNING_DURATION
	_pending_swarm = true
	wave_warning.emit()
	VfxPool.screen_flash(Color(0.8, 0.2, 0.2, 0.06), 0.15)
	AudioManager.play("wave_warning")


func _do_trigger_swarm(time: float) -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return

	var enemies: Array = get_tree().get_nodes_in_group("enemies")
	if enemies.size() >= GameData.get_enemy_cap():
		return

	var difficulty: float = _stage.get("difficulty_mult", 1.0)
	var time_scale: float = 1.0 + time / _stage.get("duration", 120.0) * 0.5
	var eff_difficulty: float = difficulty * time_scale

	var rate: float = _stage.get("spawn_rate", 1.0)
	var count: int = int(WAVE_SWARM_COUNT * rate)
	count = clampi(count, 6, 30)
	count = maxi(4, int(float(count) * GameData.get_swarm_count_scale()))

	var use_formation := _should_use_formation()
	if use_formation:
		var available := _get_available_formations()
		var formation := Formation.pick_formation(available)
		var formation_count := _get_stage_formation_count(difficulty)
		_spawn_formation(formation, player.global_position, formation_count, eff_difficulty)
	else:
		var pool: Array = _stage.get("enemy_pool", ["bat"])
		for i in range(count):
			var type_key: String = pool[randi() % pool.size()]
			_spawn_enemy(type_key, player.global_position, eff_difficulty)

	VfxPool.screen_flash(Color(0.8, 0.2, 0.2, 0.08), 0.1)


func _should_use_formation() -> bool:
	var diff: float = _stage.get("difficulty_mult", 1.0)
	if diff < 0.8:
		return false
	elif diff < 1.0:
		return randf() < 0.4
	elif diff < 1.3:
		return randf() < 0.6
	elif diff < 1.8:
		return randf() < 0.8
	else:
		return randf() < 0.95


func _get_available_formations() -> Array:
	var diff: float = _stage.get("difficulty_mult", 1.0)
	if diff < 1.0:
		return [Formation.Type.LINE]
	elif diff < 1.3:
		return [Formation.Type.LINE, Formation.Type.CIRCLE]
	elif diff < 1.8:
		return [Formation.Type.LINE, Formation.Type.CIRCLE, Formation.Type.V_SHAPE, Formation.Type.PINCER]
	else:
		return [Formation.Type.LINE, Formation.Type.CIRCLE, Formation.Type.PINCER,
				Formation.Type.RUSH, Formation.Type.V_SHAPE, Formation.Type.SPIRAL]


func _update_formation_timer(delta: float, _time: float) -> void:
	var diff: float = _stage.get("difficulty_mult", 1.0)
	if diff < 1.0:
		return

	_formation_timer += delta
	var interval: float = 22.0 - diff * 3.0
	interval = maxf(interval, 10.0)

	if _formation_timer >= interval:
		_formation_timer = 0.0
		var player := GameData.player_ref
		if not is_instance_valid(player):
			return
		var enemies: Array = get_tree().get_nodes_in_group("enemies")
		if enemies.size() >= GameData.get_enemy_cap():
			return
		var eff_diff: float = diff * (1.0 + GameData.elapsed_time / _stage.get("duration", 120.0) * 0.5)
		var available := _get_available_formations()
		var formation := Formation.pick_formation(available)
		var count := _get_stage_formation_count(diff)
		_spawn_formation(formation, player.global_position, count, eff_diff)
		VfxPool.screen_flash(Color(0.9, 0.5, 0.1, 0.06), 0.1)
		AudioManager.play("wave_warning")


func _get_stage_formation_count(diff: float) -> int:
	var scale: float = GameData.get_formation_count_scale()
	if diff < 1.0:
		return maxi(5, int(float(randi_range(8, 12)) * scale))
	elif diff < 1.3:
		return maxi(7, int(float(randi_range(12, 18)) * scale))
	elif diff < 1.8:
		return maxi(10, int(float(randi_range(18, 25)) * scale))
	return maxi(12, int(float(randi_range(25, 40)) * scale))


func _spawn_formation(formation: int, player_pos: Vector2, count: int, difficulty: float) -> void:
	var positions := Formation.get_positions(formation, player_pos, count)
	var container := GameData.enemies_container
	if not container or not is_instance_valid(container):
		return

	var pool: Array = _stage.get("enemy_pool", ["bat"])
	for data in positions:
		var delay: float = data.get("delay", 0.0)
		if delay > 0.01:
			_spiral_queue.append({
				"pos": data["pos"],
				"rush_target": data["rush_target"],
				"difficulty": difficulty,
				"pool": pool,
				"delay": delay,
			})
			continue

		var type_key: String = pool[randi() % pool.size()]
		var enemy := Node2D.new()
		enemy.set_script(preload("res://scripts/enemy.gd"))
		enemy.global_position = data["pos"]
		container.add_child(enemy)
		enemy.setup(type_key, difficulty)
		enemy.apply_formation_debuff()
		enemy.setup_formation_delay(0.8)
		var rush_target: Vector2 = data.get("rush_target", Vector2.ZERO)
		if rush_target != Vector2.ZERO:
			enemy.setup_rush(rush_target)


func _process_spiral_queue(delta: float) -> void:
	if _spiral_queue.is_empty():
		return

	var container := GameData.enemies_container
	if not container or not is_instance_valid(container):
		return

	var remaining: Array = []
	for data in _spiral_queue:
		data["delay"] -= delta
		if data["delay"] <= 0:
			var pool: Array = data.get("pool", ["bat"])
			var type_key: String = pool[randi() % pool.size()]
			var enemy := Node2D.new()
			enemy.set_script(preload("res://scripts/enemy.gd"))
			enemy.global_position = data["pos"]
			container.add_child(enemy)
			enemy.setup(type_key, data["difficulty"])
			enemy.apply_formation_debuff()
			enemy.setup_formation_delay(0.5)
			var rush_target: Vector2 = data.get("rush_target", Vector2.ZERO)
			if rush_target != Vector2.ZERO:
				enemy.setup_rush(rush_target)
		else:
			remaining.append(data)
	_spiral_queue = remaining


# ── Elite spawns (lowered threshold to 0.9) ──

func _update_elite_spawns(delta: float, time: float) -> void:
	var difficulty: float = _stage.get("difficulty_mult", 1.0)
	if difficulty < 0.9:
		return

	_elite_timer += delta
	var interval: float = maxf(20.0, 60.0 - difficulty * 10.0)

	if _elite_timer >= interval:
		_elite_timer = 0.0
		var chance: float = 0.02 + (difficulty - 0.9) * 0.08
		if randf() < chance:
			_spawn_elite(time)


func _spawn_elite(time: float) -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return

	var difficulty: float = _stage.get("difficulty_mult", 1.0)
	var time_scale: float = 1.0 + time / _stage.get("duration", 120.0) * 0.5
	var eff_difficulty: float = difficulty * time_scale

	var pool: Array = _stage.get("enemy_pool", ["bat"])
	var type_key: String = pool[randi() % pool.size()]
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
		enemy.setup(type_key, eff_difficulty * 1.5)
		enemy.setup_elite(elite_type)


# ── Champion elite at 70% time (non-boss stages) ──

func _check_champion_spawn(time: float) -> void:
	if _champion_spawned:
		return

	var boss_count: int = _stage.get("boss_count", 0)
	if boss_count > 0:
		return

	var duration: float = _stage.get("duration", 120.0)
	if time >= duration * CHAMPION_TIME_RATIO:
		_champion_spawned = true
		_spawn_champion(time)


func _spawn_champion(time: float) -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return

	elite_champion_warning.emit()
	VfxPool.screen_flash(Color(0.9, 0.5, 0.1, 0.1), 0.3)
	AudioManager.play("elite_warning")

	var difficulty: float = _stage.get("difficulty_mult", 1.0)
	var time_scale: float = 1.0 + time / _stage.get("duration", 120.0) * 0.5
	var eff_difficulty: float = difficulty * time_scale * 2.0

	var pool: Array = _stage.get("enemy_pool", ["bat"])
	var type_key: String = pool[randi() % pool.size()]
	if pool.has("skeleton"):
		type_key = "skeleton"
	elif pool.has("zombie"):
		type_key = "zombie"

	var elite_types := ["berserk", "armored", "splitter"]
	var elite_type: String = elite_types.pick_random()

	var angle := randf() * TAU
	var spawn_pos := player.global_position + Vector2(cos(angle), sin(angle)) * (SPAWN_DISTANCE * 0.6)

	var enemy := Node2D.new()
	enemy.set_script(preload("res://scripts/enemy.gd"))
	enemy.global_position = spawn_pos

	var container := GameData.enemies_container
	if container and is_instance_valid(container):
		container.add_child(enemy)
		enemy.setup(type_key, eff_difficulty)
		enemy.setup_elite(elite_type)
		enemy.max_health *= 2.0
		enemy.health = enemy.max_health
		enemy.xp_value *= 3
		enemy.enemy_size *= 1.2
		if is_instance_valid(enemy._sprite):
			enemy._sprite.scale *= 1.2


# ── Boss spawns with differentiated boss_ids ──

func _check_boss_spawn(time: float) -> void:
	if is_instance_valid(_active_boss):
		return

	var boss_times: Array = _stage.get("boss_time", [])
	if _boss_spawned >= boss_times.size():
		return

	var t: float = boss_times[_boss_spawned]
	var warn_time: float = t - BOSS_WARNING_DURATION
	if time >= warn_time and not _boss_warning_active:
		_start_boss_warning()
	elif time >= t and not _boss_warning_active:
		_do_spawn_boss()


func _start_boss_warning() -> void:
	_boss_warning_active = true
	_boss_warning_timer = BOSS_WARNING_DURATION
	boss_warning_started.emit()
	VfxPool.screen_flash(Color(0.8, 0.1, 0.1, 0.1), 0.5)
	AudioManager.start_boss_bgm()


func _do_spawn_boss() -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return

	var difficulty: float = _stage.get("difficulty_mult", 1.0) * 1.5

	var boss_id: String = _get_boss_id_for_index(_boss_spawned)
	_boss_spawned += 1

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
		boss.setup_boss(boss_id, difficulty)
		boss.boss_died.connect(_on_boss_died)
		_active_boss = boss

	VfxPool.screen_flash(Color(0.8, 0.1, 0.1, 0.15), 0.3)


func _get_boss_id_for_index(idx: int) -> String:
	var boss_ids: Array = _stage.get("boss_ids", [])
	if boss_ids.size() > idx:
		return boss_ids[idx]

	var single_id: String = _stage.get("boss_id", "")
	if single_id != "":
		return single_id

	var cycle: Array = ["bone_lord", "shadow_lich", "blood_moon"]
	return cycle[idx % cycle.size()]


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
