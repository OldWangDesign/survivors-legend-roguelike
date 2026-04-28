extends Control

var _current_index: int = 0
var _preview: TextureRect
var _name_lbl: Label
var _role_lbl: Label
var _weapon_icon: TextureRect
var _weapon_name_lbl: Label
var _passive_name_lbl: Label
var _passive_desc_lbl: Label
var _confirm_btn: Button
var _lock_overlay: Label
var _unlock_lbl: Label
var _counter_lbl: Label
var _stat_bars: Dictionary = {}
var _anim_timer: float = 0.0
var _anim_frame: int = 0
var _original_style: String = ""

const STAT_COLORS: Dictionary = {
	"hp": Color(0.85, 0.2, 0.2),
	"speed": Color(0.25, 0.6, 1.0),
	"damage": Color(1.0, 0.5, 0.1),
	"cooldown": Color(0.2, 0.8, 0.3),
	"pickup": Color(0.6, 0.3, 0.9),
}

const STAT_MAX: Dictionary = {
	"hp": 160.0,
	"speed": 280.0,
	"damage": 1.8,
	"cooldown": 1.2,
	"pickup": 2.0,
}

const STAT_NAMES: Dictionary = {
	"hp": "血  量",
	"speed": "速  度",
	"damage": "攻  击",
	"cooldown": "冷  却",
	"pickup": "拾  取",
}

