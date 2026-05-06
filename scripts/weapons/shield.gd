extends WeaponBase

var _active: bool = false
var _shield_timer: float = 0.0
var _hex_angle: float = 0.0
var _hit_flash_timer: float = 0.0
var _pulse_phase: float = 0.0
var _impact_rings: Array = []


func _ready() -> void:
	weapon_type = GameData.WeaponType.SHIELD


func attack() -> void:
	_active = true
	var data: Dictionary = GameData.WEAPON_DATA[weapon_type]
	_shield_timer = data.get("base_duration", 1.5) + weapon_level * 0.3
	_impact_rings.clear()
	play_weapon_sound("weapon_shield")
	VfxPool.ring_wave(GameData.player_ref.global_position, Color(0.3, 0.6, 1.0), 80.0, 0.3, 3.0)
	start_cooldown()


func _process(delta: float) -> void:
	if not _active:
		return
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return

	_shield_timer -= delta
	_hex_angle += delta * 1.5
	_pulse_phase += delta * 4.0
	if _hit_flash_timer > 0:
		_hit_flash_timer -= delta

	# Update impact rings
	for r in _impact_rings:
		r["t"] += delta * 4.0
	_impact_rings = _impact_rings.filter(func(r: Dictionary) -> bool: return r["t"] < 1.0)

	if _shield_timer <= 0:
		_active = false
		return

	var radius := GameData.get_weapon_area(weapon_type, weapon_level)
	var dmg := get_damage()
	var knockback_strength := 80.0

	for enemy in SpatialGrid.get_in_range(player.global_position, radius):
		var diff: Vector2 = enemy.global_position - player.global_position
		enemy.take_damage(dmg * delta * 2.0)
		enemy.apply_knockback(diff.normalized() * knockback_strength * delta)
		_hit_flash_timer = 0.12
		if _impact_rings.size() < 5:
			_impact_rings.append({"pos": diff.normalized() * radius, "t": 0.0})

	queue_redraw()


func _draw() -> void:
	if not _active:
		return
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return
	var radius := GameData.get_weapon_area(weapon_type, weapon_level)
	var pos := player.global_position - global_position
	var alpha := clampf(_shield_timer / 0.5, 0.2, 0.8)
	var hit_boost := 0.4 if _hit_flash_timer > 0 else 0.0
	var pulse := sin(_pulse_phase) * 0.1 + 0.9

	# Background energy field
	draw_circle(pos, radius * 1.1, Color(0.15, 0.3, 0.8, alpha * 0.04 + hit_boost * 0.06))

	# Hexagonal shield segments with inner patterns
	var hex_count := 6
	for i in range(hex_count):
		var a1 := _hex_angle + (TAU / hex_count) * i
		var a2 := _hex_angle + (TAU / hex_count) * (i + 1)
		var p1 := pos + Vector2(cos(a1), sin(a1)) * radius
		var p2 := pos + Vector2(cos(a2), sin(a2)) * radius

		# Shield face fill
		var face_pts := PackedVector2Array([pos, p1, p2])
		var face_alpha := (alpha * 0.06) + hit_boost * 0.08
		draw_colored_polygon(face_pts, Color(0.2, 0.5, 1.0, face_alpha))

		# Edge with glow
		draw_line(p1, p2, Color(0.3, 0.6, 1.0, alpha * 0.2 + hit_boost), 7.0)
		draw_line(p1, p2, Color(0.5, 0.8, 1.0, alpha * 0.7 + hit_boost), 2.5)
		draw_line(p1, p2, Color(1, 1, 1, alpha * 0.3 + hit_boost * 0.5), 1.0)

		# Inner grid pattern (energy matrix)
		var mid := (p1 + p2) * 0.5
		var center_to_mid := (mid - pos) * 0.5
		var grid_p := pos + center_to_mid
		draw_line(grid_p, mid, Color(0.4, 0.7, 1.0, alpha * 0.15), 1.0)
		draw_line(pos, grid_p, Color(0.4, 0.7, 1.0, alpha * 0.08), 1.0)

		# Vertex glow nodes
		draw_circle(p1, 3.5, Color(0.5, 0.8, 1.0, alpha * 0.4 + hit_boost * 0.3))
		draw_circle(p1, 1.5, Color(1, 1, 1, alpha * 0.3))

	# Outer ring layers
	draw_arc(pos, radius * 1.05, 0, TAU, 48, Color(0.3, 0.6, 1.0, alpha * 0.15), 5.0)
	draw_arc(pos, radius, 0, TAU, 48, Color(0.5, 0.8, 1.0, alpha * 0.8 + hit_boost), 2.5)
	draw_arc(pos, radius * 0.9, 0, TAU, 48, Color(0.6, 0.85, 1.0, alpha * 0.2), 1.5)

	# Rotating energy flow lines
	for i in range(6):
		var angle := _hex_angle * 2.5 + (TAU / 6.0) * i
		var inner := pos + Vector2(cos(angle), sin(angle)) * radius * 0.2
		var outer := pos + Vector2(cos(angle), sin(angle)) * radius * 0.95
		draw_line(inner, outer, Color(0.5, 0.8, 1.0, alpha * 0.12), 1.5)
		# Energy dot traveling along line
		var dot_t := fmod(_pulse_phase * 0.5 + float(i) * 0.17, 1.0)
		var dot_pos := inner.lerp(outer, dot_t)
		draw_circle(dot_pos, 2.0, Color(0.7, 0.9, 1.0, alpha * 0.5))

	# Pulsating center core
	draw_circle(pos, 8.0 * pulse, Color(0.3, 0.6, 1.0, alpha * 0.08))
	draw_circle(pos, 4.0, Color(0.5, 0.8, 1.0, alpha * 0.12))

	# Impact absorption rings
	for ring in _impact_rings:
		var rt: float = ring["t"]
		var rp: Vector2 = pos + ring["pos"]
		var rr := 15.0 * rt
		var ra := (1.0 - rt) * alpha
		draw_arc(rp, rr, 0, TAU, 16, Color(0.7, 0.9, 1.0, ra * 0.6), 2.0)
		draw_circle(rp, (1.0 - rt) * 5.0, Color(1, 1, 1, ra * 0.4))

	# Full shield hit flash
	if _hit_flash_timer > 0:
		var flash_a := _hit_flash_timer / 0.12
		draw_circle(pos, radius * 0.6, Color(1, 1, 1, flash_a * 0.1))
