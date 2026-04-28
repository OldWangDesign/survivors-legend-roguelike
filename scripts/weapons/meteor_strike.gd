extends Node2D

var _target: Vector2
var _damage: int = 30
var _radius: float = 80.0
var _fall_offset: Vector2
var _fall_timer: float = 0.7
var _exploded: bool = false
var _fx_timer: float = 0.5
var _debris: Array = []
var _shake_done: bool = false
var _crater_cracks: Array = []

const FALL_HEIGHT := 280.0


func setup(target: Vector2, dmg: int, radius: float) -> void:
	_target = target
	_damage = dmg
	_radius = radius
	_fall_offset = Vector2(0, -FALL_HEIGHT)
	global_position = target
	z_index = 5
	_fx_timer = 0.5
	for i in range(12):
		var angle := (TAU / 12.0) * i + randf_range(-0.2, 0.2)
		var len_mult := randf_range(0.6, 1.2)
		_crater_cracks.append({"angle": angle, "len": len_mult, "jitter": randf_range(-8, 8)})


func _process(delta: float) -> void:
	if not _exploded:
		_fall_timer -= delta
		var t := 1.0 - clampf(_fall_timer / 0.7, 0.0, 1.0)
		_fall_offset = Vector2(0, -FALL_HEIGHT * (1.0 - t * t * t))
		if _fall_timer <= 0:
			_explode()
	else:
		_fx_timer -= delta
		for d in _debris:
			d["pos"] += d["vel"] * delta
			d["vel"].y += 180.0 * delta
			d["vel"] *= 0.96
		if _fx_timer <= 0:
			queue_free()
			return
	queue_redraw()


func _explode() -> void:
	_exploded = true
	var r_sq := _radius * _radius
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if _target.distance_squared_to(enemy.global_position) < r_sq:
			enemy.take_damage(_damage)
	VfxPool.screen_flash(Color(1, 0.4, 0.1, 0.25), 0.1)
	VfxPool.ring_wave(global_position, Color(1, 0.4, 0.1), _radius * 2.5, 0.5, 5.0)
	VfxPool.spark_burst(global_position, 20, Color(1, 0.6, 0.2), 200.0, 0.5)
	var gm := get_tree().current_scene if get_tree() else null
	if gm and gm.has_method("shake_camera"):
		gm.shake_camera(8.0, 0.3)
	for i in range(16):
		var angle := randf() * TAU
		var spd := randf_range(80, 250)
		_debris.append({
			"pos": Vector2.ZERO,
			"vel": Vector2(cos(angle), sin(angle)) * spd + Vector2(0, -randf_range(60, 150)),
			"size": randf_range(2, 7),
			"type": randi() % 3,
		})
	_shake_done = true


