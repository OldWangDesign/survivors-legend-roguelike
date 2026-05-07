extends Control

const _FONT_THEME: Theme = preload("res://assets/fonts/default_theme.tres")

var _xp_bar: Control
var _xp_fill: float = 0.0
var _xp_display_fill: float = 0.0
var _time_label: Label
var _kill_label: Label
var _stage_label: Label
var _objective_label: Label
var _obj_bar: Control
var _obj_fill: float = 0.0

var _xp_cur: int = 0
var _xp_max: int = 1
var _xp_level: int = 1
var _xp_prev_level: int = 1
var _obj_cur: float = 0.0
var _obj_max: float = 1.0

var _xp_flame_frame: int = 0
var _xp_flame_timer: float = 0.0
var _xp_flash_timer: float = 0.0
var _xp_levelup_timer: float = 0.0

var _weapon_container: HBoxContainer
var _weapon_slots: Array = []
var _prev_weapon_types: Array = []

# Boss health bar
var _boss_bar: Control
var _boss_name_lbl: Label
var _boss_health_fill: float = 0.0
var _boss_display_fill: float = 0.0
var _boss_visible: bool = false
var _boss_flash_timer: float = 0.0

# Warning banner
var _warn_label: Label
var _warn_timer: float = 0.0

# Character portrait
var _portrait: TextureRect
var _portrait_panel: PanelContainer
var _portrait_style: StyleBoxFlat
var _char_name_lbl: Label
var _passive_lbl: Label
var _portrait_base_border: Color = Color(0.35, 0.35, 0.5)
var _portrait_flash_timer: float = 0.0
var _portrait_flash_color: Color = Color.WHITE
var _portrait_breath_time: float = 0.0
var _prev_health: int = -1
var _prev_passive_status: String = ""

const SLOT_SIZE := Vector2(40, 50)
const SLOT_SIZE_SMALL := Vector2(32, 42)
const ICON_SIZE := 20
const ICON_SIZE_SMALL := 14
const SHRINK_THRESHOLD := 8
const PORTRAIT_SIZE := 36


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("hud")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	theme = GameData.pixel_theme
	_build_ui()


func _build_ui() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 8)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(margin)

	var outer := VBoxContainer.new()
	outer.set_anchors_preset(Control.PRESET_FULL_RECT)
	outer.add_theme_constant_override("separation", 4)
	outer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(outer)

	# ── Row 1: XP Bar (staircase style) ──
	_xp_bar = Control.new()
	_xp_bar.custom_minimum_size = Vector2(0, 20)
	_xp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	outer.add_child(_xp_bar)
	_xp_bar.draw.connect(_draw_xp_bar)

	# ── Row 1.5: Boss Health Bar (hidden by default) ──
	_boss_bar = Control.new()
	_boss_bar.custom_minimum_size = Vector2(0, 16)
	_boss_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_boss_bar.visible = false
	outer.add_child(_boss_bar)
	_boss_bar.draw.connect(_draw_boss_bar)

	_boss_name_lbl = Label.new()
	_boss_name_lbl.text = ""
	_boss_name_lbl.visible = false

	_warn_label = Label.new()
	_warn_label.text = ""
	_warn_label.add_theme_font_size_override("font_size", 20)
	_warn_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.2))
	_warn_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_warn_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_warn_label.position.y = 50
	_warn_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_warn_label.visible = false
	add_child(_warn_label)

	# ── Row 2: Portrait + Time + Info ──
	var main_row := HBoxContainer.new()
	main_row.add_theme_constant_override("separation", 8)
	main_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	outer.add_child(main_row)

	_build_portrait_block(main_row)

	var center_spacer := Control.new()
	center_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_row.add_child(center_spacer)

	_time_label = Label.new()
	_time_label.text = "00:00"
	_time_label.add_theme_font_size_override("font_size", 26)
	_time_label.add_theme_color_override("font_color", GameData.UI_GOLD)
	_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_time_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_time_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_row.add_child(_time_label)

	var right_spacer := Control.new()
	right_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_row.add_child(right_spacer)

	_build_right_info(main_row)

	# ── Row 3: Weapons + Stage Objective ──
	var bottom_row := HBoxContainer.new()
	bottom_row.add_theme_constant_override("separation", 8)
	bottom_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	outer.add_child(bottom_row)

	_weapon_container = HBoxContainer.new()
	_weapon_container.alignment = BoxContainer.ALIGNMENT_BEGIN
	_weapon_container.add_theme_constant_override("separation", 3)
	_weapon_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom_row.add_child(_weapon_container)


