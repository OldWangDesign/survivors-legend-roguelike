extends Node2D

var area_radius: float = 50.0
var damage: int = 8
var duration: float = 3.0
var _tick_timer: float = 0.0
var _active: bool = true
var _ripple_time: float = 0.0
var _pillars: Array = []


func setup(radius: float, dmg: int, dur: float) -> void:
	area_radius = radius
	damage = dmg
	duration = dur
	z_index = -1
	for i in range(4):
		_pillars.append({"angle": (TAU / 4.0) * i + randf_range(-0.3, 0.3), "r": randf_range(0.4, 0.7), "phase": randf() * TAU})


func _process(delta: float) -> void:
	if not _active:
		return

	duration -= delta
	_tick_timer -= delta
	_ripple_time += delta

	if _tick_timer <= 0:
		_tick_timer = 0.33
		_deal_damage()

	if duration <= 0:
		_active = false
		var tween := create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.3)
		tween.tween_callback(queue_free)

	queue_redraw()


func _deal_damage() -> void:
	for enemy in SpatialGrid.get_in_range(global_position, area_radius):
		enemy.take_damage(damage)


func _draw() -> void:
	var alpha := clampf(duration / 0.5, 0.0, 1.0) * 0.6

	# Base holy water pool with luminous layers
	draw_circle(Vector2.ZERO, area_radius * 1.05, Color(0.1, 0.25, 0.8, alpha * 0.15))
	draw_circle(Vector2.ZERO, area_radius, Color(0.15, 0.3, 0.9, alpha * 0.3))
	draw_circle(Vector2.ZERO, area_radius * 0.7, Color(0.2, 0.4, 1.0, alpha * 0.2))
	draw_circle(Vector2.ZERO, area_radius * 0.4, Color(0.4, 0.6, 1.0, alpha * 0.12))

	# Purification magic circles
	for r_idx in range(2):
		var circle_r := area_radius * (0.5 + float(r_idx) * 0.35)
		var rot := _ripple_time * (0.5 if r_idx == 0 else -0.3)
		var seg_count := 8 + r_idx * 4
		for i in range(seg_count):
			var a1 := rot + (TAU / seg_count) * i
			var a2 := a1 + (TAU / seg_count) * 0.6
			draw_arc(Vector2.ZERO, circle_r, a1, a2, 6, Color(0.5, 0.7, 1.0, alpha * 0.4), 1.5)
			# Rune dot at segment start
			var rp := Vector2(cos(a1), sin(a1)) * circle_r
			draw_circle(rp, 2.0, Color(0.6, 0.8, 1.0, alpha * 0.3))

	# Expanding ripple rings
	for r in range(4):
		var ripple_t := fmod(_ripple_time * 1.2 + float(r) * 0.25, 1.0)
		var ripple_r := area_radius * ripple_t
		var ripple_a := (1.0 - ripple_t) * alpha * 0.6
		draw_arc(Vector2.ZERO, ripple_r, 0, TAU, 32, Color(0.5, 0.75, 1.0, ripple_a), 2.0)

	# Outer glowing ring
	draw_arc(Vector2.ZERO, area_radius, 0, TAU, 48, Color(0.4, 0.65, 1.0, alpha * 0.7), 3.0)
	draw_arc(Vector2.ZERO, area_radius, 0, TAU, 48, Color(0.6, 0.8, 1.0, alpha * 0.15), 8.0)

	# Light pillars rising from pool
	for p in _pillars:
		var p_angle: float = p["angle"]
		var p_r: float = p["r"]
		var p_phase: float = p["phase"]
		var px: float = cos(p_angle) * area_radius * p_r
		var pillar_base: Vector2 = Vector2(px, sin(p_angle) * area_radius * p_r)
		var pillar_h: float = 35.0 + 15.0 * sin(_ripple_time * 2.0 + p_phase)
		var pa: float = alpha * (0.3 + 0.2 * sin(_ripple_time * 3.0 + p_phase))
		# Wide glow
		draw_line(pillar_base, pillar_base + Vector2(0, -pillar_h), Color(0.4, 0.6, 1.0, pa * 0.3), 10.0)
		# Core beam
		draw_line(pillar_base, pillar_base + Vector2(0, -pillar_h), Color(0.6, 0.8, 1.0, pa), 3.0)
		# Bright core
		draw_line(pillar_base, pillar_base + Vector2(0, -pillar_h * 0.7), Color(1, 1, 1, pa * 0.4), 1.5)
		# Top sparkle
		draw_circle(pillar_base + Vector2(0, -pillar_h), 3.0, Color(0.7, 0.9, 1.0, pa * 0.6))

	# Steam/bubble particles rising
	for i in range(10):
		var angle := (_ripple_time * 0.8 + float(i) * 0.7) * 2.0
		var r := area_radius * (0.3 + 0.4 * sin(angle * 0.3 + float(i)))
		var bpos := Vector2(cos(angle), sin(angle)) * r
		var bubble_a := alpha * (0.4 + 0.3 * sin(_ripple_time * 3.0 + float(i)))
		draw_circle(bpos, 3.5, Color(0.5, 0.7, 1.0, bubble_a))
		draw_circle(bpos, 2.0, Color(0.8, 0.9, 1.0, bubble_a * 0.5))
		draw_circle(bpos, 1.0, Color(1, 1, 1, bubble_a * 0.3))

	# Rising steam wisps
	for i in range(5):
		var x := (float(i) / 4.0 - 0.5) * area_radius * 1.2
		var base_y := sin(_ripple_time * 2.0 + float(i)) * area_radius * 0.25
		var top_y := base_y - 22.0 - sin(_ripple_time * 3.0 + float(i)) * 8.0
		var wave_x := x + sin(_ripple_time * 1.5 + float(i)) * 6.0
		draw_line(Vector2(x, base_y), Vector2(wave_x, top_y), Color(0.6, 0.8, 1.0, alpha * 0.2), 2.0)
		draw_line(Vector2(x, base_y), Vector2(wave_x, top_y), Color(0.8, 0.9, 1.0, alpha * 0.06), 5.0)

	# Center holy cross symbol
	var cross_a := alpha * 0.3
	var cs := 8.0
	draw_line(Vector2(0, -cs), Vector2(0, cs), Color(1.0, 0.95, 0.8, cross_a), 2.0)
	draw_line(Vector2(-cs * 0.7, -cs * 0.3), Vector2(cs * 0.7, -cs * 0.3), Color(1.0, 0.95, 0.8, cross_a), 2.0)
