extends Node2D

var _from: Vector2
var _to: Vector2
var _timer: float = 0.3
var _max_time: float = 0.3
var _segments: Array[Vector2] = []
var _branches: Array = []
var _flicker: float = 0.0
var _ball_phase: float = 0.0


func setup(from: Vector2, to: Vector2) -> void:
	_from = from
	_to = to
	_max_time = 0.3
	_timer = _max_time
	z_index = 5
	global_position = Vector2.ZERO
	_generate_segments()
	_generate_branches()
	VfxPool.hit_flash(to, Color(0.7, 0.85, 1.0), 20.0)
	VfxPool.spark_burst(to, 6, Color(0.6, 0.8, 1.0), 60.0, 0.2)


func _generate_segments() -> void:
	_segments.clear()
	_segments.append(_from)
	var steps := 12
	for i in range(1, steps):
		var t := float(i) / float(steps)
		var p := _from.lerp(_to, t)
		var jitter := 16.0 * (1.0 - absf(t - 0.5) * 2.0)
		p += Vector2(randf_range(-jitter, jitter), randf_range(-jitter, jitter))
		_segments.append(p)
	_segments.append(_to)


func _generate_branches() -> void:
	_branches.clear()
	var branch_count := randi_range(3, 6)
	for _b in range(branch_count):
		var seg_idx := randi_range(2, _segments.size() - 2)
		var origin: Vector2 = _segments[seg_idx]
		var dir := (_to - _from).normalized().rotated(randf_range(-1.5, 1.5))
		var length := randf_range(20, 55)
		var branch: Array[Vector2] = [origin]
		var steps := randi_range(3, 5)
		for i in range(steps):
			var p := origin + dir * length * float(i + 1) / float(steps)
			p += Vector2(randf_range(-8, 8), randf_range(-8, 8))
			branch.append(p)
		_branches.append(branch)


func _process(delta: float) -> void:
	_timer -= delta
	_flicker += delta * 50.0
	_ball_phase += delta * 20.0
	if _timer <= 0:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var t := _timer / _max_time
	var flicker_mod := 0.6 + sin(_flicker) * 0.3 + sin(_flicker * 1.7) * 0.1

	# Electric field glow along bolt path
	for i in range(_segments.size() - 1):
		var alpha := t * flicker_mod
		# Wide electric field
		draw_line(_segments[i], _segments[i + 1], Color(0.3, 0.4, 1.0, alpha * 0.08), 16.0)
		# Outer glow
		draw_line(_segments[i], _segments[i + 1], Color(0.4, 0.6, 1.0, alpha * 0.2), 8.0)
		# Mid beam
		draw_line(_segments[i], _segments[i + 1], Color(0.6, 0.8, 1.0, alpha * 0.5), 4.0)
		# Core white
		draw_line(_segments[i], _segments[i + 1], Color(1.0, 1.0, 1.0, alpha * 0.9), 2.0)

		# Electric arc particles along segments
		if i % 2 == 0:
			var mid := (_segments[i] + _segments[i + 1]) * 0.5
			var perp := (_segments[i + 1] - _segments[i]).normalized().orthogonal()
			var arc_offset := perp * sin(_ball_phase + float(i)) * 10.0
			draw_circle(mid + arc_offset, 2.5 * t, Color(0.7, 0.9, 1.0, alpha * 0.6))

	# Branches with sub-branches
	for branch in _branches:
		for i in range(branch.size() - 1):
			var alpha := t * flicker_mod * 0.7
			draw_line(branch[i], branch[i + 1], Color(0.5, 0.7, 1.0, alpha * 0.15), 6.0)
			draw_line(branch[i], branch[i + 1], Color(0.7, 0.85, 1.0, alpha * 0.5), 3.0)
			draw_line(branch[i], branch[i + 1], Color(1.0, 1.0, 1.0, alpha * 0.7), 1.5)

	# Ball lightning at origin
	var ball_r := 8.0 * t * (0.8 + sin(_ball_phase) * 0.2)
	draw_circle(_from, ball_r * 2.0, Color(0.4, 0.6, 1.0, t * 0.1))
	draw_circle(_from, ball_r * 1.3, Color(0.6, 0.8, 1.0, t * 0.25))
	draw_circle(_from, ball_r * 0.7, Color(0.9, 0.95, 1.0, t * 0.5))
	# Crackling arcs around origin ball
	for i in range(6):
		var arc_angle := _ball_phase + (TAU / 6.0) * i
		var arc_end := _from + Vector2(cos(arc_angle), sin(arc_angle)) * ball_r * 2.5
		draw_line(_from, arc_end, Color(0.7, 0.9, 1.0, t * 0.3 * flicker_mod), 1.0)

	# Impact glow at endpoint (large pulsating)
	var impact_r := 14.0 * t * (0.7 + sin(_ball_phase * 1.3) * 0.3)
	draw_circle(_to, impact_r * 2.5, Color(0.3, 0.5, 1.0, t * 0.1))
	draw_circle(_to, impact_r * 1.5, Color(0.6, 0.8, 1.0, t * 0.3))
	draw_circle(_to, impact_r, Color(0.8, 0.9, 1.0, t * 0.5))
	draw_circle(_to, impact_r * 0.5, Color(1, 1, 1, t * 0.7))
	# Impact ring
	draw_arc(_to, impact_r * 2.0, 0, TAU, 24, Color(0.5, 0.7, 1.0, t * 0.3), 2.0)
