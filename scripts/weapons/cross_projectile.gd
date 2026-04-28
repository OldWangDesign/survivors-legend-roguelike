extends Node2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 350.0
var damage: int = 12
var max_range: float = 250.0
var _origin: Vector2
var _returning: bool = false
var _hit_cooldown: Dictionary = {}
var _rotation_angle: float = 0.0
var _trail_positions: Array[Vector2] = []
var _time: float = 0.0

const HIT_INTERVAL := 0.3
const TRAIL_LENGTH := 16


func setup(dir: Vector2, spd: float, dmg: int, max_r: float) -> void:
	direction = dir.normalized()
	speed = spd
	damage = dmg
	max_range = max_r
	_origin = global_position
	z_index = 3


func _physics_process(delta: float) -> void:
	_rotation_angle += delta * 16.0
	_time += delta

	_trail_positions.push_front(global_position)
	if _trail_positions.size() > TRAIL_LENGTH:
		_trail_positions.resize(TRAIL_LENGTH)

	if not _returning:
		position += direction * speed * delta
		speed -= delta * 300.0
		if speed <= 0 or _origin.distance_to(global_position) >= max_range:
			_returning = true
			speed = 50.0
	else:
		var player := GameData.player_ref
		if not is_instance_valid(player):
			queue_free()
			return
		var to_player := player.global_position - global_position
		var dist := to_player.length()
		if dist < 20.0:
			queue_free()
			return
		direction = to_player.normalized()
		speed = minf(speed + delta * 600.0, 500.0)
		position += direction * speed * delta

	var keys_to_remove: Array = []
	for enemy_id in _hit_cooldown:
		_hit_cooldown[enemy_id] -= delta
		if _hit_cooldown[enemy_id] <= 0:
			keys_to_remove.append(enemy_id)
	for k in keys_to_remove:
		_hit_cooldown.erase(k)

	var hit_r_sq := 22.0 * 22.0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var eid: int = enemy.get_instance_id()
		if _hit_cooldown.has(eid):
			continue
		if global_position.distance_squared_to(enemy.global_position) < hit_r_sq:
			enemy.take_damage(damage)
			_hit_cooldown[eid] = HIT_INTERVAL
			VfxPool.hit_flash(enemy.global_position, Color(1.0, 0.9, 0.3), 16.0)
			VfxPool.spark_burst(enemy.global_position, 5, Color(1.0, 0.85, 0.2), 50.0, 0.2)

	queue_redraw()


func _draw() -> void:
	# Stardust trail with golden shimmer
	for i in range(_trail_positions.size() - 1):
		var t := 1.0 - float(i) / float(_trail_positions.size())
		var from := _trail_positions[i] - global_position
		var to := _trail_positions[i + 1] - global_position
		# Outer divine glow
		draw_line(from, to, Color(1.0, 0.85, 0.2, t * 0.08), 12.0 * t)
		# Mid golden trail
		draw_line(from, to, Color(1.0, 0.9, 0.4, t * 0.35), 4.0 * t)
		# Core white trail
		draw_line(from, to, Color(1.0, 0.98, 0.8, t * 0.2), 8.0 * t)
		# Stardust particles along trail
		if i % 2 == 0:
			var mid := (from + to) * 0.5
			var wobble := Vector2(sin(_time * 8.0 + float(i)) * 4.0, cos(_time * 6.0 + float(i)) * 4.0) * t
			draw_circle(mid + wobble, 2.0 * t, Color(1.0, 0.95, 0.6, t * 0.7))
			draw_circle(mid - wobble, 1.5 * t, Color(1, 1, 1, t * 0.4))

	# Outer divine aura
	var pulse := sin(_time * 10.0) * 0.15 + 0.85
	draw_circle(Vector2.ZERO, 20.0 * pulse, Color(1.0, 0.85, 0.2, 0.06))
	draw_circle(Vector2.ZERO, 14.0 * pulse, Color(1.0, 0.9, 0.4, 0.12))

	# Rotating cross with thick arms and glow
	var s := 11.0
	var c := cos(_rotation_angle)
	var sn := sin(_rotation_angle)
	for m in [1.0, -1.0]:
		var arm1 := Vector2(c * s * m, sn * s * m)
		var arm2 := Vector2(-sn * s * m, c * s * m)
		# Glow layer
		draw_line(Vector2.ZERO, arm1, Color(1.0, 0.85, 0.2, 0.15), 10.0)
		draw_line(Vector2.ZERO, arm2, Color(1.0, 0.85, 0.2, 0.15), 10.0)
		# Mid
		draw_line(Vector2.ZERO, arm1, Color(1.0, 0.92, 0.5, 0.6), 4.0)
		draw_line(Vector2.ZERO, arm2, Color(1.0, 0.92, 0.5, 0.6), 4.0)
		# Core bright
		draw_line(Vector2.ZERO, arm1, Color(1, 1, 0.9, 0.8), 2.0)
		draw_line(Vector2.ZERO, arm2, Color(1, 1, 0.9, 0.8), 2.0)
		# Arm tip glow
		draw_circle(arm1, 3.0, Color(1.0, 0.95, 0.7, 0.5))
		draw_circle(arm2, 3.0, Color(1.0, 0.95, 0.7, 0.5))

	# Radiating divine light beams
	for i in range(8):
		var beam_angle := _rotation_angle * 0.5 + (TAU / 8.0) * i
		var beam_len := 18.0 * pulse
		var beam_end := Vector2(cos(beam_angle), sin(beam_angle)) * beam_len
		draw_line(Vector2.ZERO, beam_end, Color(1.0, 0.95, 0.6, 0.12), 2.0)

	# Bright core
	draw_circle(Vector2.ZERO, 5.0, Color(1.0, 0.95, 0.7, 0.8))
	draw_circle(Vector2.ZERO, 3.0, Color(1, 1, 1, 0.95))

	# Orbiting sparkles
	for i in range(4):
		var orbit_angle := _time * 6.0 + (TAU / 4.0) * i
		var orbit_r := 9.0
		var op := Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_r
		draw_circle(op, 1.5, Color(1.0, 0.9, 0.5, 0.6))
