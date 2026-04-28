extends Control

var _enemy_count_label: Label
var _fps_label: Label
var _time_label: Label
var _god_mode_btn: Button
var _spawn_count_slider: HSlider
var _spawn_count_label: Label
var _time_scale_slider: HSlider
var _time_scale_label: Label
var _weapon_buttons: Dictionary = {}

var _game_manager: Node = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	theme = GameData.pixel_theme
	_build_ui()


func set_game_manager(gm: Node) -> void:
	_game_manager = gm


func _process(_delta: float) -> void:
	if not visible:
		return
	_enemy_count_label.text = "敌人数: %d" % get_tree().get_nodes_in_group("enemies").size()
	_fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
	var t := GameData.elapsed_time
	_time_label.text = "时间: %02d:%02d" % [int(t) / 60, int(t) % 60]

	if _game_manager:
		_god_mode_btn.text = "无敌: [开]" if _game_manager._god_mode else "无敌: [关]"

	var p := GameData.player_ref
	if is_instance_valid(p):
		for wt_key in _weapon_buttons:
			var btn: Button = _weapon_buttons[wt_key]
			if p.is_weapon_consumed(wt_key):
				btn.disabled = true
				btn.tooltip_text = "已合成为超级武器"
			else:
				btn.disabled = false
				btn.tooltip_text = ""


