extends Control

var _main_vbox: VBoxContainer
var _lb_panel: PanelContainer


func _ready() -> void:
	theme = GameData.pixel_theme
	_build_ui()
	_show_splash_overlay()
	AudioManager.play_jingle("menu_jingle")


func _show_splash_overlay() -> void:
	var overlay := TextureRect.new()
	overlay.name = "SplashOverlay"
	var tex := load("res://assets/icons/boot_splash.png")
	overlay.texture = tex
	overlay.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	overlay.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var tween := create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(overlay, "modulate:a", 0.0, 0.5)
	tween.tween_callback(overlay.queue_free)


func _build_ui() -> void:
	var anim_bg := Control.new()
	anim_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	anim_bg.set_script(preload("res://scripts/ui/menu_bg.gd"))
	add_child(anim_bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 16)
	center.add_child(vbox)

	# ---- Dramatic title with glow ----
	var title_outer := Control.new()
	title_outer.custom_minimum_size = Vector2(500, 120)
	title_outer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(title_outer)

	var title_glow := Label.new()
	title_glow.text = "幸存者传说"
	title_glow.add_theme_font_size_override("font_size", 56)
	title_glow.add_theme_color_override("font_color", Color(1.0, 0.45, 0.0, 0.25))
	title_glow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	title_glow.add_theme_constant_override("outline_size", 16)
	title_glow.add_theme_color_override("font_outline_color", Color(0.8, 0.2, 0.0, 0.15))
	title_outer.add_child(title_glow)

	var title_shadow := Label.new()
	title_shadow.text = "幸存者传说"
	title_shadow.add_theme_font_size_override("font_size", 56)
	title_shadow.add_theme_color_override("font_color", Color(0.0, 0.0, 0.0, 0.6))
	title_shadow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_shadow.set_anchors_preset(Control.PRESET_FULL_RECT)
	title_shadow.position = Vector2(3, 3)
	title_outer.add_child(title_shadow)

	var title := Label.new()
	title.text = "幸存者传说"
	title.add_theme_font_size_override("font_size", 56)
	title.add_theme_color_override("font_color", GameData.UI_GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_FULL_RECT)
	title.add_theme_constant_override("outline_size", 4)
	title.add_theme_color_override("font_outline_color", Color(0.4, 0.15, 0.0, 0.8))
	title_outer.add_child(title)

	var deco_line := ColorRect.new()
	deco_line.custom_minimum_size = Vector2(0, GameData.PX)
	deco_line.color = GameData.UI_GOLD
	deco_line.color.a = 0.3
	vbox.add_child(deco_line)

	var subtitle := Label.new()
	subtitle.text = "Vampire Survivors Like"
	subtitle.add_theme_font_size_override("font_size", 12)
	subtitle.add_theme_color_override("font_color", GameData.UI_TEXT_DIM)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(subtitle)

	var spacer := Control.new()
	spacer.custom_minimum_size.y = 24
	vbox.add_child(spacer)

	var stage_btn := Button.new()
	stage_btn.text = "> 关卡挑战 <"
	stage_btn.custom_minimum_size = Vector2(240, 48)
	stage_btn.add_theme_font_size_override("font_size", 24)
	stage_btn.pressed.connect(_on_stage_select)
	stage_btn.mouse_entered.connect(func(): AudioManager.play_ui("ui_hover"))
	_apply_transparent_btn_style(stage_btn)
	vbox.add_child(stage_btn)

	var free_btn := Button.new()
	free_btn.text = "自由模式"
	free_btn.custom_minimum_size = Vector2(240, 48)
	free_btn.add_theme_font_size_override("font_size", 24)
	free_btn.pressed.connect(_on_free_mode)
	free_btn.mouse_entered.connect(func(): AudioManager.play_ui("ui_hover"))
	_apply_transparent_btn_style(free_btn)
	vbox.add_child(free_btn)

	var lb_btn := Button.new()
	lb_btn.text = "排行榜"
	lb_btn.custom_minimum_size = Vector2(240, 48)
	lb_btn.add_theme_font_size_override("font_size", 24)
	lb_btn.pressed.connect(_on_leaderboard)
	lb_btn.mouse_entered.connect(func(): AudioManager.play_ui("ui_hover"))
	_apply_transparent_btn_style(lb_btn)
	vbox.add_child(lb_btn)

	var quit_btn := Button.new()
	quit_btn.text = "退出"
	quit_btn.custom_minimum_size = Vector2(240, 48)
	quit_btn.add_theme_font_size_override("font_size", 24)
	quit_btn.pressed.connect(_on_quit)
	quit_btn.mouse_entered.connect(func(): AudioManager.play_ui("ui_hover"))
	_apply_transparent_btn_style(quit_btn)
	vbox.add_child(quit_btn)

	var spacer2 := Control.new()
	spacer2.custom_minimum_size.y = 16
	vbox.add_child(spacer2)

	var progress_label := Label.new()
	var cleared: int = GameData.cleared_stages.size()
	var total: int = GameData.STAGE_DATA.size()
	progress_label.text = "关卡进度: %d / %d" % [cleared, total]
	progress_label.add_theme_font_size_override("font_size", 14)
	progress_label.add_theme_color_override("font_color", GameData.UI_GOLD if cleared > 0 else GameData.UI_TEXT_DIM)
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(progress_label)

	var controls := Label.new()
	controls.text = "WASD / 方向键 移动"
	controls.add_theme_font_size_override("font_size", 12)
	controls.add_theme_color_override("font_color", GameData.UI_TEXT_DIM)
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(controls)

	var info := Label.new()
	info.text = "击杀敌人获取经验，升级选择武器和强化"
	info.add_theme_font_size_override("font_size", 12)
	info.add_theme_color_override("font_color", Color(GameData.UI_TEXT_DIM, 0.6))
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(info)


