extends Node2D

enum GameState { PLAYING, LEVEL_UP, GAME_OVER, VICTORY, PAUSED }

var state := GameState.PLAYING
var elapsed_time: float = 0.0
var _game_duration: float = 1200.0

var camera: Camera2D
var player: CharacterBody2D
var enemies_container: Node2D
var pickups_container: Node2D
var hud: Control
var level_up_panel: Control
var game_over_screen: Control

var _shake_amount: float = 0.0
var _shake_timer: float = 0.0
var _cleanup_timer: float = 0.0
var _pending_level_ups: int = 0
var _god_mode: bool = false
var debug_panel: Control = null
var pause_menu: Control = null
var _chest_timer: float = 0.0
var _next_chest_interval: float = 30.0
var _danger_zone_timer: float = 0.0
var _next_danger_interval: float = 25.0
var _healing_point_timer: float = 0.0
var _next_healing_interval: float = 42.0
const MAP_EVENT_START_TIME := 90.0  # 1.5 min 后激活

var _stage_data: Dictionary = {}


func _ready() -> void:
	GameData.total_kills = 0
	GameData.elapsed_time = 0.0
	GameData.boss_kills_this_stage = 0

	_stage_data = GameData.get_stage_data()
	if not _stage_data.is_empty():
		_game_duration = _stage_data.get("duration", 120.0)
		GameData.bg_style = _stage_data.get("bg_style", "grassland")
	else:
		_game_duration = 1200.0

	_create_background()
	_create_containers()
	_create_player()
	_create_camera()
	_create_spawner()
	_create_ui()

	get_tree().paused = false
	AudioManager.start_bgm("zombie")


func _create_background() -> void:
	var bg := Node2D.new()
	bg.set_script(preload("res://scripts/background.gd"))
	bg.z_index = GameData.Z_BACKGROUND
	add_child(bg)


func _create_containers() -> void:
	pickups_container = Node2D.new()
	pickups_container.name = "Pickups"
	add_child(pickups_container)
	GameData.pickups_container = pickups_container

	enemies_container = Node2D.new()
	enemies_container.name = "Enemies"
	add_child(enemies_container)
	GameData.enemies_container = enemies_container


func _create_player() -> void:
	player = CharacterBody2D.new()
	player.set_script(preload("res://scripts/player.gd"))
	add_child(player)
	player.leveled_up.connect(_on_player_leveled_up)
	player.died.connect(_on_player_died)
	player.hurt.connect(_on_player_hurt)


func _create_camera() -> void:
	camera = Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8.0
	player.add_child(camera)
	camera.make_current()


func _create_spawner() -> void:
	var spawner := Node.new()
	if GameData.is_stage_mode():
		spawner.set_script(preload("res://scripts/stage_spawner.gd"))
		spawner.name = "StageSpawner"
	else:
		spawner.set_script(preload("res://scripts/enemy_spawner.gd"))
		spawner.name = "EnemySpawner"
	add_child(spawner)