func _build_portrait_block(parent: HBoxContainer) -> void:
	var block := HBoxContainer.new()
	block.add_theme_constant_override("separation", 6)
	block.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(block)

	_portrait_panel = PanelContainer.new()
	_portrait_panel.custom_minimum_size = Vector2(PORTRAIT_SIZE + 8, PORTRAIT_SIZE + 8)
	_portrait_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_portrait_style = StyleBoxFlat.new()
	_portrait_style.bg_color = Color(0.04, 0.04, 0.08, 0.9)
	_portrait_style.border_color = _portrait_base_border
	_portrait_style.set_border_width_all(GameData.PX)
	_portrait_style.set_corner_radius_all(0)
	_portrait_style.set_content_margin_all(3)
	_portrait_panel.add_theme_stylebox_override("panel", _portrait_style)
	block.add_child(_portrait_panel)

	var portrait_center := CenterContainer.new()
	portrait_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_portrait_panel.add_child(portrait_center)

	_portrait = TextureRect.new()
	_portrait.custom_minimum_size = Vector2(PORTRAIT_SIZE, PORTRAIT_SIZE)
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_center.add_child(_portrait)

	var frames: Array = GameData.sprites.get("player", [])
	if frames.size() > 0:
		_portrait.texture = frames[0]

	var text_col := VBoxContainer.new()
	text_col.add_theme_constant_override("separation", 1)
	text_col.alignment = BoxContainer.ALIGNMENT_CENTER
	text_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	block.add_child(text_col)

	var char_data: Dictionary = GameData.get_character_data()

	_char_name_lbl = Label.new()
	_char_name_lbl.text = char_data.get("name", "")
	_char_name_lbl.add_theme_font_size_override("font_size", 13)
	_char_name_lbl.add_theme_color_override("font_color", GameData.UI_GOLD)
	_char_name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_col.add_child(_char_name_lbl)

	_passive_lbl = Label.new()
	_passive_lbl.text = "★ " + char_data.get("passive_name", "")
	_passive_lbl.add_theme_font_size_override("font_size", 10)
	_passive_lbl.add_theme_color_override("font_color", GameData.UI_TEXT_DIM)
	_passive_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_col.add_child(_passive_lbl)


func _build_right_info(parent: HBoxContainer) -> void:
	var right_col := VBoxContainer.new()
	right_col.add_theme_constant_override("separation", 2)
	right_col.alignment = BoxContainer.ALIGNMENT_CENTER
	right_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(right_col)

	if GameData.is_stage_mode():
		var stage_data: Dictionary = GameData.get_stage_data()
		_stage_label = Label.new()
		_stage_label.text = stage_data.get("name", "")
		_stage_label.add_theme_font_size_override("font_size", 11)
		_stage_label.add_theme_color_override("font_color", GameData.UI_GOLD)
		_stage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		_stage_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		right_col.add_child(_stage_label)

		_objective_label = Label.new()
		_objective_label.text = _get_objective_text()
		_objective_label.add_theme_font_size_override("font_size", 10)
		_objective_label.add_theme_color_override("font_color", GameData.UI_GREEN.lightened(0.3))
		_objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		_objective_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		right_col.add_child(_objective_label)

		_obj_bar = _create_bar(right_col, 8, GameData.UI_GREEN)
		_obj_bar.custom_minimum_size.x = 160

	_kill_label = Label.new()
	_kill_label.text = "击杀: 0"
	_kill_label.add_theme_font_size_override("font_size", 14)
	_kill_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9))
	_kill_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_kill_label.custom_minimum_size.x = 100
	_kill_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	right_col.add_child(_kill_label)


# ============================================================
#  Bar rendering
# ============================================================

func _create_bar(parent: Control, height: int, color: Color) -> Control:
	var bar := Control.new()
	bar.custom_minimum_size = Vector2(0, height)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(bar)
	bar.draw.connect(_draw_bar.bind(bar, color))
	return bar