func _make_semi_btn(bg: Color, border: Color, pressed: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(0)
	if pressed:
		s.border_color = border
		s.set_border_width_all(GameData.PX)
		s.border_width_top = GameData.PX * 2
		s.border_width_left = GameData.PX * 2
		s.border_width_bottom = GameData.PX
		s.border_width_right = GameData.PX
		s.shadow_color = Color(0, 0, 0, 0)
	else:
		s.border_width_top = GameData.PX
		s.border_width_left = GameData.PX
		s.border_width_bottom = GameData.PX * 2
		s.border_width_right = GameData.PX * 2
		s.border_color = border
		s.shadow_color = Color(0, 0, 0, 0.2)
		s.shadow_size = GameData.PX
		s.shadow_offset = Vector2(GameData.PX, GameData.PX)
	s.set_content_margin_all(8)
	return s


func _apply_transparent_btn_style(btn: Button) -> void:
	var base_bg := Color(0.15, 0.15, 0.25, 0.45)
	var hover_bg := Color(0.18, 0.18, 0.30, 0.55)
	var press_bg := Color(0.06, 0.06, 0.12, 0.5)
	var border_hi := Color(0.35, 0.35, 0.55, 0.6)
	var border_hover := Color(0.5, 0.45, 0.7, 0.6)
	var border_lo := Color(0.12, 0.12, 0.22, 0.6)

	btn.add_theme_stylebox_override("normal", _make_semi_btn(base_bg, border_hi, false))
	btn.add_theme_stylebox_override("hover", _make_semi_btn(hover_bg, border_hover, false))
	btn.add_theme_stylebox_override("pressed", _make_semi_btn(press_bg, border_lo, true))
	btn.add_theme_stylebox_override("focus", _make_semi_btn(hover_bg, Color(GameData.UI_GOLD, 0.5), false))


func _on_stage_select() -> void:
	AudioManager.play_ui("ui_click")
	get_tree().change_scene_to_file("res://scenes/stage_select.tscn")


func _on_free_mode() -> void:
	AudioManager.play_ui("ui_click")
	GameData.current_stage = 0
	get_tree().change_scene_to_file("res://scenes/char_select.tscn")


func _on_quit() -> void:
	get_tree().quit()


func _on_leaderboard() -> void:
	AudioManager.play_ui("ui_click")
	if _lb_panel:
		_lb_panel.queue_free()
		_lb_panel = null
		return

	_lb_panel = PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.06, 0.12, 0.95)
	style.border_color = GameData.UI_GOLD
	style.border_color.a = 0.5
	style.set_border_width_all(GameData.PX)
	style.set_corner_radius_all(0)
	style.set_content_margin_all(20)
	style.shadow_color = Color(0, 0, 0, 0.4)
	style.shadow_size = GameData.PX * 2
	style.shadow_offset = Vector2(GameData.PX * 2, GameData.PX * 2)
	_lb_panel.add_theme_stylebox_override("panel", style)
	_lb_panel.set_anchors_preset(Control.PRESET_CENTER)
	_lb_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_lb_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(_lb_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	_lb_panel.add_child(vbox)

	var title := Label.new()
	title.text = "= 自由模式排行榜 ="
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", GameData.UI_GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var sep := ColorRect.new()
	sep.custom_minimum_size = Vector2(0, GameData.PX)
	sep.color = GameData.UI_GOLD
	sep.color.a = 0.3
	vbox.add_child(sep)

	if GameData.leaderboard.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "暂无记录\n完成一局自由模式即可上榜"
		empty_lbl.add_theme_font_size_override("font_size", 16)
		empty_lbl.add_theme_color_override("font_color", GameData.UI_TEXT_DIM)
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(empty_lbl)
	else:
		var header := HBoxContainer.new()
		header.add_theme_constant_override("separation", 12)
		vbox.add_child(header)
		_lb_cell(header, "#", 30, GameData.UI_TEXT_DIM)
		_lb_cell(header, "存活时间", 90, GameData.UI_TEXT_DIM)
		_lb_cell(header, "击杀数", 70, GameData.UI_TEXT_DIM)
		_lb_cell(header, "等级", 60, GameData.UI_TEXT_DIM)

		for i in range(GameData.leaderboard.size()):
			var entry: Dictionary = GameData.leaderboard[i]
			var row := HBoxContainer.new()
			row.add_theme_constant_override("separation", 12)
			vbox.add_child(row)

			var color: Color
			if i == 0:
				color = GameData.UI_GOLD
			elif i <= 2:
				color = GameData.UI_BLUE
			else:
				color = GameData.UI_TEXT

			var t: float = entry.get("time", 0.0)
			var m: int = int(t) / 60
			var s: int = int(t) % 60
			_lb_cell(row, str(i + 1), 30, color)
			_lb_cell(row, "%02d:%02d" % [m, s], 90, color)
			_lb_cell(row, str(entry.get("kills", 0)), 70, color)
			_lb_cell(row, "Lv.%d" % entry.get("level", 1), 60, color)

	var spacer := Control.new()
	spacer.custom_minimum_size.y = 8
	vbox.add_child(spacer)

	var close_btn := Button.new()
	close_btn.text = "关闭"
	close_btn.custom_minimum_size = Vector2(120, 36)
	close_btn.add_theme_font_size_override("font_size", 18)
	close_btn.pressed.connect(_on_leaderboard)
	close_btn.mouse_entered.connect(func(): AudioManager.play_ui("ui_hover"))
	vbox.add_child(close_btn)


func _lb_cell(parent: HBoxContainer, text: String, min_w: float, color: Color) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.custom_minimum_size.x = min_w
	lbl.add_theme_font_size_override("font_size", 16)
	lbl.add_theme_color_override("font_color", color)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(lbl)
