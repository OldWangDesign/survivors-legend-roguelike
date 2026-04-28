extends Control

signal choice_made(choice: Dictionary)

var _choices: Array = []
var _countdown: float = 0.0
var _countdown_label: Label = null
var _auto_pick: bool = false
var _choice_locked: bool = false

const AUTO_PICK_DELAY := 5.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_preset(Control.PRESET_FULL_RECT)
	theme = GameData.pixel_theme


func show_choices(player: CharacterBody2D) -> void:
	_choices = _generate_choices(player)
	_countdown = AUTO_PICK_DELAY
	_choice_locked = false
	_build_ui()
	visible = true


func _process(delta: float) -> void:
	if not visible or _choices.is_empty():
		return
	_countdown -= delta
	if _countdown_label:
		var secs := ceili(_countdown)
		_countdown_label.text = "自动选择: %ds" % secs
	if _countdown <= 0:
		_auto_select_best()


func _auto_select_best() -> void:
	if _choices.is_empty():
		return
	var best_idx := 0
	var best_prio := -1
	for i in range(_choices.size()):
		var p: int = _choices[i].get("priority", 0)
		if p > best_prio:
			best_prio = p
			best_idx = i
	_on_choice(best_idx)


func set_auto_pick(enabled: bool) -> void:
	_auto_pick = enabled


func _generate_choices(player: CharacterBody2D) -> Array:
	var pool: Array = []

	if player.has_method("get_available_evolutions"):
		var evolutions: Array = player.get_available_evolutions()
		for evo_type in evolutions:
			var data: Dictionary = GameData.WEAPON_DATA[evo_type]
			var recipe: Array = GameData.EVOLUTION_RECIPES[evo_type]
			var src_a: String = GameData.WEAPON_DATA[recipe[0]]["name"]
			var src_b: String = GameData.WEAPON_DATA[recipe[1]]["name"]
			pool.append({
				"type": "evolve",
				"weapon_type": evo_type,
				"name": data["name"] + " [合成!]",
				"description": src_a + " + " + src_b + " → " + data["description"],
				"color": data["icon_color"],
				"priority": 10,
			})

	for wt in GameData.WEAPON_DATA.keys():
		var wd: Dictionary = GameData.WEAPON_DATA[wt]
		if wd.get("is_evolution", false):
			continue
		if player.is_weapon_consumed(wt):
			continue
		if not player.has_weapon(wt):
			pool.append({
				"type": "new_weapon",
				"weapon_type": wt,
				"name": wd["name"] + " (新!)",
				"description": wd["description"],
				"color": wd["icon_color"],
				"priority": 2,
			})

	for w in player.weapons:
		if w["level"] < 8:
			var wt: int = w["type"]
			var data: Dictionary = GameData.WEAPON_DATA[wt]
			pool.append({
				"type": "upgrade_weapon",
				"weapon_type": wt,
				"name": data["name"] + " Lv.%d→%d" % [w["level"], w["level"] + 1],
				"description": data["description"],
				"color": data["icon_color"],
				"priority": 3,
			})

	var stat_opts := [
		{"type": "stat", "stat": "max_health", "name": "生命 +20", "description": "增加最大生命值", "color": GameData.UI_RED},
		{"type": "stat", "stat": "speed", "name": "移速 +10%", "description": "提升移动速度", "color": Color.SKY_BLUE},
		{"type": "stat", "stat": "damage", "name": "伤害 +10%", "description": "提升武器伤害", "color": Color.ORANGE_RED},
		{"type": "stat", "stat": "area", "name": "范围 +10%", "description": "增加攻击范围", "color": Color.PURPLE},
		{"type": "stat", "stat": "cooldown", "name": "冷却 -8%", "description": "降低冷却时间", "color": GameData.UI_GREEN},
		{"type": "stat", "stat": "pickup_range", "name": "拾取 +20%", "description": "增加拾取范围", "color": GameData.UI_GOLD},
	]
	for s in stat_opts:
		var opt: Dictionary = s.duplicate()
		opt["priority"] = 1
		pool.append(opt)

	pool.shuffle()
	pool.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["priority"] > b["priority"])
	return pool.slice(0, 3)