func _draw_bar(bar: Control, color: Color) -> void:
	var w: float = bar.size.x
	var h: float = bar.size.y
	if w < 1:
		return

	var px: int = GameData.PX

	bar.draw_rect(Rect2(0, 0, w, h), Color(0.02, 0.02, 0.05))
	bar.draw_rect(Rect2(0, 0, w, px), Color(0.0, 0.0, 0.0, 0.6))
	bar.draw_rect(Rect2(0, 0, px, h), Color(0.0, 0.0, 0.0, 0.6))
	bar.draw_rect(Rect2(0, h - px, w, px), Color(0.2, 0.2, 0.3, 0.4))
	bar.draw_rect(Rect2(w - px, 0, px, h), Color(0.2, 0.2, 0.3, 0.4))

	var fill: float = _obj_fill if bar == _obj_bar else 0.0

	var inner_x: float = px
	var inner_y: float = px
	var inner_w: float = (w - px * 2) * clampf(fill, 0.0, 1.0)
	var inner_h: float = h - px * 2

	if inner_w > 0:
		bar.draw_rect(Rect2(inner_x, inner_y, inner_w, inner_h), color.darkened(0.2))
		bar.draw_rect(Rect2(inner_x, inner_y, inner_w, px), color.lightened(0.3))
		bar.draw_rect(Rect2(inner_x, inner_y + px, inner_w, inner_h - px * 2), color)
		bar.draw_rect(Rect2(inner_x, inner_y + inner_h - px, inner_w, px), color.darkened(0.3))

		var seg_spacing: int = 8
		var seg_x: int = seg_spacing
		while seg_x < int(inner_w):
			bar.draw_rect(Rect2(inner_x + seg_x, inner_y, 1, inner_h), Color(0, 0, 0, 0.15))
			seg_x += seg_spacing


# ============================================================
#  XP Bar - Staircase gradient style
# ============================================================

const XP_MIN_H: float = 4.0
const XP_MAX_H: float = 18.0

func _xp_color_at(t: float) -> Color:
	var c_deep_blue := Color(0.12, 0.18, 0.55)
	var c_bright_blue := Color(0.25, 0.55, 1.0)
	var c_purple := Color(0.6, 0.25, 0.9)
	var c_gold := Color(1.0, 0.85, 0.2)
	if t < 0.5:
		return c_deep_blue.lerp(c_bright_blue, t / 0.5)
	elif t < 0.8:
		return c_bright_blue.lerp(c_purple, (t - 0.5) / 0.3)
	else:
		return c_purple.lerp(c_gold, (t - 0.8) / 0.2)