const CARD_WIDTH: float = 520.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	theme = GameData.pixel_theme
	_original_style = GameData.current_style
	var sel: String = GameData.selected_character
	for i in range(GameData.CHARACTER_ORDER.size()):
		if GameData.CHARACTER_ORDER[i] == sel:
			_current_index = i
			break
	_build_ui()
	_refresh()


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
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)

	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 10)
	margin.add_child(outer)

	# ── Title ──
	var title := Label.new()
	title.text = "= 选择角色 ="
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", GameData.UI_GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outer.add_child(title)

	# ── Card area (centered) ──
	var card_center := CenterContainer.new()
	card_center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer.add_child(card_center)

	var card := PanelContainer.new()
	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color(0.06, 0.06, 0.12, 0.95)
	card_style.border_color = GameData.UI_BORDER_HI
	card_style.set_border_width_all(GameData.PX)
	card_style.set_corner_radius_all(0)
	card_style.set_content_margin_all(20)
	card.add_theme_stylebox_override("panel", card_style)
	card.custom_minimum_size = Vector2(CARD_WIDTH, 0)
	card_center.add_child(card)

	var card_vbox := VBoxContainer.new()
	card_vbox.add_theme_constant_override("separation", 10)
	card.add_child(card_vbox)

	# ── Row 1: Nav arrows + Name + Role ──
	var nav_row := HBoxContainer.new()
	nav_row.add_theme_constant_override("separation", 12)
	nav_row.alignment = BoxContainer.ALIGNMENT_CENTER
	card_vbox.add_child(nav_row)

	var prev_btn := Button.new()
	prev_btn.text = " ◀ "
	prev_btn.custom_minimum_size = Vector2(40, 36)
	prev_btn.pressed.connect(_on_prev)
	prev_btn.mouse_entered.connect(func(): AudioManager.play_ui("ui_hover"))
	nav_row.add_child(prev_btn)

	var name_col := VBoxContainer.new()
	name_col.add_theme_constant_override("separation", 0)
	name_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_col.alignment = BoxContainer.ALIGNMENT_CENTER
	nav_row.add_child(name_col)

	_name_lbl = Label.new()
	_name_lbl.add_theme_font_size_override("font_size", 24)
	_name_lbl.add_theme_color_override("font_color", GameData.UI_GOLD)
	_name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_col.add_child(_name_lbl)

	_role_lbl = Label.new()
	_role_lbl.add_theme_font_size_override("font_size", 12)
	_role_lbl.add_theme_color_override("font_color", GameData.UI_TEXT_DIM)
	_role_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_col.add_child(_role_lbl)

	var next_btn := Button.new()
	next_btn.text = " ▶ "
	next_btn.custom_minimum_size = Vector2(40, 36)
	next_btn.pressed.connect(_on_next)
	next_btn.mouse_entered.connect(func(): AudioManager.play_ui("ui_hover"))
	nav_row.add_child(next_btn)

	# ── Row 2: Character preview (centered, large) ──
	var preview_center := CenterContainer.new()
	card_vbox.add_child(preview_center)

	var preview_frame := PanelContainer.new()
	var pf_style := StyleBoxFlat.new()
	pf_style.bg_color = Color(0.03, 0.03, 0.06, 0.8)
	pf_style.border_color = GameData.UI_BORDER_LO
	pf_style.set_border_width_all(GameData.PX)
	pf_style.set_corner_radius_all(0)
	pf_style.set_content_margin_all(12)
	preview_frame.add_theme_stylebox_override("panel", pf_style)
	preview_center.add_child(preview_frame)

	var inner_center := CenterContainer.new()
	preview_frame.add_child(inner_center)

	_preview = TextureRect.new()
	_preview.custom_minimum_size = Vector2(128, 128)
	_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_preview.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	inner_center.add_child(_preview)

	_lock_overlay = Label.new()
	_lock_overlay.text = "LOCKED"
	_lock_overlay.add_theme_font_size_override("font_size", 24)
	_lock_overlay.add_theme_color_override("font_color", Color(1, 0.3, 0.3, 0.9))
	_lock_overlay.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lock_overlay.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_lock_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_lock_overlay.visible = false
	preview_frame.add_child(_lock_overlay)

	# ── Row 3: Weapon + Passive (side by side) ──
	var info_row := HBoxContainer.new()
	info_row.add_theme_constant_override("separation", 20)
	info_row.alignment = BoxContainer.ALIGNMENT_CENTER
	card_vbox.add_child(info_row)

	var weapon_col := HBoxContainer.new()
	weapon_col.add_theme_constant_override("separation", 5)
	info_row.add_child(weapon_col)

	var wlabel := Label.new()
	wlabel.text = "⚔"
	wlabel.add_theme_font_size_override("font_size", 14)
	wlabel.add_theme_color_override("font_color", GameData.UI_TEXT_DIM)
	weapon_col.add_child(wlabel)

	_weapon_icon = TextureRect.new()
	_weapon_icon.custom_minimum_size = Vector2(16, 16)
	_weapon_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_weapon_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	weapon_col.add_child(_weapon_icon)

	_weapon_name_lbl = Label.new()
	_weapon_name_lbl.add_theme_font_size_override("font_size", 13)
	weapon_col.add_child(_weapon_name_lbl)

	var divider_lbl := Label.new()
	divider_lbl.text = "|"
	divider_lbl.add_theme_font_size_override("font_size", 13)
	divider_lbl.add_theme_color_override("font_color", GameData.UI_BORDER_LO)
	info_row.add_child(divider_lbl)

	var passive_col := HBoxContainer.new()
	passive_col.add_theme_constant_override("separation", 5)
	info_row.add_child(passive_col)

	var plabel := Label.new()
	plabel.text = "★"
	plabel.add_theme_font_size_override("font_size", 14)
	plabel.add_theme_color_override("font_color", GameData.UI_GOLD)
	passive_col.add_child(plabel)

	_passive_name_lbl = Label.new()
	_passive_name_lbl.add_theme_font_size_override("font_size", 13)
	_passive_name_lbl.add_theme_color_override("font_color", GameData.UI_GOLD)
	passive_col.add_child(_passive_name_lbl)

	# Passive description
	_passive_desc_lbl = Label.new()
	_passive_desc_lbl.add_theme_font_size_override("font_size", 11)
	_passive_desc_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.65, 0.8))
	_passive_desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_passive_desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	card_vbox.add_child(_passive_desc_lbl)

	# ── Separator ──
	var sep_line := ColorRect.new()
	sep_line.custom_minimum_size = Vector2(0, 1)
	sep_line.color = GameData.UI_BORDER_LO
	sep_line.color.a = 0.3
	card_vbox.add_child(sep_line)

	# ── Stat bars ──
	var stat_keys: Array = ["hp", "speed", "damage", "cooldown", "pickup"]
	for key in stat_keys:
		_create_stat_bar(card_vbox, key, STAT_NAMES[key])

	# ── Unlock condition ──
	_unlock_lbl = Label.new()
	_unlock_lbl.add_theme_font_size_override("font_size", 12)
	_unlock_lbl.add_theme_color_override("font_color", GameData.UI_RED)
	_unlock_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_unlock_lbl.visible = false
	card_vbox.add_child(_unlock_lbl)

	# ── Bottom: Counter + Buttons ──
	var bottom := HBoxContainer.new()
	bottom.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom.add_theme_constant_override("separation", 16)
	outer.add_child(bottom)

	var back_btn := Button.new()
	back_btn.text = "返回"
	back_btn.custom_minimum_size = Vector2(120, 40)
	back_btn.add_theme_font_size_override("font_size", 18)
	back_btn.pressed.connect(_on_back)
	back_btn.mouse_entered.connect(func(): AudioManager.play_ui("ui_hover"))
	bottom.add_child(back_btn)

	_counter_lbl = Label.new()
	_counter_lbl.add_theme_font_size_override("font_size", 14)
	_counter_lbl.add_theme_color_override("font_color", GameData.UI_TEXT_DIM)
	_counter_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_counter_lbl.custom_minimum_size.x = 60
	bottom.add_child(_counter_lbl)

	_confirm_btn = Button.new()
	_confirm_btn.text = "确认选择"
	_confirm_btn.custom_minimum_size = Vector2(160, 40)
	_confirm_btn.add_theme_font_size_override("font_size", 18)
	_confirm_btn.pressed.connect(_on_confirm)
	_confirm_btn.mouse_entered.connect(func(): AudioManager.play_ui("ui_hover"))
	bottom.add_child(_confirm_btn)