func _draw() -> void:
	if not _exploded:
		# Ground warning - animated crosshair target
		var warn_t := 1.0 - clampf(_fall_timer / 0.7, 0.0, 1.0)
		var warn_alpha := warn_t * 0.6
		var warn_pulse := sin(warn_t * PI * 6.0) * 0.15 + 0.85

		# Danger zone fill
		draw_circle(Vector2.ZERO, _radius * 0.7 * warn_pulse, Color(1.0, 0.2, 0.0, warn_alpha * 0.1))
		# Concentric warning rings
		for r in range(3):
			var rr := _radius * (0.3 + float(r) * 0.2) * warn_pulse
			draw_arc(Vector2.ZERO, rr, 0, TAU, 24, Color(1.0, 0.3, 0.1, warn_alpha * (0.5 - float(r) * 0.12)), 1.5)
		# Rotating crosshair
		var ch := _radius * 0.5 * warn_alpha
		var ch_angle := warn_t * 2.0
		for i in range(4):
			var ca := ch_angle + (TAU / 4.0) * i
			var c_start := Vector2(cos(ca), sin(ca)) * ch * 0.3
			var c_end := Vector2(cos(ca), sin(ca)) * ch
			draw_line(c_start, c_end, Color(1, 0.3, 0.1, warn_alpha * 0.5), 1.5)
		# Impact X mark
		draw_line(Vector2(-6, -6), Vector2(6, 6), Color(1, 0.2, 0.0, warn_alpha * 0.4), 2.0)
		draw_line(Vector2(6, -6), Vector2(-6, 6), Color(1, 0.2, 0.0, warn_alpha * 0.4), 2.0)

		# Meteor body with dramatic fire trail
		var mp := _fall_offset
		# Lengthy fire trail
		for i in range(10):
			var trail_y := mp.y + float(i + 1) * 10.0
			var trail_s := 10.0 - float(i) * 0.8
			var trail_a := 0.6 - float(i) * 0.05
			var trail_x := mp.x + sin(float(i) * 1.5) * 3.0
			draw_circle(Vector2(trail_x, trail_y), trail_s, Color(1.0, 0.4 + float(i) * 0.04, 0.05, trail_a))
			if i < 5:
				draw_circle(Vector2(trail_x, trail_y), trail_s * 0.5, Color(1.0, 0.8, 0.3, trail_a * 0.4))
		# Meteor glow
		draw_circle(mp, 18.0, Color(1.0, 0.3, 0.0, 0.2))
		# Meteor layers
		draw_circle(mp, 14.0, Color(0.8, 0.2, 0.02))
		draw_circle(mp, 11.0, Color(1.0, 0.4, 0.05))
		draw_circle(mp, 7.0, Color(1.0, 0.7, 0.2))
		draw_circle(mp, 4.0, Color(1.0, 0.9, 0.5))
		draw_circle(mp, 2.0, Color(1, 1, 0.9))
	else:
		var t := _fx_timer / 0.5

		# Multi-ring blast shockwave
		for r in range(3):
			var ring_t := clampf(1.0 - t + float(r) * 0.1, 0.0, 1.0)
			var ring_r := _radius * (1.5 + ring_t * 1.5)
			var ring_a := (1.0 - ring_t) * t * 0.4
			draw_arc(Vector2.ZERO, ring_r, 0, TAU, 48, Color(1.0, 0.4, 0.0, ring_a), 3.0)
			draw_arc(Vector2.ZERO, ring_r, 0, TAU, 48, Color(1.0, 0.2, 0.0, ring_a * 0.3), 8.0)

		# Massive explosion layers
		draw_circle(Vector2.ZERO, _radius * 1.6 * (1.3 - t * 0.3), Color(1.0, 0.2, 0.0, t * 0.1))
		draw_circle(Vector2.ZERO, _radius * 1.2 * (1.2 - t * 0.2), Color(1.0, 0.35, 0.05, t * 0.18))
		draw_circle(Vector2.ZERO, _radius * 0.8, Color(1.0, 0.55, 0.1, t * 0.3))
		draw_circle(Vector2.ZERO, _radius * 0.45, Color(1.0, 0.8, 0.3, t * 0.45))
		draw_circle(Vector2.ZERO, _radius * 0.2, Color(1.0, 0.95, 0.6, t * 0.6))
		draw_circle(Vector2.ZERO, _radius * 0.08, Color(1, 1, 1, t * 0.8))

		# Crater crack lines with branching
		for crack in _crater_cracks:
			var ca: float = crack["angle"]
			var cl: float = _radius * 1.0 * crack["len"] * (1.0 - t * 0.2)
			var mid := Vector2(cos(ca), sin(ca)) * cl * 0.5
			mid += Vector2(crack["jitter"], crack["jitter"] * 0.7).rotated(ca)
			var end := Vector2(cos(ca), sin(ca)) * cl
			draw_line(Vector2.ZERO, mid, Color(1.0, 0.4, 0.05, t * 0.5), 2.5)
			draw_line(mid, end, Color(0.5, 0.2, 0.05, t * 0.3), 1.5)
			# Hot glow along crack
			draw_line(Vector2.ZERO, mid, Color(1.0, 0.7, 0.2, t * 0.15), 5.0)

		# Debris rocks flying
		for d in _debris:
			var dt: int = d["type"]
			var ds: float = d["size"]
			var da := t * 0.9
			if dt == 0:
				draw_circle(d["pos"], ds * t, Color(0.5, 0.25, 0.1, da))
				draw_circle(d["pos"], ds * 0.5 * t, Color(1.0, 0.6, 0.2, da * 0.5))
			elif dt == 1:
				var dp: Vector2 = d["pos"]
				draw_rect(Rect2(dp.x - ds * 0.5, dp.y - ds * 0.5, ds, ds), Color(0.6, 0.3, 0.15, da))
			else:
				draw_circle(d["pos"], ds * 0.7 * t, Color(1.0, 0.5, 0.1, da * 0.7))
				draw_circle(d["pos"], ds * 0.3 * t, Color(1.0, 0.9, 0.4, da * 0.3))

		# Radial fire rays
		for i in range(16):
			var angle := float(i) / 16.0 * TAU + t * 2.0
			var ray_len := _radius * 2.0 * t
			var p := Vector2(cos(angle), sin(angle)) * ray_len
			draw_line(Vector2.ZERO, p, Color(1.0, 0.5, 0.0, t * 0.15), 2.0)
