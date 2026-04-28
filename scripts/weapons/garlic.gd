extends WeaponBase

var _pulse_alpha: float = 0.0
var _pulse_rings: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0]
var _spark_angle: float = 0.0
var _rune_angle: float = 0.0
var _skull_particles: Array = []

func _ready() -> void:
	weapon_type = GameData.WeaponType.GARLIC
	z_index = 2


func attack() -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		start_cooldown()
		return

	var area: float = GameData.get_weapon_area(weapon_type, weapon_level) * player.area_mult
	var dmg := get_damage()

	var enemies := get_enemies_in_range(player.global_position, area)
	for enemy in enemies:
		enemy.take_damage(dmg)

	_pulse_alpha = 1.2
	_pulse_rings = [0.0, -0.12, -0.24, -0.36, -0.48]
	_skull_particles.clear()
	for i in range(6 + weapon_level):
		var angle := randf() * TAU
		_skull_particles.append({"angle": angle, "r": area * 0.4, "speed": randf_range(0.8, 1.5), "t": 0.0})
	play_weapon_sound()
	VfxPool.ring_wave(player.global_position, Color(0.4, 1.0, 0.2), area * 1.5, 0.35, 3.0)
	VfxPool.screen_flash(Color(0.3, 0.8, 0.1, 0.08), 0.05)
	start_cooldown()


func _process(delta: float) -> void:
	if _pulse_alpha > 0:
		_pulse_alpha -= delta * 2.0
		for i in range(_pulse_rings.size()):
			_pulse_rings[i] += delta * 2.5
		for p in _skull_particles:
			p["t"] += delta * p["speed"]
			p["r"] += delta * 40.0
	_spark_angle += delta * 3.0
	_rune_angle -= delta * 1.5
	queue_redraw()


func _draw() -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return
	if _pulse_alpha <= 0:
		return

	var area: float = GameData.get_weapon_area(weapon_type, weapon_level)
	if is_instance_valid(player):
		area *= player.area_mult

	var pos := player.global_position - global_position
	var base_alpha := clampf(_pulse_alpha, 0.0, 1.0)

	# Ground toxic fill with gradient
	draw_circle(pos, area * 0.5 * base_alpha, Color(0.2, 0.6, 0.1, base_alpha * 0.08))
	draw_circle(pos, area * 0.3 * base_alpha, Color(0.3, 0.8, 0.2, base_alpha * 0.12))

	# Multi-ring shockwave pulses (5 rings)
	for i in range(_pulse_rings.size()):
		var ring_t := clampf(_pulse_rings[i], 0.0, 1.0)
		if ring_t <= 0:
			continue
		var r := area * (0.3 + ring_t * 0.7)
		var a := base_alpha * (1.0 - ring_t) * 0.7
		draw_arc(pos, r, 0, TAU, 48, Color(0.3, 1.0, 0.2, a), 3.0)
		draw_arc(pos, r, 0, TAU, 48, Color(0.4, 1.0, 0.3, a * 0.2), 8.0)
		# Dashed inner ring
		for seg in range(12):
			var sa := (TAU / 12.0) * seg
			var ea := sa + (TAU / 24.0)
			draw_arc(pos, r * 0.92, sa, ea, 4, Color(0.5, 1.0, 0.4, a * 0.4), 1.5)

	# Rotating poison rune symbols
	var rune_count := 8
	for i in range(rune_count):
		var angle := _rune_angle + (TAU / rune_count) * i
		var r := area * 0.65
		var rp := pos + Vector2(cos(angle), sin(angle)) * r
		var ra := base_alpha * 0.5
		# Simple cross/rune shape
		var rs := 5.0
		draw_line(rp + Vector2(-rs, -rs), rp + Vector2(rs, rs), Color(0.4, 0.9, 0.2, ra), 1.5)
		draw_line(rp + Vector2(rs, -rs), rp + Vector2(-rs, rs), Color(0.4, 0.9, 0.2, ra), 1.5)
		draw_circle(rp, 2.0, Color(0.5, 1.0, 0.3, ra))

	# Rotating spark particles with trails
	var spark_count := 8 + weapon_level * 2
	for i in range(spark_count):
		var angle := _spark_angle + (TAU / spark_count) * i
		var wobble := sin(angle * 3.0 + _spark_angle * 2.0) * 0.25
		var r := area * (0.5 + wobble)
		var sp := pos + Vector2(cos(angle), sin(angle)) * r
		var sa := base_alpha * 0.7
		draw_circle(sp, 3.0, Color(0.3, 0.9, 0.1, sa * 0.3))
		draw_circle(sp, 2.0, Color(0.5, 1.0, 0.3, sa))
		draw_circle(sp, 1.0, Color(1, 1, 1, sa * 0.5))
		# Mini trail
		var trail_end := pos + Vector2(cos(angle - 0.3), sin(angle - 0.3)) * r
		draw_line(sp, trail_end, Color(0.3, 0.8, 0.1, sa * 0.3), 1.0)

	# Skull-like particles expanding outward
	for p in _skull_particles:
		if p["t"] > 1.0:
			continue
		var p_angle: float = p["angle"]
		var p_r: float = p["r"]
		var p_t: float = p["t"]
		var sp: Vector2 = pos + Vector2(cos(p_angle), sin(p_angle)) * p_r
		var sa: float = (1.0 - p_t) * base_alpha * 0.6
		# Skull shape (simplified: circle + two eye dots)
		draw_circle(sp, 4.0, Color(0.4, 0.8, 0.2, sa))
		draw_circle(sp + Vector2(-1.5, -1), 1.0, Color(0.1, 0.2, 0.0, sa))
		draw_circle(sp + Vector2(1.5, -1), 1.0, Color(0.1, 0.2, 0.0, sa))
		draw_line(sp + Vector2(-1.5, 1.5), sp + Vector2(1.5, 1.5), Color(0.1, 0.2, 0.0, sa), 0.8)