func _create_stat_bar(parent: VBoxContainer, key: String, label_text: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	parent.add_child(row)

	var name_lbl := Label.new()
	name_lbl.text = label_text
	name_lbl.add_theme_font_size_override("font_size", 12)
	name_lbl.add_theme_color_override("font_color", GameData.UI_TEXT_DIM)
	name_lbl.custom_minimum_size.x = 50
	row.add_child(name_lbl)

	var bar_bg := ColorRect.new()
	bar_bg.custom_minimum_size = Vector2(180, 12)
	bar_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar_bg.color = Color(0.06, 0.06, 0.1)
	bar_bg.clip_contents = true
	row.add_child(bar_bg)

	var bar_fill := ColorRect.new()
	bar_fill.color = STAT_COLORS.get(key, Color.WHITE)
	bar_fill.position = Vector2.ZERO
	bar_fill.size = Vector2(0, 12)
	bar_bg.add_child(bar_fill)

	var val_lbl := Label.new()
	val_lbl.add_theme_font_size_override("font_size", 12)
	val_lbl.add_theme_color_override("font_color", STAT_COLORS.get(key, Color.WHITE))
	val_lbl.custom_minimum_size.x = 50
	val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(val_lbl)

	_stat_bars[key] = {"bg": bar_bg, "fill": bar_fill, "val": val_lbl, "ratio": 0.0}


func _refresh() -> void:
	var char_id: String = GameData.CHARACTER_ORDER[_current_index]
	var data: Dictionary = GameData.CHARACTER_DATA[char_id]
	var unlocked: bool = GameData.is_character_unlocked(char_id)

	GameData.switch_style(data["style"])
	var frames: Array = GameData.sprites.get("player", [])
	if frames.size() > 0:
		_preview.texture = frames[0]
		_anim_frame = 0

	_name_lbl.text = data["name"]
	_role_lbl.text = "「%s」" % data["role"]
	_counter_lbl.text = "%d / %d" % [_current_index + 1, GameData.CHARACTER_ORDER.size()]

	var wt: int = data["weapon"]
	var wdata: Dictionary = GameData.WEAPON_DATA[wt]
	_weapon_name_lbl.text = wdata["name"]
	_weapon_name_lbl.add_theme_color_override("font_color", wdata["icon_color"].lightened(0.3))
	if GameData.weapon_icons.has(wt):
		_weapon_icon.texture = GameData.weapon_icons[wt]

	_passive_name_lbl.text = data["passive_name"]
	_passive_desc_lbl.text = data["passive_desc"]

	_update_stat("hp", float(data["max_health"]), str(data["max_health"]))
	_update_stat("speed", data["base_speed"], str(int(data["base_speed"])))
	_update_stat("damage", data["damage_mult"], "x%.2f" % data["damage_mult"])
	var cd_display: float = STAT_MAX["cooldown"] - data["cooldown_mult"] + 0.1
	_update_stat("cooldown", cd_display, "x%.2f" % data["cooldown_mult"])
	_update_stat("pickup", data["pickup_mult"], "x%.1f" % data["pickup_mult"])

	_lock_overlay.visible = not unlocked
	_confirm_btn.disabled = not unlocked

	_unlock_lbl.visible = true
	if not unlocked:
		_unlock_lbl.text = _get_unlock_text(data)
		_unlock_lbl.add_theme_color_override("font_color", GameData.UI_RED)
	else:
		_unlock_lbl.text = "✦ 已解锁 ✦"
		_unlock_lbl.add_theme_color_override("font_color", Color(0.3, 0.8, 0.4, 0.7))


func _update_stat(key: String, value: float, text: String) -> void:
	if not _stat_bars.has(key):
		return
	var info: Dictionary = _stat_bars[key]
	var max_v: float = STAT_MAX.get(key, 1.0)
	var ratio: float = clampf(value / max_v, 0.0, 1.0)
	info["ratio"] = ratio
	var bg: ColorRect = info["bg"]
	var fill: ColorRect = info["fill"]
	var val_lbl: Label = info["val"]
	if bg.size.x > 0:
		fill.size = Vector2(bg.size.x * ratio, bg.size.y)
	val_lbl.text = text


func _get_unlock_text(data: Dictionary) -> String:
	var ut: String = data["unlock_type"]
	var uv = data["unlock_value"]
	match ut:
		"stage":
			return "解锁条件: 通关第 %d 关" % int(uv)
		"stage_all":
			return "解锁条件: 通关全部 %d 关" % int(uv)
		"survival":
			var m: int = int(uv) / 60
			return "解锁条件: 自由模式存活 %d 分钟" % m
		"kills":
			return "解锁条件: 累计击杀 %d" % int(uv)
	return ""


func _on_prev() -> void:
	AudioManager.play_ui("ui_click")
	_current_index = (_current_index - 1 + GameData.CHARACTER_ORDER.size()) % GameData.CHARACTER_ORDER.size()
	_refresh()


func _on_next() -> void:
	AudioManager.play_ui("ui_click")
	_current_index = (_current_index + 1) % GameData.CHARACTER_ORDER.size()
	_refresh()


func _on_confirm() -> void:
	AudioManager.play_ui("ui_click")
	var char_id: String = GameData.CHARACTER_ORDER[_current_index]
	if not GameData.is_character_unlocked(char_id):
		return
	GameData.selected_character = char_id
	var data: Dictionary = GameData.CHARACTER_DATA[char_id]
	GameData.switch_style(data["style"])
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_back() -> void:
	AudioManager.play_ui("ui_click")
	GameData.switch_style(_original_style)
	if GameData.current_stage > 0:
		get_tree().change_scene_to_file("res://scenes/stage_select.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _process(delta: float) -> void:
	_anim_timer += delta
	if _anim_timer >= 0.35:
		_anim_timer -= 0.35
		_anim_frame = 1 - _anim_frame
		var frames: Array = GameData.sprites.get("player", [])
		if _anim_frame < frames.size():
			_preview.texture = frames[_anim_frame]

	for key in _stat_bars:
		var info: Dictionary = _stat_bars[key]
		var bg: ColorRect = info["bg"]
		var fill: ColorRect = info["fill"]
		var ratio: float = info["ratio"]
		if bg.size.x > 0:
			fill.size = Vector2(bg.size.x * ratio, bg.size.y)


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed):
		return
	match event.keycode:
		KEY_LEFT:
			_on_prev()
			get_viewport().set_input_as_handled()
		KEY_RIGHT:
			_on_next()
			get_viewport().set_input_as_handled()
		KEY_ENTER, KEY_KP_ENTER:
			_on_confirm()
			get_viewport().set_input_as_handled()
		KEY_ESCAPE:
			_on_back()
			get_viewport().set_input_as_handled()