func _build_ui() -> void:
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	panel.anchor_left = 0.72
	panel.mouse_filter = Control.MOUSE_FILTER_STOP

	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.04, 0.04, 0.08, 0.92)
	bg.set_corner_radius_all(0)
	bg.border_color = GameData.UI_GOLD
	bg.border_color.a = 0.6
	bg.border_width_left = GameData.PX * 2
	bg.border_width_top = 0
	bg.border_width_bottom = 0
	bg.border_width_right = 0
	bg.set_content_margin_all(8)
	panel.add_theme_stylebox_override("panel", bg)
	add_child(panel)

	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox)

	# Header
	var header := Label.new()
	header.text = "[ DEBUG ]"
	header.add_theme_font_size_override("font_size", 24)
	header.add_theme_color_override("font_color", GameData.UI_GOLD)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(header)

	_add_sep(vbox, GameData.UI_GOLD, 0.3)

	_add_section_title(vbox, "信息")
	_enemy_count_label = _add_info_label(vbox, "敌人数: 0")
	_fps_label = _add_info_label(vbox, "FPS: 0")
	_time_label = _add_info_label(vbox, "时间: 00:00")

	_add_sep(vbox, GameData.UI_BORDER, 0.3)
	_add_section_title(vbox, "怪物生成")

	var count_row := HBoxContainer.new()
	count_row.add_theme_constant_override("separation", 4)
	vbox.add_child(count_row)
	var count_lbl := _add_info_label(count_row, "数量:")
	count_lbl.custom_minimum_size.x = 48
	_spawn_count_slider = HSlider.new()
	_spawn_count_slider.min_value = 1
	_spawn_count_slider.max_value = 50
	_spawn_count_slider.value = 5
	_spawn_count_slider.step = 1
	_spawn_count_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_spawn_count_slider.custom_minimum_size.x = 80
	_spawn_count_slider.value_changed.connect(_on_spawn_count_changed)
	count_row.add_child(_spawn_count_slider)
	_spawn_count_label = _add_info_label(count_row, "5")
	_spawn_count_label.custom_minimum_size.x = 28

	for type_key in GameData.ENEMY_TYPES.keys():
		var data: Dictionary = GameData.ENEMY_TYPES[type_key]
		var btn := Button.new()
		btn.text = "> " + data["name"]
		btn.custom_minimum_size.y = 28
		btn.pressed.connect(_on_spawn_enemy.bind(type_key))
		vbox.add_child(btn)

	_add_sep(vbox, GameData.UI_BORDER, 0.3)
	_add_section_title(vbox, "武器")

	for wt in GameData.WEAPON_DATA.keys():
		var data: Dictionary = GameData.WEAPON_DATA[wt]
		if data.get("is_evolution", false):
			continue
		var btn := Button.new()
		btn.text = "> " + data["name"]
		btn.custom_minimum_size.y = 28
		btn.pressed.connect(_on_weapon_btn.bind(wt))
		vbox.add_child(btn)
		_weapon_buttons[wt] = btn

	_add_sep(vbox, Color(1.0, 0.6, 0.0), 0.5)
	_add_section_title(vbox, "超级武器")

	var max_all_btn := Button.new()
	max_all_btn.text = ">> 基础武器全满级 <<"
	max_all_btn.custom_minimum_size.y = 28
	max_all_btn.pressed.connect(_on_max_all_base)
	vbox.add_child(max_all_btn)

	for wt in GameData.WEAPON_DATA.keys():
		var data: Dictionary = GameData.WEAPON_DATA[wt]
		if not data.get("is_evolution", false):
			continue
		var recipe: Array = GameData.EVOLUTION_RECIPES.get(wt, [])
		var src_names := ""
		for rt in recipe:
			if src_names != "":
				src_names += "+"
			src_names += GameData.WEAPON_DATA[rt]["name"]
		var btn := Button.new()
		btn.text = "> %s (%s)" % [data["name"], src_names]
		btn.custom_minimum_size.y = 28
		btn.pressed.connect(_on_evolve_btn.bind(wt))
		vbox.add_child(btn)

	_add_sep(vbox, GameData.UI_BORDER, 0.3)
	_add_section_title(vbox, "玩家属性")

	_add_slider_row(vbox, "血量", 10, 500, 100, _on_health_changed)
	_add_slider_row(vbox, "速度", 0.5, 5.0, 1.0, _on_speed_changed)
	_add_slider_row(vbox, "伤害", 0.5, 10.0, 1.0, _on_damage_changed)

	_add_sep(vbox, GameData.UI_BORDER, 0.3)
	_add_section_title(vbox, "游戏控制")

	_god_mode_btn = Button.new()
	_god_mode_btn.text = "无敌: [关]"
	_god_mode_btn.custom_minimum_size.y = 28
	_god_mode_btn.pressed.connect(_on_god_mode)
	vbox.add_child(_god_mode_btn)

	var kill_btn := Button.new()
	kill_btn.text = "秒杀全屏"
	kill_btn.custom_minimum_size.y = 28
	kill_btn.pressed.connect(_on_kill_all)
	vbox.add_child(kill_btn)

	var heal_btn := Button.new()
	heal_btn.text = "回满血"
	heal_btn.custom_minimum_size.y = 28
	heal_btn.pressed.connect(_on_full_heal)
	vbox.add_child(heal_btn)

	var lvl_btn := Button.new()
	lvl_btn.text = "触发升级"
	lvl_btn.custom_minimum_size.y = 28
	lvl_btn.pressed.connect(_on_level_up)
	vbox.add_child(lvl_btn)

	var chest_btn := Button.new()
	chest_btn.text = "生成宝箱"
	chest_btn.custom_minimum_size.y = 28
	chest_btn.pressed.connect(_on_spawn_chest)
	vbox.add_child(chest_btn)

	var chest_epic_btn := Button.new()
	chest_epic_btn.text = "生成金色宝箱"
	chest_epic_btn.custom_minimum_size.y = 28
	chest_epic_btn.pressed.connect(_on_spawn_epic_chest)
	vbox.add_child(chest_epic_btn)

	var ts_row := HBoxContainer.new()
	ts_row.add_theme_constant_override("separation", 4)
	vbox.add_child(ts_row)
	var ts_lbl := _add_info_label(ts_row, "倍速:")
	ts_lbl.custom_minimum_size.x = 48
	_time_scale_slider = HSlider.new()
	_time_scale_slider.min_value = 0.25
	_time_scale_slider.max_value = 5.0
	_time_scale_slider.value = 1.0
	_time_scale_slider.step = 0.25
	_time_scale_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_time_scale_slider.custom_minimum_size.x = 64
	_time_scale_slider.value_changed.connect(_on_time_scale_changed)
	ts_row.add_child(_time_scale_slider)
	_time_scale_label = _add_info_label(ts_row, "1.0x")
	_time_scale_label.custom_minimum_size.x = 48

	_add_sep(vbox, GameData.UI_RED, 0.3)

	_add_section_title(vbox, "素材风格")
	for style_key: String in preload("res://scripts/sprite_loader.gd").STYLES:
		var label: String = preload("res://scripts/sprite_loader.gd").STYLES[style_key]
		var btn := Button.new()
		btn.text = "> " + label
		btn.custom_minimum_size.y = 28
		btn.pressed.connect(_on_switch_style.bind(style_key))
		vbox.add_child(btn)

	_add_sep(vbox, GameData.UI_BLUE, 0.3)

	_add_section_title(vbox, "地板风格")
	for bg_key: String in preload("res://scripts/bg_tile_gen.gd").BG_STYLES:
		var bg_label: String = preload("res://scripts/bg_tile_gen.gd").BG_STYLES[bg_key]
		var btn := Button.new()
		btn.text = "> " + bg_label
		btn.custom_minimum_size.y = 28
		btn.pressed.connect(_on_switch_bg.bind(bg_key))
		vbox.add_child(btn)

	_add_sep(vbox, Color(0.6, 0.3, 0.9), 0.3)

	_add_section_title(vbox, "背景音乐")
	for bgm_key: String in AudioManager.BGM_STYLES:
		var bgm_label: String = AudioManager.BGM_STYLES[bgm_key]
		var btn := Button.new()
		btn.text = "> " + bgm_label
		btn.custom_minimum_size.y = 28
		btn.pressed.connect(_on_switch_bgm.bind(bgm_key))
		vbox.add_child(btn)

	_add_sep(vbox, GameData.UI_RED, 0.3)

	var restart_btn := Button.new()
	restart_btn.text = ">> 重新开始 <<"
	restart_btn.custom_minimum_size.y = 28
	restart_btn.pressed.connect(_on_restart)
	vbox.add_child(restart_btn)

	var reset_btn := Button.new()
	reset_btn.text = "恢复默认配置"
	reset_btn.custom_minimum_size.y = 28
	reset_btn.pressed.connect(_on_reset_player)
	vbox.add_child(reset_btn)

	_add_sep(vbox, GameData.UI_BORDER, 0.2)

	var hint := _add_info_label(vbox, "` 面板 | Ctrl+1~9")
	hint.add_theme_color_override("font_color", GameData.UI_TEXT_DIM)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