func _create_ui() -> void:
	var ui_layer := CanvasLayer.new()
	ui_layer.layer = 10
	ui_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(ui_layer)

	hud = Control.new()
	hud.set_script(preload("res://scripts/ui/hud.gd"))
	hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(hud)

	player.health_changed.connect(hud.update_health)
	player.xp_changed.connect(hud.update_xp)

	var stats_panel := Control.new()
	stats_panel.set_script(preload("res://scripts/ui/stats_panel.gd"))
	stats_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(stats_panel)

	level_up_panel = Control.new()
	level_up_panel.set_script(preload("res://scripts/ui/level_up_panel.gd"))
	level_up_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(level_up_panel)
	level_up_panel.visible = false
	level_up_panel.choice_made.connect(_on_level_up_choice)

	game_over_screen = Control.new()
	game_over_screen.set_script(preload("res://scripts/ui/game_over_screen.gd"))
	game_over_screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(game_over_screen)
	game_over_screen.visible = false
	game_over_screen.retry_pressed.connect(_on_retry)
	game_over_screen.menu_pressed.connect(_on_main_menu)
	if game_over_screen.has_signal("next_stage_pressed"):
		game_over_screen.next_stage_pressed.connect(_on_next_stage)
	if game_over_screen.has_signal("stage_select_pressed"):
		game_over_screen.stage_select_pressed.connect(_on_stage_select)

	pause_menu = Control.new()
	pause_menu.set_script(preload("res://scripts/ui/pause_menu.gd"))
	pause_menu.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(pause_menu)
	pause_menu.resume_pressed.connect(_on_resume)
	pause_menu.restart_pressed.connect(_on_retry)
	pause_menu.main_menu_pressed.connect(_on_main_menu)
	if pause_menu.has_signal("stage_select_pressed"):
		pause_menu.stage_select_pressed.connect(_on_stage_select)

	if OS.is_debug_build():
		debug_panel = Control.new()
		debug_panel.set_script(preload("res://scripts/ui/debug_panel.gd"))
		debug_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
		ui_layer.add_child(debug_panel)
		debug_panel.set_game_manager(self)
		debug_panel.visible = false

	var joystick := Control.new()
	joystick.set_script(preload("res://scripts/ui/virtual_joystick.gd"))
	ui_layer.add_child(joystick)
	GameData.joystick_ref = joystick

	_create_touch_buttons(ui_layer)

	_connect_spawner_signals()


func _create_touch_buttons(layer: CanvasLayer) -> void:
	var container := HBoxContainer.new()
	container.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	container.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	container.position = Vector2(-8, 4)
	container.add_theme_constant_override("separation", 8)
	layer.add_child(container)

	var pause_btn := Button.new()
	pause_btn.text = "||"
	pause_btn.custom_minimum_size = Vector2(48, 48)
	pause_btn.add_theme_font_size_override("font_size", 18)
	pause_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_btn.pressed.connect(_toggle_pause)
	container.add_child(pause_btn)

	var info_btn := Button.new()
	info_btn.text = "i"
	info_btn.custom_minimum_size = Vector2(48, 48)
	info_btn.add_theme_font_size_override("font_size", 18)
	info_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	info_btn.pressed.connect(_toggle_stats_panel)
	container.add_child(info_btn)


func _toggle_stats_panel() -> void:
	for p in get_tree().get_nodes_in_group("stats_panel"):
		p._visible_state = not p._visible_state
		p._panel.visible = p._visible_state


func _connect_spawner_signals() -> void:
	var spawner_name := "StageSpawner" if GameData.is_stage_mode() else "EnemySpawner"
	var spawner := get_node_or_null(spawner_name)
	if not spawner:
		return
	if spawner.has_signal("wave_warning") and hud.has_method("show_wave_warning"):
		spawner.wave_warning.connect(hud.show_wave_warning)
	if spawner.has_signal("elite_champion_warning") and hud.has_method("show_champion_warning"):
		spawner.elite_champion_warning.connect(hud.show_champion_warning)
	if spawner.has_signal("boss_warning_started") and hud.has_method("show_boss_warning"):
		spawner.boss_warning_started.connect(hud.show_boss_warning)


func _physics_process(delta: float) -> void:
	if state != GameState.PLAYING:
		return

	elapsed_time += delta
	GameData.elapsed_time = elapsed_time

	hud.update_time(elapsed_time)
	hud.update_kills(GameData.total_kills)

	if GameData.is_stage_mode():
		_check_stage_conditions()
	else:
		if elapsed_time >= _game_duration:
			_victory()
			return

	_check_enemy_contact()

	_cleanup_timer -= delta
	if _cleanup_timer <= 0:
		_cleanup_timer = 2.0
		_cleanup_distant_enemies()

	_chest_timer += delta
	if _chest_timer >= _next_chest_interval:
		_chest_timer = 0.0
		_next_chest_interval = randf_range(GameData.CHEST_SPAWN_INTERVAL_MIN, GameData.CHEST_SPAWN_INTERVAL_MAX)
		_spawn_random_chest()

	_update_world_events(delta)


