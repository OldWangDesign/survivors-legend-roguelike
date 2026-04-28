extends Control

var _panel: PanelContainer
var _content: VBoxContainer
var _visible_state: bool = false
var _stats_labels: Dictionary = {}
var _weapons_vbox: VBoxContainer
var _evo_vbox: VBoxContainer
var _char_name_lbl: Label
var _char_role_lbl: Label
var _passive_name_lbl: Label
var _passive_status_lbl: Label
var _passive_desc_lbl: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	theme = GameData.pixel_theme
	add_to_group("stats_panel")
	_build_ui()


func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	_panel.custom_minimum_size.x = 200
	_panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.visible = false

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.04, 0.08, 0.85)
	style.border_color = GameData.UI_BORDER_LO
	style.border_width_right = GameData.PX
	style.set_corner_radius_all(0)
	style.set_content_margin_all(8)
	style.content_margin_top = 50
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)

	var scroll := ScrollContainer.new()
	scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_panel.add_child(scroll)

	_content = VBoxContainer.new()
	_content.add_theme_constant_override("separation", 3)
	_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scroll.add_child(_content)

	# Tab hint
	var tab_hint := Label.new()
	tab_hint.text = "[Tab] 隐藏/显示"
	tab_hint.add_theme_font_size_override("font_size", 10)
	tab_hint.add_theme_color_override("font_color", GameData.UI_TEXT_DIM)
	_content.add_child(tab_hint)

	# Character info section
	var char_data: Dictionary = GameData.get_character_data()
	_char_name_lbl = Label.new()
	_char_name_lbl.text = char_data.get("name", "")
	_char_name_lbl.add_theme_font_size_override("font_size", 16)
	_char_name_lbl.add_theme_color_override("font_color", GameData.UI_GOLD)
	_char_name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_content.add_child(_char_name_lbl)

	_char_role_lbl = Label.new()
	_char_role_lbl.text = "「%s」" % char_data.get("role", "")
	_char_role_lbl.add_theme_font_size_override("font_size", 11)
	_char_role_lbl.add_theme_color_override("font_color", GameData.UI_TEXT_DIM)
	_char_role_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_content.add_child(_char_role_lbl)

	_add_separator()

	_passive_name_lbl = Label.new()
	_passive_name_lbl.text = char_data.get("passive_name", "")
	_passive_name_lbl.add_theme_font_size_override("font_size", 13)
	_passive_name_lbl.add_theme_color_override("font_color", GameData.UI_GOLD)
	_passive_name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_content.add_child(_passive_name_lbl)

	_passive_status_lbl = Label.new()
	_passive_status_lbl.text = ""
	_passive_status_lbl.add_theme_font_size_override("font_size", 11)
	_passive_status_lbl.add_theme_color_override("font_color", GameData.UI_GREEN)
	_passive_status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_content.add_child(_passive_status_lbl)

	_passive_desc_lbl = Label.new()
	_passive_desc_lbl.text = char_data.get("passive_desc", "")
	_passive_desc_lbl.add_theme_font_size_override("font_size", 9)
	_passive_desc_lbl.add_theme_color_override("font_color", Color(GameData.UI_TEXT_DIM, 0.7))
	_passive_desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_passive_desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	_content.add_child(_passive_desc_lbl)

	_add_separator()

	_add_section_title("角色属性")
	_add_stat_row("level", "等  级", "1", GameData.UI_BLUE)
	_add_stat_row("hp", "生  命", "100/100", GameData.UI_RED)
	_add_stat_row("speed", "移  速", "100%", Color.SKY_BLUE)
	_add_stat_row("damage", "攻  击", "100%", Color.ORANGE_RED)
	_add_stat_row("area", "范  围", "100%", Color.PURPLE)
	_add_stat_row("cooldown", "冷  却", "100%", GameData.UI_GREEN)
	_add_stat_row("pickup", "拾  取", "100%", GameData.UI_GOLD)
	_add_stat_row("armor", "护  甲", "0", Color.GRAY)

	_add_separator()
	_add_section_title("击杀统计")
	_add_stat_row("kills", "击  杀", "0", GameData.UI_RED)
	_add_stat_row("time", "时  间", "00:00", GameData.UI_GOLD)

	_add_separator()
	_add_section_title("持有技能")
	_weapons_vbox = VBoxContainer.new()
	_weapons_vbox.add_theme_constant_override("separation", 2)
	_weapons_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content.add_child(_weapons_vbox)

	_add_separator()
	_add_section_title("可合成")
	_evo_vbox = VBoxContainer.new()
	_evo_vbox.add_theme_constant_override("separation", 2)
	_evo_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content.add_child(_evo_vbox)


func _add_section_title(text: String) -> void:
	var lbl := Label.new()
	lbl.text = "-- %s --" % text
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", GameData.UI_GOLD)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_content.add_child(lbl)


func _add_separator() -> void:
	var sep := ColorRect.new()
	sep.custom_minimum_size = Vector2(0, 1)
	sep.color = GameData.UI_BORDER_LO
	sep.color.a = 0.3
	_content.add_child(sep)