func _draw_xp_bar() -> void:
	var w: float = _xp_bar.size.x
	var h: float = _xp_bar.size.y
	if w < 2:
		return

	var px: int = GameData.PX
	var fill: float = clampf(_xp_display_fill, 0.0, 1.0)
	var fill_w: float = w * fill

	# Background: draw staircase outline (dark)
	for col in range(int(w)):
		var t: float = float(col) / maxf(w - 1.0, 1.0)
		var col_h: float = XP_MIN_H + (XP_MAX_H - XP_MIN_H) * t
		var y_start: float = h - col_h
		_xp_bar.draw_rect(Rect2(col, y_start, 1, col_h), Color(0.03, 0.03, 0.07))

	# Top border of staircase outline
	for col in range(int(w)):
		var t: float = float(col) / maxf(w - 1.0, 1.0)
		var col_h: float = XP_MIN_H + (XP_MAX_H - XP_MIN_H) * t
		var y_start: float = h - col_h
		_xp_bar.draw_rect(Rect2(col, y_start, 1, px), Color(0.08, 0.08, 0.15))

	# Bottom border
	_xp_bar.draw_rect(Rect2(0, h - px, w, px), Color(0.08, 0.08, 0.15))

	# Filled portion
	if fill_w > 0:
		var near_levelup: bool = fill > 0.9
		var pulse_val: float = (sin(Time.get_ticks_msec() * 0.008) + 1.0) * 0.5 if near_levelup else 0.0

		for col in range(int(fill_w)):
			var t_pos: float = float(col) / maxf(w - 1.0, 1.0)
			var col_h: float = XP_MIN_H + (XP_MAX_H - XP_MIN_H) * t_pos
			var y_start: float = h - col_h
			var inner_h: float = col_h - px

			var base_color: Color = _xp_color_at(fill)
			var col_color: Color = base_color.darkened(0.15).lerp(base_color.lightened(0.1), t_pos)

			if near_levelup:
				col_color = col_color.lerp(GameData.UI_GOLD, pulse_val * 0.3)

			# XP gain flash
			if _xp_flash_timer > 0:
				col_color = col_color.lerp(Color.WHITE, clampf(_xp_flash_timer / 0.2, 0.0, 1.0) * 0.4)

			# Level-up flash
			if _xp_levelup_timer > 0:
				var lu_alpha: float = clampf(_xp_levelup_timer / 0.5, 0.0, 1.0)
				col_color = col_color.lerp(Color(1.0, 0.95, 0.7), lu_alpha * 0.7)

			_xp_bar.draw_rect(Rect2(col, y_start + px, 1, inner_h), col_color)

			# Highlight on top pixel
			_xp_bar.draw_rect(Rect2(col, y_start + px, 1, px), col_color.lightened(0.4))

		# Segment lines every 10%
		for seg_i in range(1, 10):
			var seg_x: float = w * seg_i * 0.1
			if seg_x < fill_w:
				var t_seg: float = float(int(seg_x)) / maxf(w - 1.0, 1.0)
				var seg_h: float = XP_MIN_H + (XP_MAX_H - XP_MIN_H) * t_seg
				var seg_y: float = h - seg_h + px
				_xp_bar.draw_rect(Rect2(int(seg_x), seg_y, 1, seg_h - px), Color(0, 0, 0, 0.2))

		# Fire/sparkle at fill tip
		var tip_x: int = int(fill_w) - 1
		if tip_x > 0 and tip_x < int(w):
			var t_tip: float = float(tip_x) / maxf(w - 1.0, 1.0)
			var tip_h: float = XP_MIN_H + (XP_MAX_H - XP_MIN_H) * t_tip
			var tip_y: float = h - tip_h
			var fire_color: Color = _xp_color_at(fill).lightened(0.5)

			if _xp_flame_frame == 0:
				_xp_bar.draw_rect(Rect2(tip_x, tip_y - 2, 1, 2), fire_color)
				if tip_x > 0:
					_xp_bar.draw_rect(Rect2(tip_x - 1, tip_y - 1, 1, 1), fire_color.darkened(0.2))
				if tip_x + 1 < int(w):
					_xp_bar.draw_rect(Rect2(tip_x + 1, tip_y - 1, 1, 1), fire_color.darkened(0.2))
			else:
				_xp_bar.draw_rect(Rect2(tip_x, tip_y - 3, 1, 3), fire_color)
				if tip_x > 0:
					_xp_bar.draw_rect(Rect2(tip_x - 1, tip_y - 2, 1, 2), fire_color.darkened(0.3))
				if tip_x + 1 < int(w):
					_xp_bar.draw_rect(Rect2(tip_x + 1, tip_y - 1, 1, 1), fire_color.darkened(0.3))

	# Text: Lv on right, EXP on left
	var font: Font = _FONT_THEME.default_font if _FONT_THEME.default_font else ThemeDB.fallback_font
	var fsize: int = 11
	var text_y: float = h - 3.0
	var lv_text: String = "Lv.%d" % _xp_level
	var xp_text: String = "%d/%d" % [_xp_cur, _xp_max]
	_xp_bar.draw_string(font, Vector2(4, text_y), xp_text, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize, Color(1, 1, 1, 0.8))
	_xp_bar.draw_string(font, Vector2(0, text_y), lv_text, HORIZONTAL_ALIGNMENT_RIGHT, int(w) - 4, fsize, GameData.UI_GOLD)


# ============================================================
#  Boss health bar
# ============================================================