func _check_stage_conditions() -> void:
	var cond: String = _stage_data.get("win_condition", "survive")
	var val: int = _stage_data.get("win_value", 0)

	match cond:
		"kills":
			if GameData.total_kills >= val:
				_victory()
				return
			if elapsed_time >= _game_duration:
				_on_player_died()
				return
		"survive":
			if elapsed_time >= float(val):
				_victory()
				return
		"boss":
			if GameData.boss_kills_this_stage >= val:
				_victory()
				return
			if elapsed_time >= _game_duration:
				_on_player_died()
				return


func _process(delta: float) -> void:
	if _shake_timer > 0:
		_shake_timer -= delta
		if camera:
			camera.offset = Vector2(
				randf_range(-_shake_amount, _shake_amount),
				randf_range(-_shake_amount, _shake_amount)
			)
			if _shake_timer <= 0:
				camera.offset = Vector2.ZERO


func _check_enemy_contact() -> void:
	if not is_instance_valid(player) or player.invincible or _god_mode:
		return
	var ppos := player.global_position
	# Boss 半径最大 56，需扩大查询半径
	var max_contact: float = player.hit_radius + 70.0
	for enemy in SpatialGrid.get_nearby(ppos, max_contact):
		if not is_instance_valid(enemy):
			continue
		# 登场期 Boss 不造成接触伤害
		if enemy.get("_entering"):
			continue
		var contact_dist: float = player.hit_radius + enemy.enemy_size
		if ppos.distance_squared_to(enemy.global_position) < contact_dist * contact_dist:
			player.take_damage(enemy.damage)
			break


func _cleanup_distant_enemies() -> void:
	if not is_instance_valid(player):
		return
	var ppos := player.global_position
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if ppos.distance_squared_to(enemy.global_position) > 2000.0 * 2000.0:
			enemy.queue_free()


func _spawn_random_chest() -> void:
	if not is_instance_valid(player):
		return
	var angle := randf() * TAU
	var dist := randf_range(150.0, GameData.CHEST_SPAWN_DISTANCE)
	var pos := player.global_position + Vector2(cos(angle), sin(angle)) * dist
	var chest_script := preload("res://scripts/treasure_chest.gd")
	var chest := Node2D.new()
	chest.set_script(chest_script)
	chest.global_position = pos
	chest.setup_random()
	if pickups_container and is_instance_valid(pickups_container):
		pickups_container.add_child(chest)
		AudioManager.play("chest_spawn")


func _update_world_events(delta: float) -> void:
	if not is_instance_valid(player):
		return
	# 1.5min 后才开始（PRD 5.7）
	if elapsed_time < MAP_EVENT_START_TIME:
		return

	# 危险区：每 20-30s 尝试一次（同屏已有则跳过）
	_danger_zone_timer += delta
	if _danger_zone_timer >= _next_danger_interval:
		_danger_zone_timer = 0.0
		_next_danger_interval = randf_range(20.0, 30.0)
		if GameData.is_mobile():
			_next_danger_interval += 8.0
		_try_spawn_danger_zone()

	# 治疗点：每 35-50s 尝试一次（同屏已有则跳过）
	_healing_point_timer += delta
	if _healing_point_timer >= _next_healing_interval:
		_healing_point_timer = 0.0
		_next_healing_interval = randf_range(35.0, 50.0)
		if GameData.is_mobile():
			_next_healing_interval += 10.0
		_try_spawn_healing_point()


func _has_world_event(group: String) -> bool:
	# 检查同屏是否已有该类型的世界事件
	for child in get_children():
		var script: Script = child.get_script()
		if script and script.resource_path.find(group) >= 0:
			return true
	return false


