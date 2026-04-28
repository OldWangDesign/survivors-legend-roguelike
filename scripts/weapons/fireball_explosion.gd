extends Node2D

var _radius: float = 60.0
var _timer: float = 0.5
var _max_time: float = 0.5
var _sparks: Array = []
var _shockwave_rings: Array = []
var _ember_rain: Array = []


func setup(radius: float) -> void:
	_radius = radius
	_max_time = 0.5
	_timer = _max_time
	z_index = 3
	for i in range(20):
		var angle := randf() * TAU
		var spd := randf_range(100, 280)
		_sparks.append({"pos": Vector2.ZERO, "vel": Vector2(cos(angle), sin(angle)) * spd, "size": randf_range(2, 6)})
	for i in range(3):
		_shockwave_rings.append({"t": -float(i) * 0.08, "max_r": _radius * (1.5 + float(i) * 0.4)})
	for i in range(15):
		var angle := randf() * TAU
		var dist := randf_range(0.2, 1.0) * _radius
		_ember_rain.append({"pos": Vector2(cos(angle), sin(angle)) * dist + Vector2(0, -randf_range(20, 60)), "vel": Vector2(randf_range(-20, 20), randf_range(30, 80)), "size": randf_range(1, 3)})
	VfxPool.ring_wave(global_position, Color(1, 0.4, 0.0), _radius * 2.0, 0.4, 4.0)
	VfxPool.screen_flash(Color(1, 0.5, 0.1, 0.2), 0.08)
	var gm := get_tree().current_scene if get_tree() else null
	if gm and gm.has_method("shake_camera"):
		gm.shake_camera(5.0, 0.2)


func _process(delta: float) -> void:
	_timer -= delta
	if _timer <= 0:
		queue_free()
		return
	for s in _sparks:
		s["pos"] += s["vel"] * delta
		s["vel"] *= 0.88
	for r in _shockwave_rings:
		r["t"] += delta * 3.0
	for e in _ember_rain:
		e["pos"] += e["vel"] * delta
		e["vel"].y += 60.0 * delta
	queue_redraw()


func _draw() -> void:
	var t := _timer / _max_time

	# Outer blast shockwave rings
	for ring in _shockwave_rings:
		var rt := clampf(ring["t"], 0.0, 1.0)
		if rt <= 0:
			continue
		var rr: float = ring["max_r"] * rt
		var ra := (1.0 - rt) * t * 0.5
		draw_arc(Vector2.ZERO, rr, 0, TAU, 48, Color(1.0, 0.5, 0.0, ra), 3.0)
		draw_arc(Vector2.ZERO, rr, 0, TAU, 48, Color(1.0, 0.3, 0.0, ra * 0.3), 8.0)

	# Mushroom cloud layers (bottom to top)
	# Base fire pool
	draw_circle(Vector2.ZERO, _radius * 1.5 * (1.3 - t * 0.3), Color(1.0, 0.2, 0.0, t * 0.12))
	# Main fireball body
	draw_circle(Vector2.ZERO, _radius * 1.2 * (1.2 - t * 0.2), Color(1.0, 0.35, 0.0, t * 0.2))
	draw_circle(Vector2.ZERO, _radius * 0.9 * (1.15 - t * 0.15), Color(1.0, 0.55, 0.1, t * 0.3))
	# Hot core
	draw_circle(Vector2.ZERO, _radius * 0.5, Color(1.0, 0.8, 0.2, t * 0.5))
	draw_circle(Vector2.ZERO, _radius * 0.25, Color(1.0, 0.95, 0.5, t * 0.7))
	# White hot center
	draw_circle(Vector2.ZERO, _radius * 0.1 * t, Color(1, 1, 1, t * 0.9))

	# Mushroom cloud rising smoke column
	var smoke_h := _radius * 0.8 * (1.0 - t)
	for i in range(4):
		var sy := -smoke_h * float(i + 1) / 4.0
		var sx := sin(float(i) * 1.5 + _timer * 5.0) * 8.0
		var sr := _radius * 0.3 * (1.0 - float(i) * 0.15)
		draw_circle(Vector2(sx, sy), sr, Color(0.3, 0.15, 0.05, t * 0.15 * (1.0 - float(i) * 0.2)))

	# Radial fire rays
	for i in range(12):
		var angle := float(i) / 12.0 * TAU + t * 3.0
		var ray_len := _radius * 1.8 * t
		var p := Vector2(cos(angle), sin(angle)) * ray_len
		draw_line(Vector2.ZERO, p, Color(1.0, 0.5, 0.0, t * 0.25), 2.5)
		draw_line(Vector2.ZERO, p, Color(1.0, 0.8, 0.3, t * 0.08), 6.0)

	# Ember sparks
	for s in _sparks:
		var alpha := t * 0.9
		var sz: float = s["size"]
		draw_circle(s["pos"], sz * t, Color(1.0, 0.6, 0.1, alpha))
		draw_circle(s["pos"], sz * 0.5 * t, Color(1.0, 0.9, 0.5, alpha * 0.6))
		draw_circle(s["pos"], sz * 0.2 * t, Color(1, 1, 0.9, alpha * 0.3))

	# Ember rain (falling particles)
	for e in _ember_rain:
		var ea := t * 0.7
		draw_circle(e["pos"], e["size"], Color(1.0, 0.5, 0.1, ea))
		draw_circle(e["pos"], e["size"] * 0.4, Color(1.0, 0.9, 0.4, ea * 0.5))

	# Ground scorch marks
	for i in range(8):
		var angle := (TAU / 8.0) * i
		var crack_len := _radius * 1.0 * (1.0 - t * 0.2)
		var end := Vector2(cos(angle), sin(angle)) * crack_len
		var mid := end * 0.5 + Vector2(sin(float(i) * 2.3) * 8.0, cos(float(i) * 1.7) * 8.0)
		draw_line(Vector2.ZERO, mid, Color(0.4, 0.15, 0.0, t * 0.4), 2.0)
		draw_line(mid, end, Color(0.3, 0.1, 0.0, t * 0.25), 1.5)