func _add_stat_row(key: String, label_text: String, default_val: String, color: Color) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content.add_child(row)

	var name_lbl := Label.new()
	name_lbl.text = label_text
	name_lbl.add_theme_font_size_override("font_size", 12)
	name_lbl.add_theme_color_override("font_color", GameData.UI_TEXT_DIM)
	name_lbl.custom_minimum_size.x = 60
	row.add_child(name_lbl)

	var val_lbl := Label.new()
	val_lbl.text = default_val
	val_lbl.add_theme_font_size_override("font_size", 12)
	val_lbl.add_theme_color_override("font_color", color)
	val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	val_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(val_lbl)

	_stats_labels[key] = val_lbl


func _process(_delta: float) -> void:
	if not _visible_state:
		return
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return

	_stats_labels["level"].text = str(player.level)
	_stats_labels["hp"].text = "%d/%d" % [player.current_health, player.max_health]
	_stats_labels["speed"].text = "%d%%" % int(player.speed_mult * 100)
	_stats_labels["damage"].text = "%d%%" % int(player.damage_mult * 100)
	_stats_labels["area"].text = "%d%%" % int(player.area_mult * 100)
	_stats_labels["cooldown"].text = "%d%%" % int(player.cooldown_mult * 100)
	_stats_labels["pickup"].text = "%d%%" % int(player.pickup_range_mult * 100)
	_stats_labels["armor"].text = str(player.armor)
	_stats_labels["kills"].text = str(GameData.total_kills)

	if _passive_status_lbl:
		_passive_status_lbl.text = player.passive_status if player.passive_status != "" else "生效中"

	var elapsed := GameData.elapsed_time
	var minutes := int(elapsed) / 60
	var seconds := int(elapsed) % 60
	_stats_labels["time"].text = "%02d:%02d" % [minutes, seconds]

	_update_weapons(player)
	_update_evolutions(player)


func _update_weapons(player: CharacterBody2D) -> void:
	var needed: int = player.weapons.size()
	while _weapons_vbox.get_child_count() < needed:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 4)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var icon := ColorRect.new()
		icon.custom_minimum_size = Vector2(8, 8)
		row.add_child(icon)

		var name_lbl := Label.new()
		name_lbl.add_theme_font_size_override("font_size", 11)
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_lbl)

		var lv_lbl := Label.new()
		lv_lbl.add_theme_font_size_override("font_size", 11)
		lv_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(lv_lbl)

		_weapons_vbox.add_child(row)

	while _weapons_vbox.get_child_count() > needed:
		var last := _weapons_vbox.get_child(_weapons_vbox.get_child_count() - 1)
		_weapons_vbox.remove_child(last)
		last.queue_free()

	for i in range(needed):
		var w: Dictionary = player.weapons[i]
		var wt: int = w["type"]
		var data: Dictionary = GameData.WEAPON_DATA[wt]
		var row: HBoxContainer = _weapons_vbox.get_child(i)
		var icon: ColorRect = row.get_child(0)
		var name_lbl: Label = row.get_child(1)
		var lv_lbl: Label = row.get_child(2)

		icon.color = data["icon_color"]
		name_lbl.text = data["name"]
		name_lbl.add_theme_color_override("font_color", data["icon_color"].lightened(0.3))
		lv_lbl.text = "Lv.%d" % w["level"]
		lv_lbl.add_theme_color_override("font_color", GameData.UI_GOLD if w["level"] >= 8 else Color.WHITE)


func _update_evolutions(player: CharacterBody2D) -> void:
	for child in _evo_vbox.get_children():
		_evo_vbox.remove_child(child)
		child.queue_free()

	for evo_type in GameData.EVOLUTION_RECIPES.keys():
		var recipe: Array = GameData.EVOLUTION_RECIPES[evo_type]
		var evo_data: Dictionary = GameData.WEAPON_DATA[evo_type]
		if player.has_weapon(evo_type):
			continue
		var has_a: bool = player.has_weapon(recipe[0])
		var has_b: bool = player.has_weapon(recipe[1])
		if not has_a and not has_b:
			continue

		var lv_a: int = player.get_weapon_level(recipe[0])
		var lv_b: int = player.get_weapon_level(recipe[1])
		var is_ready: bool = lv_a >= 8 and lv_b >= 8
		var name_a: String = GameData.WEAPON_DATA[recipe[0]]["name"]
		var name_b: String = GameData.WEAPON_DATA[recipe[1]]["name"]

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 4)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_evo_vbox.add_child(row)

		var icon := ColorRect.new()
		icon.custom_minimum_size = Vector2(8, 8)
		icon.color = evo_data["icon_color"] if is_ready else Color(0.3, 0.3, 0.3)
		row.add_child(icon)

		var info := Label.new()
		info.add_theme_font_size_override("font_size", 10)
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if is_ready:
			info.text = evo_data["name"] + " ★"
			info.add_theme_color_override("font_color", GameData.UI_GOLD)
		else:
			info.text = "%s(%d)+%s(%d)" % [name_a, lv_a, name_b, lv_b]
			info.add_theme_color_override("font_color", GameData.UI_TEXT_DIM)
		row.add_child(info)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		_visible_state = not _visible_state
		_panel.visible = _visible_state
		get_viewport().set_input_as_handled()