# 玩家 facing 方向 200-400px ±60° 扇形（PRD 5.10.5）
func _get_world_event_position(min_dist: float = 200.0, max_dist: float = 400.0) -> Vector2:
	var base_dir: Vector2 = player.facing if player.facing.length_squared() > 0.01 else Vector2.RIGHT
	var spread: float = deg_to_rad(60.0)
	var ang_offset: float = randf_range(-spread, spread)
	var dir: Vector2 = base_dir.rotated(ang_offset)
	var dist: float = randf_range(min_dist, max_dist)
	return player.global_position + dir * dist


func _try_spawn_danger_zone() -> void:
	if _has_world_event("danger_zone"):
		return
	var zone := Node2D.new()
	zone.set_script(preload("res://scripts/world/danger_zone.gd"))
	zone.global_position = _get_world_event_position(200.0, 400.0)
	add_child(zone)


func _try_spawn_healing_point() -> void:
	if _has_world_event("healing_point"):
		return
	var point := Node2D.new()
	point.set_script(preload("res://scripts/world/healing_point.gd"))
	point.global_position = _get_world_event_position(200.0, 400.0)
	add_child(point)


func _on_player_leveled_up(_new_level: int) -> void:
	_pending_level_ups += 1
	if state == GameState.PLAYING:
		if level_up_panel._auto_pick:
			_auto_level_up()
		else:
			state = GameState.LEVEL_UP
			get_tree().paused = true
			level_up_panel.show_choices(player)


func _auto_level_up() -> void:
	while _pending_level_ups > 0:
		var choices: Array = level_up_panel._generate_choices(player)
		if choices.is_empty():
			break
		var best: Dictionary = choices[0]
		for c in choices:
			if c.get("priority", 0) > best.get("priority", 0):
				best = c
		_apply_choice(best)
		_pending_level_ups -= 1


func _on_level_up_choice(choice: Dictionary) -> void:
	var is_evolve: bool = choice.get("type", "") == "evolve"
	_apply_choice(choice)
	_pending_level_ups = maxi(_pending_level_ups - 1, 0)
	if _pending_level_ups > 0:
		level_up_panel.show_choices(player)
		return
	state = GameState.PLAYING
	level_up_panel.visible = false
	get_tree().paused = false
	if is_evolve:
		AudioManager.play("level_up")
		VfxPool.screen_flash(Color(1.0, 0.9, 0.3, 0.25), 0.15)
		shake_camera(5.0)


func _apply_choice(choice: Dictionary) -> void:
	match choice["type"]:
		"new_weapon":
			player.add_weapon(choice["weapon_type"])
		"upgrade_weapon":
			player.upgrade_weapon(choice["weapon_type"])
		"evolve":
			player.evolve_weapon(choice["weapon_type"])
		"stat":
			match choice["stat"]:
				"max_health":
					player.max_health += 20
					player.heal(20)
				"speed":
					player.speed_mult += 0.1
				"damage":
					player.damage_mult += 0.1
				"area":
					player.area_mult += 0.1
				"cooldown":
					player.cooldown_mult = maxf(0.3, player.cooldown_mult - 0.08)
				"pickup_range":
					player.pickup_range_mult += 0.2


func _on_player_hurt(_amount: int) -> void:
	_shake_amount = 4.0
	_shake_timer = 0.2


func shake_camera(amount: float = 3.0, duration: float = 0.15) -> void:
	_shake_amount = maxf(_shake_amount, amount)
	_shake_timer = maxf(_shake_timer, duration)


func _on_player_died() -> void:
	if state == GameState.GAME_OVER or state == GameState.VICTORY:
		return
	state = GameState.GAME_OVER
	get_tree().paused = true
	AudioManager.stop_bgm()
	_update_global_stats()
	game_over_screen.show_results(elapsed_time, GameData.total_kills, player.level, false)


func _victory() -> void:
	if state == GameState.VICTORY:
		return
	state = GameState.VICTORY
	get_tree().paused = true
	AudioManager.stop_bgm()
	if GameData.is_stage_mode():
		GameData.clear_stage(GameData.current_stage)
	_update_global_stats()
	var newly_unlocked: Array = GameData.check_character_unlocks()
	game_over_screen.show_results(elapsed_time, GameData.total_kills, player.level, true)
	if not newly_unlocked.is_empty():
		_show_unlock_notification(newly_unlocked)