func _draw_boss_bar() -> void:
	var w: float = _boss_bar.size.x
	var h: float = _boss_bar.size.y
	if w < 2:
		return

	var px: int = GameData.PX

	_boss_bar.draw_rect(Rect2(0, 0, w, h), Color(0.03, 0.01, 0.02))
	_boss_bar.draw_rect(Rect2(0, 0, w, px), Color(0.3, 0.05, 0.05))
	_boss_bar.draw_rect(Rect2(0, h - px, w, px), Color(0.15, 0.05, 0.05))
	_boss_bar.draw_rect(Rect2(0, 0, px, h), Color(0.3, 0.05, 0.05))
	_boss_bar.draw_rect(Rect2(w - px, 0, px, h), Color(0.15, 0.05, 0.05))

	var fill: float = clampf(_boss_display_fill, 0.0, 1.0)
	var inner_x: float = px
	var inner_y: float = px
	var inner_w: float = (w - px * 2) * fill
	var inner_h: float = h - px * 2

	if inner_w > 0:
		var base_red := Color(0.7, 0.1, 0.1)
		var bright_red := Color(0.9, 0.15, 0.1)
		_boss_bar.draw_rect(Rect2(inner_x, inner_y, inner_w, inner_h), base_red)
		_boss_bar.draw_rect(Rect2(inner_x, inner_y, inner_w, px), bright_red)
		_boss_bar.draw_rect(Rect2(inner_x, inner_y + inner_h - px, inner_w, px), base_red.darkened(0.3))

		if _boss_flash_timer > 0:
			var flash_a: float = clampf(_boss_flash_timer / 0.2, 0.0, 1.0) * 0.5
			_boss_bar.draw_rect(Rect2(inner_x, inner_y, inner_w, inner_h), Color(1, 1, 1, flash_a))

	var font: Font = _FONT_THEME.default_font if _FONT_THEME.default_font else ThemeDB.fallback_font
	var fsize: int = 10
	var text_y: float = h - 3.0
	var pct_text: String = "%d%%" % int(fill * 100.0)
	_boss_bar.draw_string(font, Vector2(4, text_y), _boss_name_lbl.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize, Color(1.0, 0.8, 0.8, 0.9))
	_boss_bar.draw_string(font, Vector2(0, text_y), pct_text, HORIZONTAL_ALIGNMENT_RIGHT, int(w) - 4, fsize, Color(1.0, 0.6, 0.6, 0.9))


func _update_boss_bar(delta: float) -> void:
	var bosses: Array = get_tree().get_nodes_in_group("bosses")
	if bosses.is_empty():
		if _boss_visible:
			_boss_visible = false
			_boss_bar.visible = false
		return

	var boss: Node2D = bosses[0]
	if not is_instance_valid(boss):
		return

	if not _boss_visible:
		_boss_visible = true
		_boss_bar.visible = true
		_boss_display_fill = 1.0

	var target_fill: float = boss.health / maxf(boss.max_health, 1.0)
	if target_fill < _boss_health_fill - 0.01:
		_boss_flash_timer = 0.2
	_boss_health_fill = target_fill
	_boss_display_fill = lerpf(_boss_display_fill, _boss_health_fill, delta * 6.0)

	if boss.has_method("setup_boss"):
		var boss_data: Dictionary = GameData.BOSS_DATA.get(boss.boss_id, {})
		_boss_name_lbl.text = boss_data.get("name", "Boss")
	else:
		_boss_name_lbl.text = "Boss"

	if _boss_flash_timer > 0:
		_boss_flash_timer -= delta

	_boss_bar.queue_redraw()


# ============================================================
#  Portrait animation
# ============================================================

func _update_portrait(delta: float) -> void:
	if not is_instance_valid(_portrait_panel):
		return

	_portrait_breath_time += delta
	var breath: float = 1.0 + sin(_portrait_breath_time * 2.0) * 0.02
	_portrait_panel.scale = Vector2(breath, breath)
	_portrait_panel.pivot_offset = _portrait_panel.size * 0.5

	if _portrait_flash_timer > 0:
		_portrait_flash_timer -= delta
		var flash_alpha: float = clampf(_portrait_flash_timer / 0.3, 0.0, 1.0)
		_portrait_style.border_color = _portrait_flash_color.lerp(_portrait_base_border, 1.0 - flash_alpha)
		_portrait.modulate = Color.WHITE.lerp(_portrait_flash_color, flash_alpha * 0.4)
	else:
		_portrait_style.border_color = _portrait_base_border
		_portrait.modulate = Color.WHITE


func flash_portrait(color: Color) -> void:
	_portrait_flash_timer = 0.3
	_portrait_flash_color = color


# ============================================================
#  Weapon bar
# ============================================================

