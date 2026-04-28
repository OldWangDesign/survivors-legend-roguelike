extends WeaponBase

var _angle: float = 0.0
var _time: float = 0.0
var _prev_angles: Array[float] = []
const GHOST_COUNT := 4
const SCYTHE_COUNT := 3


func _ready() -> void:
	weapon_type = GameData.WeaponType.DEATH_SCYTHE
	z_index = 3


func attack() -> void:
	pass


func _process(delta: float) -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return

	_time += delta
	var spin_speed := 3.0 + weapon_level * 0.2
	_prev_angles.push_front(_angle)
	if _prev_angles.size() > GHOST_COUNT:
		_prev_angles.resize(GHOST_COUNT)

	_angle += delta * spin_speed
	if _angle > TAU:
		_angle -= TAU

	var area: float = GameData.get_weapon_area(weapon_type, weapon_level)
	var dmg := get_damage()
	var hit_r_sq := 35.0 * 35.0

	for i in range(SCYTHE_COUNT):
		var a := _angle + (TAU / SCYTHE_COUNT) * i
		var blade_pos := player.global_position + Vector2(cos(a), sin(a)) * area
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if blade_pos.distance_squared_to(enemy.global_position) < hit_r_sq:
				enemy.take_damage(dmg * delta * 2.5)

	queue_redraw()


func _draw() -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return
	var area: float = GameData.get_weapon_area(weapon_type, weapon_level)
	var center := player.global_position - global_position

	draw_arc(center, area, 0, TAU, 24, Color(0.4, 0.0, 0.5, 0.08), 2.0)

	for ai in range(_prev_angles.size()):
		var old_a := _prev_angles[ai]
		var ghost_alpha := 0.15 * (1.0 - float(ai) / float(GHOST_COUNT))
		for i in range(SCYTHE_COUNT):
			var a := old_a + (TAU / SCYTHE_COUNT) * float(i)
			var pos := center + Vector2(cos(a), sin(a)) * area
			_draw_scythe(pos, a, ghost_alpha, 0.7)

	for i in range(SCYTHE_COUNT):
		var a := _angle + (TAU / SCYTHE_COUNT) * float(i)
		var pos := center + Vector2(cos(a), sin(a)) * area
		_draw_scythe(pos, a, 1.0, 1.0)
		draw_circle(pos, 8.0, Color(0.5, 0.0, 0.7, 0.15))


func _draw_scythe(pos: Vector2, angle: float, alpha: float, scale_f: float) -> void:
	var dir := Vector2(cos(angle), sin(angle))
	var perp := dir.orthogonal()
	var blade_len := 28.0 * scale_f
	var handle_len := 22.0 * scale_f

	draw_line(pos - dir * handle_len, pos, Color(0.5, 0.4, 0.3, alpha * 0.8), 2.5)

	var tip := pos + perp * blade_len
	var curve_mid := pos + perp * blade_len * 0.7 + dir * blade_len * 0.5
	var base1 := pos + dir * 4.0 * scale_f
	var base2 := pos - dir * 2.0 * scale_f

	var blade_pts := PackedVector2Array([base2, tip, curve_mid, base1])
	draw_colored_polygon(blade_pts, Color(0.4, 0.0, 0.5, alpha * 0.7))

	var inner_tip := pos + perp * blade_len * 0.7
	var inner_pts := PackedVector2Array([pos, inner_tip, curve_mid])
	draw_colored_polygon(inner_pts, Color(0.6, 0.1, 0.8, alpha * 0.4))

	draw_line(pos, tip, Color(0.8, 0.3, 1.0, alpha * 0.6), 1.5)
	draw_line(tip, curve_mid, Color(0.8, 0.3, 1.0, alpha * 0.6), 1.5)

	draw_circle(pos, 3.0 * scale_f, Color(0.7, 0.2, 1.0, alpha * 0.8))