func _add_section_title(parent: Control, text: String) -> Label:
	var label := Label.new()
	label.text = "[ " + text + " ]"
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", GameData.UI_GOLD)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(label)
	return label


func _add_info_label(parent: Control, text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 12)
	parent.add_child(label)
	return label


func _add_sep(parent: Control, color: Color, alpha: float) -> void:
	var sep := ColorRect.new()
	sep.custom_minimum_size = Vector2(0, GameData.PX)
	sep.color = color
	sep.color.a = alpha
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(sep)


func _add_slider_row(parent: Control, label_text: String, min_val: float, max_val: float, default_val: float, callback: Callable) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	parent.add_child(row)
	var lbl := _add_info_label(row, label_text + ":")
	lbl.custom_minimum_size.x = 48
	var slider := HSlider.new()
	slider.min_value = min_val
	slider.max_value = max_val
	slider.value = default_val
	slider.step = 0.1 if max_val <= 10.0 else 10.0
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.custom_minimum_size.x = 64
	slider.value_changed.connect(callback)
	row.add_child(slider)
	var val_label := Label.new()
	val_label.text = str(default_val)
	val_label.add_theme_font_size_override("font_size", 12)
	val_label.custom_minimum_size.x = 36
	row.add_child(val_label)
	slider.value_changed.connect(func(v: float) -> void: val_label.text = "%.1f" % v)


# --- Callbacks ---

func _on_spawn_count_changed(value: float) -> void:
	_spawn_count_label.text = str(int(value))


func _on_spawn_enemy(type_key: String) -> void:
	if not _game_manager or not is_instance_valid(GameData.player_ref):
		return
	var count := int(_spawn_count_slider.value)
	var difficulty := GameData.get_difficulty_multiplier(GameData.elapsed_time)
	for i in range(count):
		_game_manager._debug_spawn_single(type_key, difficulty)