func _sync_weapon_slots() -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return

	var weapons: Array = player.weapons
	var count: int = weapons.size()

	while _weapon_slots.size() > count:
		var slot: Dictionary = _weapon_slots.pop_back()
		_weapon_container.remove_child(slot["panel"])
		slot["panel"].queue_free()

	while _weapon_slots.size() < count:
		var slot := _create_weapon_slot()
		_weapon_container.add_child(slot["panel"])
		_weapon_slots.append(slot)

	var is_small: bool = count > SHRINK_THRESHOLD
	var target_size: Vector2 = SLOT_SIZE_SMALL if is_small else SLOT_SIZE
	var icon_sz: int = ICON_SIZE_SMALL if is_small else ICON_SIZE
	for slot in _weapon_slots:
		slot["panel"].custom_minimum_size = target_size
		slot["icon"].custom_minimum_size = Vector2(icon_sz, icon_sz)
		slot["icon"].stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED


func _create_weapon_slot() -> Dictionary:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = SLOT_SIZE
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.06, 0.1, 0.8)
	style.border_color = Color(0.25, 0.25, 0.35)
	style.set_border_width_all(GameData.PX)
	style.set_corner_radius_all(0)
	style.set_content_margin_all(2)
	panel.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 1)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(vbox)

	var icon_center := CenterContainer.new()
	icon_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(icon_center)

	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(ICON_SIZE, ICON_SIZE)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_center.add_child(icon)

	var cd_overlay := ColorRect.new()
	cd_overlay.color = Color(0, 0, 0, 0.55)
	cd_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cd_overlay.visible = false
	icon_center.add_child(cd_overlay)

	var name_lbl := Label.new()
	name_lbl.text = ""
	name_lbl.add_theme_font_size_override("font_size", 9)
	name_lbl.add_theme_color_override("font_color", Color(0.4, 0.4, 0.5))
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(name_lbl)

	var lv_lbl := Label.new()
	lv_lbl.text = ""
	lv_lbl.add_theme_font_size_override("font_size", 8)
	lv_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6))
	lv_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lv_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(lv_lbl)

	var flash := ColorRect.new()
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.color = Color(1, 1, 1, 0)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(flash)

	return {
		"panel": panel,
		"style": style,
		"icon": icon,
		"cd_overlay": cd_overlay,
		"name_lbl": name_lbl,
		"lv_lbl": lv_lbl,
		"flash": flash,
	}


func _update_weapon_bar() -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return

	_sync_weapon_slots()

	var weapons: Array = player.weapons
	var cur_types: Array = []
	for w in weapons:
		cur_types.append(w["type"])

	var new_types: Array = []
	for t in cur_types:
		if not _prev_weapon_types.has(t):
			new_types.append(t)
	_prev_weapon_types = cur_types.duplicate()

	var evo_ready_types: Dictionary = {}
	for evo_type in GameData.EVOLUTION_RECIPES.keys():
		if player.has_weapon(evo_type):
			continue
		var recipe: Array = GameData.EVOLUTION_RECIPES[evo_type]
		var all_max := true
		for base_type in recipe:
			if player.get_weapon_level(base_type) < 8:
				all_max = false
				break
		if all_max:
			for base_type in recipe:
				evo_ready_types[base_type] = true

	var pulse: float = (sin(Time.get_ticks_msec() * 0.005) + 1.0) * 0.5

	for i in range(weapons.size()):
		if i >= _weapon_slots.size():
			break
		var w: Dictionary = weapons[i]
		var wt: int = w["type"]
		var data: Dictionary = GameData.WEAPON_DATA[wt]
		var slot: Dictionary = _weapon_slots[i]
		var style: StyleBoxFlat = slot["style"]
		var icon: TextureRect = slot["icon"]
		var name_lbl: Label = slot["name_lbl"]
		var lv_lbl: Label = slot["lv_lbl"]
		var cd_overlay: ColorRect = slot["cd_overlay"]
		var wcolor: Color = data["icon_color"]
		var is_evo: bool = data.get("is_evolution", false)
		var is_max: bool = w["level"] >= 8

		if GameData.weapon_icons.has(wt):
			icon.texture = GameData.weapon_icons[wt]
		icon.modulate = Color.WHITE

		name_lbl.text = data["name"].left(2)
		name_lbl.add_theme_color_override("font_color", wcolor.lightened(0.3))

		if is_max:
			lv_lbl.text = "MAX"
			lv_lbl.add_theme_color_override("font_color", GameData.UI_GOLD)
		else:
			lv_lbl.text = "Lv.%d" % w["level"]
			lv_lbl.add_theme_color_override("font_color", Color.WHITE)

		if is_evo:
			style.border_color = GameData.UI_GOLD
			style.bg_color = Color(0.12, 0.08, 0.02, 0.85)
		elif evo_ready_types.has(wt):
			var glow_color: Color = GameData.UI_GOLD.lerp(wcolor.darkened(0.3), pulse)
			style.border_color = glow_color
			style.bg_color = Color(0.1, 0.08, 0.02, 0.85).lerp(Color(0.06, 0.06, 0.1, 0.8), pulse)
		elif is_max:
			style.border_color = GameData.UI_GOLD.darkened(0.3)
			style.bg_color = Color(0.08, 0.06, 0.02, 0.85)
		else:
			style.border_color = wcolor.darkened(0.3)
			style.bg_color = Color(0.06, 0.06, 0.1, 0.8)

		var weapon_node = w.get("node")
		if weapon_node and is_instance_valid(weapon_node) and weapon_node.has_method("get_cooldown_percent"):
			var cd_pct: float = weapon_node.get_cooldown_percent()
			if cd_pct > 0.01:
				cd_overlay.visible = true
				var icon_h: float = icon.size.y if icon.size.y > 0 else float(ICON_SIZE)
				cd_overlay.custom_minimum_size = Vector2(icon.size.x, icon_h * cd_pct)
				cd_overlay.size = cd_overlay.custom_minimum_size
				cd_overlay.position = icon.position
			else:
				cd_overlay.visible = false
		else:
			cd_overlay.visible = false

		if new_types.has(wt):
			_play_new_weapon_anim(slot)


