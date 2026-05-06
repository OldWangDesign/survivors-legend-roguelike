extends Node2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 400.0
var damage: int = 6
var _slow_mult: float = 0.35
var _slow_dur: float = 2.0
var _timer: float = 1.5
var _hit_enemies: Dictionary = {}
var _trail_positions: Array[Vector2] = []
var _time: float = 0.0

const HIT_INTERVAL := 0.4
const TRAIL_LENGTH := 16


func setup(dir: Vector2, spd: float, dmg: int, slow_mult: float, slow_dur: float) -> void:
	direction = dir.normalized()
	speed = spd
	damage = dmg
	_slow_mult = slow_mult
	_slow_dur = slow_dur
	z_index = 3


func _physics_process(delta: float) -> void:
	_time += delta
	_timer -= delta
	if _timer <= 0:
		queue_free()
		return
	position += direction * speed * delta

	_trail_positions.push_front(global_position)
	if _trail_positions.size() > TRAIL_LENGTH:
		_trail_positions.resize(TRAIL_LENGTH)

	var keys_to_remove: Array = []
	for eid in _hit_enemies:
		_hit_enemies[eid] -= delta
		if _hit_enemies[eid] <= 0:
			keys_to_remove.append(eid)
	for k in keys_to_remove:
		_hit_enemies.erase(k)

	var hit_r_sq := 18.0 * 18.0
	for enemy in SpatialGrid.get_nearby(global_position, 18.0):
		var eid: int = enemy.get_instance_id()
		if _hit_enemies.has(eid):
			continue
		if global_position.distance_squared_to(enemy.global_position) < hit_r_sq:
			enemy.take_damage(damage)
			enemy.apply_slow(_slow_mult, _slow_dur)
			_hit_enemies[eid] = HIT_INTERVAL
			VfxPool.spark_burst(enemy.global_position, 6, Color(0.5, 0.9, 1.0), 50.0, 0.25)
			VfxPool.ring_wave(enemy.global_position, Color(0.6, 0.9, 1.0), 20.0, 0.15, 2.0)

	queue_redraw()


func _draw() -> void:
	# Ice beam trail with prismatic refraction
	for i in range(_trail_positions.size() - 1):
		var t := 1.0 - float(i) / float(_trail_positions.size())
		var from := _trail_positions[i] - global_position
		var to := _trail_positions[i + 1] - global_position
		# Outer frost field
		draw_line(from, to, Color(0.4, 0.7, 1.0, t * 0.06), 14.0 * t)
		# Prismatic color shift
		var hue_shift := sin(_time * 8.0 + float(i) * 0.5)
		var prism_col := Color(0.5 + hue_shift * 0.15, 0.8, 1.0 - hue_shift * 0.1)
		draw_line(from, to, Color(prism_col, t * 0.2), 8.0 * t)
		# Mid ice beam
		draw_line(from, to, Color(0.6, 0.9, 1.0, t * 0.45), 4.0 * t)
		# Core white beam
		draw_line(from, to, Color(1.0, 1.0, 1.0, t * 0.6), 2.0 * t)
		# Crystal shards along trail
		if i % 2 == 0:
			var mid := (from + to) * 0.5
			_draw_crystal(mid, 4.0 * t, Color(0.7, 0.95, 1.0, t * 0.6))
			# Snowflake particle orbiting beam
			var perp := (to - from).normalized().orthogonal()
			var orbit := perp * sin(_time * 10.0 + float(i) * 1.2) * 8.0 * t
			_draw_snowflake(mid + orbit, 2.5 * t, Color(0.8, 0.95, 1.0, t * 0.4))

	# Head crystal cluster
	var pulse := sin(_time * 12.0) * 0.2 + 0.8
	# Outer frost aura
	draw_circle(Vector2.ZERO, 12.0 * pulse, Color(0.4, 0.7, 1.0, 0.08))
	draw_circle(Vector2.ZERO, 9.0 * pulse, Color(0.5, 0.85, 1.0, 0.2))
	# Crystal core
	_draw_crystal(Vector2.ZERO, 6.0, Color(0.7, 0.95, 1.0, 0.7))
	draw_circle(Vector2.ZERO, 3.5, Color(0.8, 0.95, 1.0, 0.8))
	draw_circle(Vector2.ZERO, 2.0, Color(1, 1, 1, 0.9))

	# Orbiting ice crystals
	for i in range(3):
		var angle := _time * 6.0 + (TAU / 3.0) * i
		var orbit_r := 10.0 * pulse
		var op := Vector2(cos(angle), sin(angle)) * orbit_r
		_draw_crystal(op, 2.5, Color(0.6, 0.9, 1.0, 0.5))


func _draw_crystal(pos: Vector2, size: float, color: Color) -> void:
	var pts := PackedVector2Array([
		pos + Vector2(0, -size),
		pos + Vector2(size * 0.6, 0),
		pos + Vector2(0, size),
		pos + Vector2(-size * 0.6, 0),
	])
	draw_colored_polygon(pts, color)
	draw_polyline(pts, Color(color, color.a * 0.5), 1.0)


func _draw_snowflake(pos: Vector2, size: float, color: Color) -> void:
	for i in range(6):
		var angle := (TAU / 6.0) * i + _time * 2.0
		var end := pos + Vector2(cos(angle), sin(angle)) * size
		draw_line(pos, end, color, 0.8)
		# Branch tips
		var branch := end + Vector2(cos(angle + 0.5), sin(angle + 0.5)) * size * 0.4
		draw_line(end, branch, Color(color, color.a * 0.6), 0.5)
