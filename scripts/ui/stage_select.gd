extends Control

const CHAPTERS: Array = [
	{"name": "第一章 - 幽暗森林", "color": Color.GREEN_YELLOW, "stages": [1, 2, 3, 4, 5]},
	{"name": "第二章 - 亡灵墓地", "color": Color.MEDIUM_PURPLE, "stages": [6, 7, 8, 9, 10]},
	{"name": "第三章 - 熔岩地狱", "color": Color.ORANGE_RED, "stages": [11, 12, 13, 14, 15]},
	{"name": "第四章 - 虚空深渊", "color": Color.DEEP_SKY_BLUE, "stages": [16, 17, 18, 19, 20]},
]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	theme = GameData.pixel_theme
	_build_ui()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.04, 0.04, 0.08)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 30)
	add_child(margin)

	var outer_vbox := VBoxContainer.new()
	outer_vbox.add_theme_constant_override("separation", 12)
	margin.add_child(outer_vbox)

	var title := Label.new()
	title.text = "= 选择关卡 ="
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", GameData.UI_GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outer_vbox.add_child(title)

	var sep := ColorRect.new()
	sep.custom_minimum_size = Vector2(0, GameData.PX)
	sep.color = GameData.UI_GOLD
	sep.color.a = 0.3
	outer_vbox.add_child(sep)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer_vbox.add_child(scroll)

	var chapters_vbox := VBoxContainer.new()
	chapters_vbox.add_theme_constant_override("separation", 16)
	chapters_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(chapters_vbox)

	for ch in CHAPTERS:
		_build_chapter(chapters_vbox, ch)

	var bottom_row := HBoxContainer.new()
	bottom_row.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom_row.add_theme_constant_override("separation", 16)
	outer_vbox.add_child(bottom_row)

	var back_btn := Button.new()
	back_btn.text = "返回主菜单"
	back_btn.custom_minimum_size = Vector2(200, 42)
	back_btn.add_theme_font_size_override("font_size", 20)
	back_btn.pressed.connect(_on_back)
	back_btn.mouse_entered.connect(func(): AudioManager.play_ui("ui_hover"))
	bottom_row.add_child(back_btn)


func _build_chapter(parent: VBoxContainer, ch: Dictionary) -> void:
	var ch_name: String = ch["name"]
	var ch_color: Color = ch["color"]
	var stage_ids: Array = ch["stages"]

	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.06, 0.12, 0.9)
	style.border_color = ch_color.darkened(0.4)
	style.set_border_width_all(GameData.PX)
	style.set_corner_radius_all(0)
	style.set_content_margin_all(12)
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = GameData.PX
	style.shadow_offset = Vector2(GameData.PX, GameData.PX)
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	var ch_label := Label.new()
	ch_label.text = ch_name
	ch_label.add_theme_font_size_override("font_size", 22)
	ch_label.add_theme_color_override("font_color", ch_color)
	vbox.add_child(ch_label)

	var grid := GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	vbox.add_child(grid)

	for sid in stage_ids:
		_build_stage_button(grid, sid, ch_color)


func _build_stage_button(parent: GridContainer, stage_id: int, ch_color: Color) -> void:
	var data: Dictionary = GameData.STAGE_DATA.get(stage_id, {})
	if data.is_empty():
		return

	var unlocked: bool = GameData.unlocked_stages.has(stage_id)
	var cleared: bool = GameData.cleared_stages.has(stage_id)

	var btn := Button.new()
	btn.custom_minimum_size = Vector2(160, 70)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var stage_name: String = data.get("name", "???")
	var desc: String = data.get("description", "")

	if cleared:
		btn.text = stage_name + "\n[已通关]"
		btn.add_theme_color_override("font_color", GameData.UI_GREEN)
	elif unlocked:
		btn.text = stage_name + "\n" + desc
		btn.add_theme_color_override("font_color", ch_color.lightened(0.2))
	else:
		btn.text = "???\n未解锁"
		btn.disabled = true
		btn.add_theme_color_override("font_color", GameData.UI_TEXT_DIM)

	btn.add_theme_font_size_override("font_size", 13)
	btn.tooltip_text = desc if unlocked else "通关前一关解锁"

	if unlocked:
		btn.pressed.connect(_on_stage_selected.bind(stage_id))
		btn.mouse_entered.connect(func(): AudioManager.play_ui("ui_hover"))

	parent.add_child(btn)


func _on_stage_selected(stage_id: int) -> void:
	AudioManager.play_ui("ui_click")
	GameData.current_stage = stage_id
	var data: Dictionary = GameData.STAGE_DATA.get(stage_id, {})
	GameData.bg_style = data.get("bg_style", "grassland")
	get_tree().change_scene_to_file("res://scenes/char_select.tscn")


func _on_back() -> void:
	AudioManager.play_ui("ui_click")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
