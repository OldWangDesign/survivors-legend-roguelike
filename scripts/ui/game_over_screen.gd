extends Control

signal retry_pressed
signal menu_pressed
signal next_stage_pressed
signal stage_select_pressed


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_preset(Control.PRESET_FULL_RECT)
	theme = GameData.pixel_theme


func show_results(time: float, kills: int, lvl: int, victory: bool) -> void:
	visible = true
	var rank: int = -1
	if not GameData.is_stage_mode():
		rank = GameData.add_leaderboard_entry(time, kills, lvl)
	_build_ui(time, kills, lvl, victory, rank)


func _build_ui(time: float, kills: int, lvl: int, victory: bool, rank: int = -1) -> void:
	for child in get_children():
		child.queue_free()

	var overlay := ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.8)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var accent: Color = GameData.UI_GOLD if victory else GameData.UI_RED

	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.07, 0.13, 0.95)
	style.border_color = accent.darkened(0.15)
	style.border_width_top = GameData.PX
	style.border_width_left = GameData.PX
	style.border_width_bottom = GameData.PX * 2
	style.border_width_right = GameData.PX * 2
	style.set_corner_radius_all(0)
	style.set_content_margin_all(28)
	style.shadow_color = Color(accent.r, accent.g, accent.b, 0.1)
	style.shadow_size = GameData.PX * 5
	style.shadow_offset = Vector2(0, 0)
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var title_row := HBoxContainer.new()
	title_row.alignment = BoxContainer.ALIGNMENT_CENTER
	title_row.add_theme_constant_override("separation", 10)
	vbox.add_child(title_row)

	var deco_l := Label.new()
	deco_l.text = ">>>" if victory else "xxx"
	deco_l.add_theme_font_size_override("font_size", 20)
	deco_l.add_theme_color_override("font_color", accent.darkened(0.3))
	title_row.add_child(deco_l)

	var title := Label.new()
	if GameData.is_stage_mode():
		var stage_name: String = GameData.get_stage_data().get("name", "")
		title.text = "%s %s" % [stage_name, "CLEAR" if victory else "FAILED"]
	else:
		title.text = "VICTORY" if victory else "GAME OVER"
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", accent)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_row.add_child(title)

	var deco_r := Label.new()
	deco_r.text = "<<<" if victory else "xxx"
	deco_r.add_theme_font_size_override("font_size", 20)
	deco_r.add_theme_color_override("font_color", accent.darkened(0.3))
	title_row.add_child(deco_r)

	var sep := ColorRect.new()
	sep.custom_minimum_size = Vector2(0, GameData.PX)
	sep.color = accent
	sep.color.a = 0.3
	vbox.add_child(sep)

	var spacer := Control.new()
	spacer.custom_minimum_size.y = 8
	vbox.add_child(spacer)

	# Stats
	var minutes := int(time) / 60
	var seconds := int(time) % 60
	_add_stat(vbox, "存活时间", "%02d:%02d" % [minutes, seconds], GameData.UI_GOLD)
	_add_stat(vbox, "等    级", str(lvl), GameData.UI_BLUE)
	_add_stat(vbox, "击 杀 数", str(kills), GameData.UI_RED)

	if GameData.is_stage_mode() and GameData.get_stage_data().get("win_condition", "") == "boss":
		var bk: int = GameData.boss_kills_this_stage
		var bv: int = GameData.get_stage_data().get("win_value", 0)
		_add_stat(vbox, "Boss击杀", "%d / %d" % [bk, bv], Color.ORANGE_RED)

	if not GameData.is_stage_mode() and rank > 0:
		var rank_label := Label.new()
		if rank == 1:
			rank_label.text = ">> 新纪录! 第 1 名 <<"
			rank_label.add_theme_color_override("font_color", GameData.UI_GOLD)
		elif rank <= 3:
			rank_label.text = "排名: 第 %d 名" % rank
			rank_label.add_theme_color_override("font_color", GameData.UI_BLUE)
		else:
			rank_label.text = "排名: 第 %d 名" % rank
			rank_label.add_theme_color_override("font_color", GameData.UI_TEXT_DIM)
		rank_label.add_theme_font_size_override("font_size", 20)
		rank_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(rank_label)

	if not GameData.is_stage_mode() and GameData.leaderboard.size() > 0:
		_build_leaderboard(vbox)

	var spacer2 := Control.new()
	spacer2.custom_minimum_size.y = 16
	vbox.add_child(spacer2)

	# Buttons
	var btn_col := VBoxContainer.new()
	btn_col.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_col.add_theme_constant_override("separation", 8)
	vbox.add_child(btn_col)

	if GameData.is_stage_mode():
		if victory:
			var next_id: int = GameData.current_stage + 1
			if GameData.STAGE_DATA.has(next_id):
				var next_btn := Button.new()
				next_btn.text = "> 下一关 <"
				next_btn.custom_minimum_size = Vector2(200, 42)
				next_btn.add_theme_font_size_override("font_size", 24)
				next_btn.add_theme_color_override("font_color", GameData.UI_GREEN)
				next_btn.pressed.connect(func() -> void: AudioManager.play_ui("ui_click"); next_stage_pressed.emit())
				next_btn.mouse_entered.connect(func(): AudioManager.play_ui("ui_hover"))
				btn_col.add_child(next_btn)

		var retry_btn := Button.new()
		retry_btn.text = "重试本关" if not victory else "再玩一次"
		retry_btn.custom_minimum_size = Vector2(200, 42)
		retry_btn.add_theme_font_size_override("font_size", 20)
		retry_btn.pressed.connect(func() -> void: AudioManager.play_ui("ui_click"); retry_pressed.emit())
		retry_btn.mouse_entered.connect(func(): AudioManager.play_ui("ui_hover"))
		btn_col.add_child(retry_btn)

		var select_btn := Button.new()
		select_btn.text = "选择关卡"
		select_btn.custom_minimum_size = Vector2(200, 42)
		select_btn.add_theme_font_size_override("font_size", 20)
		select_btn.pressed.connect(func() -> void: AudioManager.play_ui("ui_click"); stage_select_pressed.emit())
		select_btn.mouse_entered.connect(func(): AudioManager.play_ui("ui_hover"))
		btn_col.add_child(select_btn)
	else:
		var btn_row := HBoxContainer.new()
		btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
		btn_row.add_theme_constant_override("separation", 16)
		btn_col.add_child(btn_row)

		var retry_btn := Button.new()
		retry_btn.text = "> 再来一局 <"
		retry_btn.custom_minimum_size = Vector2(140, 42)
		retry_btn.add_theme_font_size_override("font_size", 24)
		retry_btn.pressed.connect(func() -> void: AudioManager.play_ui("ui_click"); retry_pressed.emit())
		retry_btn.mouse_entered.connect(func(): AudioManager.play_ui("ui_hover"))
		btn_row.add_child(retry_btn)

		var menu_btn := Button.new()
		menu_btn.text = "主菜单"
		menu_btn.custom_minimum_size = Vector2(140, 42)
		menu_btn.add_theme_font_size_override("font_size", 24)
		menu_btn.pressed.connect(func() -> void: AudioManager.play_ui("ui_click"); menu_pressed.emit())
		menu_btn.mouse_entered.connect(func(): AudioManager.play_ui("ui_hover"))
		btn_row.add_child(menu_btn)

	var menu_btn2 := Button.new()
	menu_btn2.text = "主菜单"
	menu_btn2.custom_minimum_size = Vector2(200, 36)
	menu_btn2.add_theme_font_size_override("font_size", 16)
	menu_btn2.pressed.connect(func() -> void: AudioManager.play_ui("ui_click"); menu_pressed.emit())
	menu_btn2.mouse_entered.connect(func(): AudioManager.play_ui("ui_hover"))
	if GameData.is_stage_mode():
		btn_col.add_child(menu_btn2)