func _play_new_weapon_anim(slot: Dictionary) -> void:
	var panel: PanelContainer = slot["panel"]
	var flash: ColorRect = slot["flash"]

	panel.pivot_offset = panel.size * 0.5
	panel.scale = Vector2(1.3, 1.3)
	flash.color = Color(1, 1, 1, 0.7)

	var tween := panel.create_tween()
	tween.set_parallel(true)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(flash, "color", Color(1, 1, 1, 0), 0.4).set_ease(Tween.EASE_OUT)


# ============================================================
#  Stage objective
# ============================================================

func _get_objective_text() -> String:
	var data: Dictionary = GameData.get_stage_data()
	var cond: String = data.get("win_condition", "survive")
	var val: int = data.get("win_value", 0)
	match cond:
		"kills":
			return "目标: 击杀 %d" % val
		"survive":
			var m: int = int(float(val) / 60.0)
			var s: int = val % 60
			return "目标: 存活 %02d:%02d" % [m, s]
		"boss":
			return "目标: 击败 %d Boss" % val
	return ""


func _process(delta: float) -> void:
	if GameData.is_stage_mode() and _objective_label and _obj_bar:
		_update_objective()

	# Smooth XP fill animation
	_xp_display_fill = lerpf(_xp_display_fill, _xp_fill, delta * 8.0)

	# XP flame animation
	_xp_flame_timer += delta
	if _xp_flame_timer >= 0.15:
		_xp_flame_timer -= 0.15
		_xp_flame_frame = 1 - _xp_flame_frame

	# XP flash decay
	if _xp_flash_timer > 0:
		_xp_flash_timer -= delta
	if _xp_levelup_timer > 0:
		_xp_levelup_timer -= delta

	if _xp_bar:
		_xp_bar.queue_redraw()
	if _obj_bar:
		_obj_bar.queue_redraw()
	_update_weapon_bar()
	_update_portrait(delta)
	_update_passive_indicator()
	_detect_damage()
	_update_boss_bar(delta)
	_update_warning(delta)


