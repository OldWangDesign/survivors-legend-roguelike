extends WeaponBase

var _blade_angle: float = 0.0
var _prev_angles: Array[float] = []
var _time: float = 0.0
const AFTERIMAGE_COUNT := 3


func _ready() -> void:
	weapon_type = GameData.WeaponType.SPIN_BLADE


func _process(delta: float) -> void:
	if not is_inside_tree():
		return
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return

	_time += delta
	var radius := GameData.get_weapon_area(weapon_type, weapon_level)
	var blade_count := 2 + weapon_level / 2
	var spin_speed := 4.0 + weapon_level * 0.3

	_prev_angles.push_front(_blade_angle)
	if _prev_angles.size() > AFTERIMAGE_COUNT:
		_prev_angles.resize(AFTERIMAGE_COUNT)

	_blade_angle += delta * spin_speed
	if _blade_angle > TAU:
		_blade_angle -= TAU

	var dmg := get_damage()
	var hit_r_sq := 24.0 * 24.0

	for i in range(blade_count):
		var angle := _blade_angle + (TAU / blade_count) * i
		var blade_pos := player.global_position + Vector2(cos(angle), sin(angle)) * radius
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if blade_pos.distance_squared_to(enemy.global_position) < hit_r_sq:
				enemy.take_damage(dmg * delta)
	queue_redraw()


func attack() -> void:
	pass


func _draw() -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return
	var radius := GameData.get_weapon_area(weapon_type, weapon_level)
	var blade_count := 2 + weapon_level / 2
	var center := player.global_position - global_position

	draw_arc(center, radius, 0, TAU, 24, Color(0.5, 0.7, 1.0, 0.1), 2.0)

	for ai in range(_prev_angles.size()):
		var old_angle := _prev_angles[ai]
		var ghost_alpha := 0.2 * (1.0 - float(ai) / float(AFTERIMAGE_COUNT))
		for i in range(blade_count):
			var angle := old_angle + (TAU / blade_count) * i
			var offset := Vector2(cos(angle), sin(angle)) * radius
			var blade_pos := center + offset
			var dir_out := offset.normalized()
			var perp := dir_out.orthogonal()
			var tip := blade_pos + dir_out * 8.0
			var back := blade_pos - dir_out * 4.0
			var side1 := blade_pos + perp * 14.0
			var side2 := blade_pos - perp * 14.0
			var pts := PackedVector2Array([tip, side1, back, side2])
			draw_colored_polygon(pts, Color(0.5, 0.7, 1.0, ghost_alpha * 0.5))

	for i in range(blade_count):
		var angle := _blade_angle + (TAU / blade_count) * i
		var offset := Vector2(cos(angle), sin(angle)) * radius
		var blade_pos := center + offset
		var dir_out := offset.normalized()
		var perp := dir_out.orthogonal()

		var tip := blade_pos + dir_out * 10.0
		var back := blade_pos - dir_out * 5.0
		var side1 := blade_pos + perp * 16.0
		var side2 := blade_pos - perp * 16.0

		var pts := PackedVector2Array([tip, side1, back, side2])
		draw_colored_polygon(pts, Color(0.75, 0.88, 1.0, 0.7))

		draw_line(side1, tip, Color(1, 1, 1, 0.6), 1.5)
		draw_line(side2, tip, Color(1, 1, 1, 0.6), 1.5)

		draw_circle(blade_pos, 3.0, Color(1, 1, 1, 0.7))
