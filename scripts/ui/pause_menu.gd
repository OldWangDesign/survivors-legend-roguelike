extends Control

signal resume_pressed
signal restart_pressed
signal main_menu_pressed
signal stage_select_pressed


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	theme = GameData.pixel_theme
	visible = false


func show_pause() -> void:
	visible = true
	_build_ui()


func hide_pause() -> void:
	visible = false
	for child in get_children():
		child.queue_free()


func _build_ui() -> void:
	for child in get_children():
		child.queue_free()

	var overlay := ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.65)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.07, 0.13, 0.95)
	style.border_color = GameData.UI_BORDER_HI
	style.border_width_top = GameData.PX
	style.border_width_left = GameData.PX
	style.border_width_bottom = GameData.PX * 2
	style.border_width_right = GameData.PX * 2
	style.set_corner_radius_all(0)
	style.set_content_margin_all(28)
	style.shadow_color = Color(0, 0, 0, 0.6)
	style.shadow_size = GameData.PX * 4
	style.shadow_offset = Vector2(GameData.PX * 2, GameData.PX * 2)
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

	var dl := Label.new()
	dl.text = "||"
	dl.add_theme_font_size_override("font_size", 28)
	dl.add_theme_color_override("font_color", GameData.UI_GOLD.darkened(0.3))
	title_row.add_child(dl)

	var title := Label.new()
	title.text = "PAUSED"
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", GameData.UI_GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_row.add_child(title)

	var dr := Label.new()
	dr.text = "||"
	dr.add_theme_font_size_override("font_size", 28)
	dr.add_theme_color_override("font_color", GameData.UI_GOLD.darkened(0.3))
	title_row.add_child(dr)

	var sep := ColorRect.new()
	sep.custom_minimum_size = Vector2(220, GameData.PX)
	sep.color = GameData.UI_GOLD
	sep.color.a = 0.25
	vbox.add_child(sep)

	var spacer := Control.new()
	spacer.custom_minimum_size.y = 8
	vbox.add_child(spacer)

	var resume_btn := _make_btn("> 继续游戏 <", 24, GameData.UI_GREEN)
	resume_btn.pressed.connect(_on_resume_btn)
	vbox.add_child(resume_btn)

	var restart_btn := _make_btn("重新开始", 20, GameData.UI_TEXT)
	restart_btn.pressed.connect(_on_restart_btn)
	vbox.add_child(restart_btn)

	if GameData.is_stage_mode():
		var select_btn := _make_btn("选择关卡", 20, GameData.UI_TEXT)
		select_btn.pressed.connect(_on_stage_select_btn)
		vbox.add_child(select_btn)

	var menu_btn := _make_btn("返回主菜单", 20, GameData.UI_TEXT)
	menu_btn.pressed.connect(_on_menu_btn)
	vbox.add_child(menu_btn)

	var spacer2 := Control.new()
	spacer2.custom_minimum_size.y = 4
	vbox.add_child(spacer2)

	var hint := Label.new()
	hint.text = "按 ESC 继续"
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", GameData.UI_TEXT_DIM)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hint)


func _make_btn(text: String, font_size: int, color: Color) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(220, 42)
	btn.add_theme_font_size_override("font_size", font_size)
	btn.add_theme_color_override("font_color", color)
	btn.mouse_entered.connect(_on_hover)
	return btn


func _on_hover() -> void:
	AudioManager.play_ui("ui_hover")


func _on_resume_btn() -> void:
	AudioManager.play_ui("ui_click")
	resume_pressed.emit()


func _on_restart_btn() -> void:
	AudioManager.play_ui("ui_click")
	restart_pressed.emit()


func _on_stage_select_btn() -> void:
	AudioManager.play_ui("ui_click")
	stage_select_pressed.emit()


func _on_menu_btn() -> void:
	AudioManager.play_ui("ui_click")
	main_menu_pressed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		resume_pressed.emit()
		get_viewport().set_input_as_handled()