func _add_stat(parent: VBoxContainer, label_text: String, value_text: String, val_color: Color) -> void:
	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 16)
	parent.add_child(hbox)

	var lbl := Label.new()
	lbl.text = label_text
	lbl.add_theme_font_size_override("font_size", 24)
	lbl.add_theme_color_override("font_color", GameData.UI_TEXT_DIM)
	hbox.add_child(lbl)

	var dot := Label.new()
	dot.text = "...."
	dot.add_theme_font_size_override("font_size", 24)
	dot.add_theme_color_override("font_color", Color(GameData.UI_TEXT_DIM, 0.3))
	hbox.add_child(dot)

	var val := Label.new()
	val.text = value_text
	val.add_theme_font_size_override("font_size", 24)
	val.add_theme_color_override("font_color", val_color)
	hbox.add_child(val)


func _build_leaderboard(parent: VBoxContainer) -> void:
	var lb_sep := ColorRect.new()
	lb_sep.custom_minimum_size = Vector2(0, GameData.PX)
	lb_sep.color = GameData.UI_BORDER_LO
	lb_sep.color.a = 0.4
	parent.add_child(lb_sep)

	var lb_title := Label.new()
	lb_title.text = "-- 排行榜 TOP %d --" % mini(GameData.leaderboard.size(), GameData.MAX_LEADERBOARD)
	lb_title.add_theme_font_size_override("font_size", 14)
	lb_title.add_theme_color_override("font_color", GameData.UI_GOLD)
	lb_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(lb_title)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	parent.add_child(header)
	_lb_cell(header, "#", 30, GameData.UI_TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER)
	_lb_cell(header, "时间", 70, GameData.UI_TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER)
	_lb_cell(header, "击杀", 60, GameData.UI_TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER)
	_lb_cell(header, "等级", 50, GameData.UI_TEXT_DIM, HORIZONTAL_ALIGNMENT_CENTER)

	for i in range(GameData.leaderboard.size()):
		var entry: Dictionary = GameData.leaderboard[i]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		parent.add_child(row)

		var rank_color: Color
		if i == 0:
			rank_color = GameData.UI_GOLD
		elif i <= 2:
			rank_color = GameData.UI_BLUE
		else:
			rank_color = GameData.UI_TEXT

		var t: float = entry.get("time", 0.0)
		var m: int = int(t) / 60
		var s: int = int(t) % 60

		_lb_cell(row, str(i + 1), 30, rank_color, HORIZONTAL_ALIGNMENT_CENTER)
		_lb_cell(row, "%02d:%02d" % [m, s], 70, rank_color, HORIZONTAL_ALIGNMENT_CENTER)
		_lb_cell(row, str(entry.get("kills", 0)), 60, rank_color, HORIZONTAL_ALIGNMENT_CENTER)
		_lb_cell(row, "Lv.%d" % entry.get("level", 1), 50, rank_color, HORIZONTAL_ALIGNMENT_CENTER)


func _lb_cell(parent: HBoxContainer, text: String, min_w: float, color: Color, align: HorizontalAlignment) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.custom_minimum_size.x = min_w
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", color)
	lbl.horizontal_alignment = align
	parent.add_child(lbl)