func _update_global_stats() -> void:
	GameData.total_kills_all_time += GameData.total_kills
	if not GameData.is_stage_mode() and elapsed_time > GameData.best_free_survival:
		GameData.best_free_survival = elapsed_time
	GameData.save_game()


func _show_unlock_notification(char_ids: Array) -> void:
	for char_id in char_ids:
		var data: Dictionary = GameData.CHARACTER_DATA.get(char_id, {})
		if data.is_empty():
			continue
		var lbl := Label.new()
		lbl.text = "新角色解锁: %s" % data.get("name", "")
		lbl.add_theme_font_size_override("font_size", 22)
		lbl.add_theme_color_override("font_color", GameData.UI_GOLD)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.set_anchors_preset(Control.PRESET_CENTER_TOP)
		lbl.position.y = 80
		lbl.modulate.a = 0.0
		var layer := CanvasLayer.new()
		layer.layer = 20
		layer.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(layer)
		layer.add_child(lbl)
		var tw := lbl.create_tween()
		tw.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
		tw.tween_property(lbl, "modulate:a", 1.0, 0.5)
		tw.tween_interval(3.0)
		tw.tween_property(lbl, "modulate:a", 0.0, 1.0)
		tw.tween_callback(layer.queue_free)


func _on_retry() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_main_menu() -> void:
	get_tree().paused = false
	GameData.current_stage = 0
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_next_stage() -> void:
	var next_id: int = GameData.current_stage + 1
	if GameData.STAGE_DATA.has(next_id) and GameData.unlocked_stages.has(next_id):
		GameData.current_stage = next_id
		var data: Dictionary = GameData.STAGE_DATA.get(next_id, {})
		GameData.bg_style = data.get("bg_style", "grassland")
		get_tree().paused = false
		get_tree().reload_current_scene()
	else:
		_on_stage_select()


func _on_stage_select() -> void:
	get_tree().paused = false
	GameData.current_stage = 0
	get_tree().change_scene_to_file("res://scenes/stage_select.tscn")


func _toggle_pause() -> void:
	if state == GameState.PLAYING:
		state = GameState.PAUSED
		get_tree().paused = true
		pause_menu.show_pause()
	elif state == GameState.PAUSED:
		_on_resume()


func _on_resume() -> void:
	state = GameState.PLAYING
	get_tree().paused = false
	pause_menu.hide_pause()


# --- Debug System ---

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed):
		return

	if event.keycode == KEY_ESCAPE:
		if state == GameState.PLAYING or state == GameState.PAUSED:
			_toggle_pause()
			get_viewport().set_input_as_handled()
		return

	if not OS.is_debug_build():
		return

	if event.keycode == KEY_QUOTELEFT:
		_debug_toggle_panel()
		return

	if not event.ctrl_pressed:
		return

	match event.keycode:
		KEY_1:
			_debug_spawn_wave()
		KEY_2:
			_debug_spawn_boss()
		KEY_3:
			_debug_level_up()
		KEY_4:
			_debug_all_weapons()
		KEY_5:
			_debug_toggle_god_mode()
		KEY_6:
			_debug_kill_all()
		KEY_7:
			_debug_full_heal()
		KEY_8:
			_debug_restart()
		KEY_9:
			_debug_reset_player()


func _debug_spawn_wave() -> void:
	if not is_instance_valid(player):
		return
	var difficulty := GameData.get_difficulty_multiplier(elapsed_time)
	for type_key in GameData.ENEMY_TYPES.keys():
		if type_key == "boss":
			continue
		for i in range(5):
			_debug_spawn_single(type_key, difficulty)


func _debug_spawn_boss() -> void:
	# 兼容 Ctrl+2 快捷键：默认生成骸骨领主 + 标准模式
	_debug_spawn_boss_specific("bone_lord", "standard")


