extends Node2D

var damage: int = 3
var radius: float = 40.0
var _duration: float = 5.0
var _tick_timer: float = 0.0
var _time: float = 0.0
var _bubbles: Array = []
var _drips: Array = []

const TICK_RATE := 0.5


func setup(dmg: int, rad: float, dur: float) -> void:
	damage = dmg
	radius = rad
	_duration = dur
	z_index = 1
	modulate.a = 0.8
	for i in range(14):
		_bubbles.append({
			"offset": Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * randf_range(0.2, 0.85),
			"speed": randf_range(0.5, 1.5),
			"size": randf_range(3, 10),
			"phase": randf() * TAU,
		})
	for i in range(6):
		_drips.append({"angle": randf() * TAU, "r": randf_range(0.3, 0.8), "t": randf(), "speed": randf_range(0.3, 0.8)})


func _process(delta: float) -> void:
	_duration -= delta
	_time += delta
	if _duration <= 0:
		queue_free()
		return
	modulate.a = clampf(_duration / 1.0, 0.1, 0.8)

	_tick_timer += delta
	if _tick_timer >= TICK_RATE:
		_tick_timer -= TICK_RATE
		_tick_damage()

	for d in _drips:
		d["t"] += delta * d["speed"]
		if d["t"] > 1.0:
			d["t"] = 0.0
			d["angle"] = randf() * TAU
			d["r"] = randf_range(0.3, 0.8)

	queue_redraw()


func _tick_damage() -> void:
	var r_sq := radius * radius
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if global_position.distance_squared_to(enemy.global_position) < r_sq:
			enemy.take_damage(damage)
			enemy.apply_slow(0.7, 0.6)


func _draw() -> void:
	# Multi-layer toxic fog
	draw_circle(Vector2.ZERO, radius * 1.05, Color(0.1, 0.35, 0.05, 0.12))
	draw_circle(Vector2.ZERO, radius * 0.85, Color(0.12, 0.4, 0.08, 0.18))
	draw_circle(Vector2.ZERO, radius * 0.6, Color(0.15, 0.5, 0.1, 0.15))
	draw_circle(Vector2.ZERO, radius * 0.35, Color(0.2, 0.55, 0.12, 0.12))

	# Rolling toxic bubbles with glow
	for b in _bubbles:
		var angle: float = _time * b["speed"] + b["phase"]
		var r: float = radius * b["offset"].length()
		var bpos: Vector2 = b["offset"].normalized() * r
		bpos = bpos.rotated(sin(angle) * 0.4)
		bpos.y += sin(_time * b["speed"] * 2.0 + b["phase"]) * 6.0
		var s: float = b["size"] * (0.6 + 0.4 * sin(angle * 2.0))
		var ba := 0.3 + 0.2 * sin(angle)
		# Bubble glow
		draw_circle(bpos, s * 1.5, Color(0.15, 0.5, 0.1, ba * 0.2))
		# Bubble body
		draw_circle(bpos, s, Color(0.2, 0.65, 0.15, ba))
		draw_circle(bpos, s * 0.5, Color(0.35, 0.8, 0.25, ba * 0.5))
		# Bubble highlight
		draw_circle(bpos + Vector2(-s * 0.2, -s * 0.2), s * 0.25, Color(0.5, 0.9, 0.4, ba * 0.3))

	# Skull face shapes floating in cloud
	for i in range(3):
		var skull_angle := _time * 0.4 + float(i) * TAU / 3.0
		var skull_r := radius * (0.3 + 0.15 * sin(_time + float(i)))
		var sp := Vector2(cos(skull_angle), sin(skull_angle)) * skull_r
		var sa := 0.15 + 0.1 * sin(_time * 1.5 + float(i))
		# Skull outline
		draw_circle(sp, 8.0, Color(0.15, 0.45, 0.1, sa))
		# Eyes
		draw_circle(sp + Vector2(-2.5, -2), 1.5, Color(0.05, 0.15, 0.0, sa * 1.5))
		draw_circle(sp + Vector2(2.5, -2), 1.5, Color(0.05, 0.15, 0.0, sa * 1.5))
		# Nose
		draw_circle(sp + Vector2(0, 0.5), 0.8, Color(0.05, 0.15, 0.0, sa))
		# Mouth
		for t_idx in range(4):
			var mx := sp.x + float(t_idx) * 2.0 - 3.0
			draw_line(Vector2(mx, sp.y + 3.0), Vector2(mx, sp.y + 5.0), Color(0.05, 0.15, 0.0, sa * 0.8), 0.8)

	# Acid drip particles falling
	for d in _drips:
		var d_angle: float = d["angle"]
		var d_r: float = d["r"]
		var d_t: float = d["t"]
		var dp: Vector2 = Vector2(cos(d_angle), sin(d_angle)) * radius * d_r
		var fall: float = d_t * 15.0
		dp.y += fall
		var da: float = (1.0 - d_t) * 0.5
		draw_circle(dp, 2.0, Color(0.3, 0.8, 0.1, da))
		# Drip trail
		draw_line(dp - Vector2(0, fall * 0.3), dp, Color(0.25, 0.7, 0.1, da * 0.4), 1.0)

	# Outer toxic ring with pulse
	var ring_pulse := sin(_time * 3.0) * 0.05 + 0.95
	draw_arc(Vector2.ZERO, radius * ring_pulse, 0, TAU, 32, Color(0.15, 0.55, 0.1, 0.4), 3.0)
	draw_arc(Vector2.ZERO, radius * ring_pulse, 0, TAU, 32, Color(0.2, 0.6, 0.15, 0.1), 8.0)

	# Toxic rising particles
	for i in range(8):
		var angle := _time * 0.8 + float(i) * TAU / 8.0
		var x := cos(angle) * radius * 0.5
		var y_base := sin(angle) * radius * 0.3
		var rise := fmod(_time * 0.6 + float(i) * 0.15, 1.0)
		var y := y_base - rise * 18.0
		var pa := (1.0 - rise) * 0.5
		draw_circle(Vector2(x, y), 2.0, Color(0.3, 0.85, 0.2, pa))
		draw_circle(Vector2(x, y), 1.0, Color(0.5, 1.0, 0.3, pa * 0.5))
