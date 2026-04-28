extends WeaponBase

var _orbit_angle: float = 0.0
var _active: bool = false
var _active_timer: float = 0.0
var _rune_phase: float = 0.0


func _ready() -> void:
	weapon_type = GameData.WeaponType.BIBLE


func attack() -> void:
	_active = true
	var data: Dictionary = GameData.WEAPON_DATA[weapon_type]
	_active_timer = data.get("base_duration", 4.0) + weapon_level * 0.5
	play_weapon_sound()
	start_cooldown()


func _process(delta: float) -> void:
	if not _active:
		return
	_active_timer -= delta
	if _active_timer <= 0:
		_active = false
		return

	var player := GameData.player_ref
	if not is_instance_valid(player):
		return

	var radius := GameData.get_weapon_area(weapon_type, weapon_level)
	var book_count := 2 + weapon_level / 2
	var spin_speed := 3.5

	_orbit_angle += delta * spin_speed
	_rune_phase += delta * 2.0
	if _orbit_angle > TAU:
		_orbit_angle -= TAU

	var dmg := get_damage()
	var hit_r_sq := 22.0 * 22.0
	for i in range(book_count):
		var angle := _orbit_angle + (TAU / book_count) * i
		var book_pos := player.global_position + Vector2(cos(angle), sin(angle)) * radius
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if book_pos.distance_squared_to(enemy.global_position) < hit_r_sq:
				enemy.take_damage(dmg * delta * 3.0)

	queue_redraw()


func _draw() -> void:
	if not _active:
		return
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return
	var radius := GameData.get_weapon_area(weapon_type, weapon_level)
	var book_count := 2 + weapon_level / 2
	var center := player.global_position - global_position

	draw_arc(center, radius, 0, TAU, 24, Color(1.0, 0.85, 0.3, 0.08), 2.0)

	for i in range(book_count):
		var angle := _orbit_angle + (TAU / book_count) * i
		var offset := Vector2(cos(angle), sin(angle)) * radius
		var pos := center + offset

		draw_circle(pos, 12.0, Color(1.0, 0.9, 0.4, 0.15))

		draw_rect(Rect2(pos.x - 7, pos.y - 8, 14, 16), Color(0.96, 0.92, 0.75))
		draw_rect(Rect2(pos.x - 7, pos.y - 8, 14, 16), Color(0.85, 0.7, 0.2), false, 2.0)
		draw_line(Vector2(pos.x, pos.y - 7), Vector2(pos.x, pos.y + 7), Color(0.7, 0.55, 0.15), 1.5)

		draw_circle(pos, 3.5, Color(1.0, 0.95, 0.7, 0.8))
		draw_circle(pos, 2.0, Color(1, 1, 1, 0.9))