# Boss 调试生成（PRD 配套）：mode 取值 full / standard / instant
func _debug_spawn_boss_specific(boss_id: String, mode: String = "standard") -> void:
	if not is_instance_valid(player):
		return
	if not GameData.BOSS_DATA.has(boss_id):
		return

	var spawn_distance: float
	var skip_entering: bool
	match mode:
		"full":
			spawn_distance = 800.0
			skip_entering = false
		"instant":
			spawn_distance = 300.0
			skip_entering = true
		_:  # standard
			spawn_distance = 300.0
			skip_entering = false

	var difficulty := GameData.get_difficulty_multiplier(elapsed_time)
	var angle := randf() * TAU
	var dir_vec := Vector2(cos(angle), sin(angle))
	var spawn_pos: Vector2 = player.global_position + dir_vec * spawn_distance
	var target_pos: Vector2 = player.global_position + dir_vec * 200.0

	var boss := Node2D.new()
	boss.set_script(preload("res://scripts/boss_enemy.gd"))
	boss.global_position = spawn_pos
	boss._enter_start_pos = spawn_pos
	boss._enter_target_pos = target_pos

	if enemies_container and is_instance_valid(enemies_container):
		enemies_container.add_child(boss)
		boss.setup_boss(boss_id, difficulty)
		if skip_entering:
			# 立即结束登场期
			boss._entering = false
			boss._enter_timer = 0.0
			boss._enter_shockwave_done = true
			boss._enter_title_shown = true
			boss._enter_darken_shown = true
			boss.global_position = target_pos
		AudioManager.start_boss_bgm()


func _debug_spawn_single(type_key: String, difficulty: float) -> void:
	var angle := randf() * TAU
	var spawn_pos := player.global_position + Vector2(cos(angle), sin(angle)) * 300.0
	var enemy := Node2D.new()
	enemy.set_script(preload("res://scripts/enemy.gd"))
	enemy.global_position = spawn_pos
	if enemies_container and is_instance_valid(enemies_container):
		enemies_container.add_child(enemy)
		enemy.setup(type_key, difficulty)


func _debug_level_up() -> void:
	if not is_instance_valid(player):
		return
	player.add_xp(GameData.get_xp_for_level(player.level))


func _debug_all_weapons() -> void:
	if not is_instance_valid(player):
		return
	for wt in GameData.WEAPON_DATA.keys():
		var wd: Dictionary = GameData.WEAPON_DATA[wt]
		if wd.get("is_evolution", false):
			continue
		if player.has_weapon(wt):
			player.upgrade_weapon(wt)
		else:
			player.add_weapon(wt)


func _debug_toggle_god_mode() -> void:
	_god_mode = not _god_mode
	if is_instance_valid(player):
		player.invincible = _god_mode
		if _god_mode:
			player._invincible_timer = 999999.0


func _debug_kill_all() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.take_damage(99999.0)


func _debug_full_heal() -> void:
	if is_instance_valid(player):
		player.heal(player.max_health)


func _debug_toggle_panel() -> void:
	if debug_panel:
		debug_panel.visible = not debug_panel.visible


func _debug_restart() -> void:
	Engine.time_scale = 1.0
	_god_mode = false
	get_tree().paused = false
	get_tree().reload_current_scene()


func _debug_reset_player() -> void:
	if not is_instance_valid(player):
		return
	_god_mode = false
	var cd: Dictionary = GameData.get_character_data()
	player.max_health = cd.get("max_health", 100)
	player.current_health = player.max_health
	player.speed_mult = 1.0
	player.damage_mult = cd.get("damage_mult", 1.0)
	player.area_mult = 1.0
	player.cooldown_mult = cd.get("cooldown_mult", 1.0)
	player.pickup_range_mult = cd.get("pickup_mult", 1.0)
	player.armor = 0
	player.invincible = false
	player._invincible_timer = 0.0
	player.health_changed.emit(player.current_health, player.max_health)
	Engine.time_scale = 1.0