func _build_ui() -> void:
	for child in get_children():
		child.queue_free()
	_countdown_label = null

	var overlay := ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.75)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var main_vbox := VBoxContainer.new()
	main_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_theme_constant_override("separation", 12)
	center.add_child(main_vbox)

	var title_panel := PanelContainer.new()
	var tp_style := StyleBoxFlat.new()
	tp_style.bg_color = Color(0.08, 0.06, 0.15, 0.9)
	tp_style.border_color = GameData.UI_GOLD
	tp_style.border_width_top = GameData.PX
	tp_style.border_width_left = GameData.PX
	tp_style.border_width_bottom = GameData.PX * 2
	tp_style.border_width_right = GameData.PX * 2
	tp_style.set_corner_radius_all(0)
	tp_style.set_content_margin_all(12)
	tp_style.shadow_color = Color(1.0, 0.84, 0, 0.08)
	tp_style.shadow_size = GameData.PX * 4
	title_panel.add_theme_stylebox_override("panel", tp_style)
	main_vbox.add_child(title_panel)

	var title_inner := HBoxContainer.new()
	title_inner.alignment = BoxContainer.ALIGNMENT_CENTER
	title_inner.add_theme_constant_override("separation", 12)
	title_panel.add_child(title_inner)

	var deco_l := Label.new()
	deco_l.text = ">>>"
	deco_l.add_theme_font_size_override("font_size", 20)
	deco_l.add_theme_color_override("font_color", GameData.UI_GOLD.darkened(0.3))
	title_inner.add_child(deco_l)

	var title := Label.new()
	title.text = "LEVEL UP"
	title.add_theme_font_size_override("font_size", 32)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", GameData.UI_GOLD)
	title_inner.add_child(title)

	var deco_r := Label.new()
	deco_r.text = "<<<"
	deco_r.add_theme_font_size_override("font_size", 20)
	deco_r.add_theme_color_override("font_color", GameData.UI_GOLD.darkened(0.3))
	title_inner.add_child(deco_r)

	var hint_row := HBoxContainer.new()
	hint_row.alignment = BoxContainer.ALIGNMENT_CENTER
	hint_row.add_theme_constant_override("separation", 24)
	main_vbox.add_child(hint_row)

	var hint := Label.new()
	hint.text = "[ 1 ]  [ 2 ]  [ 3 ]"
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", GameData.UI_TEXT_DIM)
	hint_row.add_child(hint)

	_countdown_label = Label.new()
	_countdown_label.text = "自动选择: %ds" % ceili(_countdown)
	_countdown_label.add_theme_font_size_override("font_size", 12)
	_countdown_label.add_theme_color_override("font_color", Color(1.0, 0.7, 0.3))
	hint_row.add_child(_countdown_label)

	var cards := HBoxContainer.new()
	cards.alignment = BoxContainer.ALIGNMENT_CENTER
	cards.add_theme_constant_override("separation", 16)
	main_vbox.add_child(cards)

	for i in range(_choices.size()):
		cards.add_child(_create_card(_choices[i], i))

	# Auto-pick toggle button
	var auto_row := HBoxContainer.new()
	auto_row.alignment = BoxContainer.ALIGNMENT_CENTER
	auto_row.add_theme_constant_override("separation", 8)
	main_vbox.add_child(auto_row)

	var auto_btn := CheckButton.new()
	auto_btn.text = "自动选择最佳技能"
	auto_btn.button_pressed = _auto_pick
	auto_btn.add_theme_font_size_override("font_size", 14)
	auto_btn.toggled.connect(_on_auto_toggle)
	auto_row.add_child(auto_btn)


func _create_card(choice: Dictionary, index: int) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(210, 280)

	var accent: Color = choice.get("color", Color.WHITE)
	var is_evo: bool = choice.get("type", "") == "evolve"
	var style := StyleBoxFlat.new()
	if is_evo:
		style.bg_color = Color(0.12, 0.05, 0.18, 0.97)
		style.border_color = GameData.UI_GOLD
		style.border_width_top = GameData.PX * 2
		style.border_width_left = GameData.PX * 2
		style.border_width_bottom = GameData.PX * 3
		style.border_width_right = GameData.PX * 3
		style.shadow_color = Color(1.0, 0.84, 0.0, 0.2)
		style.shadow_size = GameData.PX * 6
	else:
		style.bg_color = Color(0.07, 0.07, 0.13, 0.95)
		style.border_color = accent.darkened(0.2)
		style.border_width_top = GameData.PX
		style.border_width_left = GameData.PX
		style.border_width_bottom = GameData.PX * 2
		style.border_width_right = GameData.PX * 2
		style.shadow_color = Color(accent.r, accent.g, accent.b, 0.1)
		style.shadow_size = GameData.PX * 3
	style.set_corner_radius_all(0)
	style.set_content_margin_all(12)
	style.shadow_offset = Vector2(0, 0)
	panel.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	var num_label := Label.new()
	num_label.text = "[ %d ]" % (index + 1)
	num_label.add_theme_font_size_override("font_size", 12)
	num_label.add_theme_color_override("font_color", GameData.UI_TEXT_DIM)
	num_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(num_label)

	if is_evo:
		var evo_tag := Label.new()
		evo_tag.text = "★ 超级合成 ★"
		evo_tag.add_theme_font_size_override("font_size", 14)
		evo_tag.add_theme_color_override("font_color", GameData.UI_GOLD)
		evo_tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(evo_tag)

	var icon_wrap := CenterContainer.new()
	icon_wrap.custom_minimum_size.y = 44
	vbox.add_child(icon_wrap)
	var icon := ColorRect.new()
	icon.custom_minimum_size = Vector2(32, 32)
	icon.color = accent
	icon_wrap.add_child(icon)

	var sep := ColorRect.new()
	sep.custom_minimum_size = Vector2(0, GameData.PX)
	sep.color = accent
	sep.color.a = 0.4
	vbox.add_child(sep)

	var name_label := Label.new()
	name_label.text = choice.get("name", "")
	name_label.add_theme_font_size_override("font_size", 24)
	name_label.add_theme_color_override("font_color", accent.lightened(0.3))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(name_label)

	var desc := Label.new()
	desc.text = choice.get("description", "")
	desc.add_theme_font_size_override("font_size", 12)
	desc.add_theme_color_override("font_color", GameData.UI_TEXT_DIM)
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(desc)

	var sp := Control.new()
	sp.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(sp)

	var btn := Button.new()
	btn.text = "> 选择 <"
	btn.custom_minimum_size.y = 52
	btn.pressed.connect(_on_choice.bind(index))
	btn.mouse_entered.connect(func(): AudioManager.play_ui("ui_hover"))
	vbox.add_child(btn)

	return panel


func _on_choice(index: int) -> void:
	if _choice_locked:
		return
	if index < _choices.size():
		_choice_locked = true
		AudioManager.play_ui("ui_click")
		choice_made.emit(_choices[index])


func _on_auto_toggle(enabled: bool) -> void:
	_auto_pick = enabled
	AudioManager.play_ui("ui_click")
	if _auto_pick:
		_auto_select_best()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				_on_choice(0)
			KEY_2:
				_on_choice(1)
			KEY_3:
				_on_choice(2)