func _on_weapon_btn(wt: int) -> void:
	var p := GameData.player_ref
	if not is_instance_valid(p):
		return
	var wd: Dictionary = GameData.WEAPON_DATA[wt]
	if wd.get("is_evolution", false):
		return
	if p.is_weapon_consumed(wt):
		return
	if p.has_weapon(wt):
		p.upgrade_weapon(wt)
	else:
		p.add_weapon(wt)


func _on_evolve_btn(evo_type: int) -> void:
	var p := GameData.player_ref
	if not is_instance_valid(p):
		return
	if p.has_weapon(evo_type):
		return
	var recipe: Array = GameData.EVOLUTION_RECIPES.get(evo_type, [])
	for base_type in recipe:
		if not p.has_weapon(base_type):
			p.add_weapon(base_type)
		while p.get_weapon_level(base_type) < 8:
			p.upgrade_weapon(base_type)
	p.evolve_weapon(evo_type)


func _on_max_all_base() -> void:
	var p := GameData.player_ref
	if not is_instance_valid(p):
		return
	for wt in GameData.WEAPON_DATA.keys():
		var wd: Dictionary = GameData.WEAPON_DATA[wt]
		if wd.get("is_evolution", false):
			continue
		if p.is_weapon_consumed(wt):
			continue
		if not p.has_weapon(wt):
			p.add_weapon(wt)
		while p.get_weapon_level(wt) < 8:
			p.upgrade_weapon(wt)


func _on_health_changed(value: float) -> void:
	var p := GameData.player_ref
	if not is_instance_valid(p):
		return
	p.max_health = int(value)
	p.current_health = mini(p.current_health, p.max_health)
	p.health_changed.emit(p.current_health, p.max_health)


func _on_speed_changed(value: float) -> void:
	var p := GameData.player_ref
	if is_instance_valid(p):
		p.speed_mult = value


func _on_damage_changed(value: float) -> void:
	var p := GameData.player_ref
	if is_instance_valid(p):
		p.damage_mult = value


func _on_god_mode() -> void:
	if _game_manager:
		_game_manager._debug_toggle_god_mode()


func _on_kill_all() -> void:
	if _game_manager:
		_game_manager._debug_kill_all()


func _on_full_heal() -> void:
	if _game_manager:
		_game_manager._debug_full_heal()


func _on_level_up() -> void:
	if _game_manager:
		_game_manager._debug_level_up()


func _on_spawn_chest() -> void:
	if _game_manager:
		_game_manager._spawn_random_chest()


func _on_spawn_epic_chest() -> void:
	var p := GameData.player_ref
	if not is_instance_valid(p):
		return
	var chest_script := preload("res://scripts/treasure_chest.gd")
	var chest := Node2D.new()
	chest.set_script(chest_script)
	chest.global_position = p.global_position + Vector2(randf_range(-60, 60), randf_range(-60, 60))
	chest.rarity = chest_script.ChestRarity.EPIC
	var container := GameData.pickups_container
	if container and is_instance_valid(container):
		container.add_child(chest)
		AudioManager.play("chest_spawn")


func _on_time_scale_changed(value: float) -> void:
	Engine.time_scale = value
	_time_scale_label.text = "%.2fx" % value


func _on_restart() -> void:
	if _game_manager:
		_game_manager._debug_restart()


func _on_reset_player() -> void:
	if _game_manager:
		_game_manager._debug_reset_player()
		_time_scale_slider.value = 1.0


func _on_switch_style(style_key: String) -> void:
	GameData.switch_style(style_key)
	get_tree().reload_current_scene()


func _on_switch_bg(bg_key: String) -> void:
	GameData.bg_style = bg_key
	var bg_node := get_tree().get_first_node_in_group("background")
	if bg_node and bg_node.has_method("load_style"):
		bg_node.load_style(bg_key)
	else:
		get_tree().reload_current_scene()


func _on_switch_bgm(bgm_key: String) -> void:
	AudioManager.switch_bgm(bgm_key)