func _update_objective() -> void:
	var data: Dictionary = GameData.get_stage_data()
	var cond: String = data.get("win_condition", "survive")
	var val: int = data.get("win_value", 0)

	match cond:
		"kills":
			var current: int = mini(GameData.total_kills, val)
			_objective_label.text = "击杀: %d / %d" % [current, val]
			_obj_cur = float(current)
			_obj_max = float(val)
		"survive":
			var current: float = minf(GameData.elapsed_time, float(val))
			var cm: int = int(current / 60.0)
			var cs: int = int(current) % 60
			var tm: int = int(float(val) / 60.0)
			var ts: int = val % 60
			_objective_label.text = "存活: %02d:%02d / %02d:%02d" % [cm, cs, tm, ts]
			_obj_cur = current
			_obj_max = float(val)
		"boss":
			var current: int = mini(GameData.boss_kills_this_stage, val)
			_objective_label.text = "Boss: %d / %d" % [current, val]
			_obj_cur = float(current)
			_obj_max = float(val)
	_obj_fill = _obj_cur / maxf(_obj_max, 1.0)


func _detect_damage() -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return
	var cur_hp: int = player.current_health
	if _prev_health >= 0 and cur_hp < _prev_health:
		flash_portrait(Color(1.0, 0.2, 0.2))
	_prev_health = cur_hp


# ============================================================
#  Public update API (called by game_manager)
# ============================================================

func update_health(_current: int, _maximum: int) -> void:
	pass


func update_xp(current: int, needed: int, lvl: int) -> void:
	var old_fill: float = _xp_fill
	_xp_cur = current
	_xp_max = needed
	_xp_level = lvl
	_xp_fill = float(current) / float(maxi(needed, 1))

	if _xp_fill > old_fill + 0.01 or _xp_fill < old_fill - 0.5:
		_xp_flash_timer = 0.2

	if lvl > _xp_prev_level and _xp_prev_level > 0:
		_xp_levelup_timer = 0.5
		_xp_display_fill = 0.0
	_xp_prev_level = lvl


func update_time(elapsed: float) -> void:
	if GameData.is_stage_mode():
		var remaining: float = maxf(0.0, GameData.get_stage_data().get("duration", 0.0) - elapsed)
		var minutes := int(remaining / 60.0)
		var seconds := int(remaining) % 60
		_time_label.text = "%02d:%02d" % [minutes, seconds]
		if remaining < 30.0:
			_time_label.add_theme_color_override("font_color", GameData.UI_RED)
		else:
			_time_label.add_theme_color_override("font_color", GameData.UI_GOLD)
	else:
		var minutes := int(elapsed / 60.0)
		var seconds := int(elapsed) % 60
		_time_label.text = "%02d:%02d" % [minutes, seconds]


func update_kills(kills: int) -> void:
	_kill_label.text = "击杀: %d" % kills


func _update_warning(delta: float) -> void:
	if _warn_timer > 0:
		_warn_timer -= delta
		if _warn_timer <= 0:
			_warn_label.visible = false
		else:
			var pulse: float = (sin(Time.get_ticks_msec() * 0.01) + 1.0) * 0.5
			_warn_label.modulate.a = 0.6 + pulse * 0.4


func show_wave_warning() -> void:
	_warn_label.text = "⚠ 怪潮来袭"
	_warn_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.2))
	_warn_label.visible = true
	_warn_timer = 1.5


func show_champion_warning() -> void:
	_warn_label.text = "⚠ 精英来袭"
	_warn_label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.1))
	_warn_label.visible = true
	_warn_timer = 2.0


func show_boss_warning() -> void:
	_warn_label.text = "⚠ 强敌来袭..."
	_warn_label.add_theme_color_override("font_color", Color(0.9, 0.1, 0.1))
	_warn_label.visible = true
	_warn_timer = 3.0


func show_reward_notice(text: String, color: Color = Color.WHITE, duration: float = 2.0) -> void:
	_warn_label.text = text
	_warn_label.add_theme_color_override("font_color", color)
	_warn_label.visible = true
	_warn_timer = duration


func _update_passive_indicator() -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player) or not _passive_lbl:
		return
	var char_data: Dictionary = GameData.get_character_data()
	var status: String = player.passive_status
	if status != "":
		_passive_lbl.text = "★ %s %s" % [char_data.get("passive_name", ""), status]
		_passive_lbl.add_theme_color_override("font_color", GameData.UI_GREEN)
		if status != _prev_passive_status and _prev_passive_status == "":
			flash_portrait(GameData.UI_GREEN)
	else:
		_passive_lbl.text = "★ " + char_data.get("passive_name", "")
		_passive_lbl.add_theme_color_override("font_color", GameData.UI_TEXT_DIM)
	_prev_passive_status = status
