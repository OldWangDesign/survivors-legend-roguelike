extends WeaponBase

var _attack_timer: float = 0.0
var _attacking: bool = false
var _attack_side: int = 1
var _hit_positions: Array[Vector2] = []
var _crack_particles: Array = []

const ATTACK_DURATION := 0.35
const WHIP_LENGTH := 100.0


func _ready() -> void:
	weapon_type = GameData.WeaponType.WHIP
	z_index = 2


func attack() -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		start_cooldown()
		return

	_attacking = true
	_attack_timer = ATTACK_DURATION
	_hit_positions.clear()
	_crack_particles.clear()
	play_weapon_sound("weapon_whip")

	var direction: Vector2 = player.facing * float(_attack_side)
	var area: float = GameData.get_weapon_area(weapon_type, weapon_level)
	var hit_range: float = WHIP_LENGTH * area
	var dmg: int = get_damage()

	for enemy in get_tree().get_nodes_in_group("enemies"):
		var to_enemy: Vector2 = enemy.global_position - player.global_position
		var dist: float = to_enemy.length()
		if dist < hit_range and dist > 0.01:
			if to_enemy.normalized().dot(direction) > -0.2:
				enemy.take_damage(dmg)
				spawn_damage_number(enemy.global_position, dmg)
				_hit_positions.append(enemy.global_position - player.global_position)

	var tip := player.global_position + direction * hit_range * 0.8
	VfxPool.spark_burst(tip, 10, Color(1, 0.7, 0.1), 100.0, 0.3)
	VfxPool.ring_wave(tip, Color(1, 0.5, 0.1), 35.0, 0.2, 2.0)
	for i in range(8):
		var angle := randf() * TAU
		var spd := randf_range(60, 150)
		_crack_particles.append({"pos": direction * hit_range * 0.8, "vel": Vector2(cos(angle), sin(angle)) * spd, "t": 0.4, "s": randf_range(2, 5)})

	_attack_side *= -1
	start_cooldown()


func _process(delta: float) -> void:
	if _attacking:
		_attack_timer -= delta
		for p in _crack_particles:
			p["t"] -= delta
			p["pos"] += p["vel"] * delta
			p["vel"] *= 0.92
		_crack_particles = _crack_particles.filter(func(p: Dictionary) -> bool: return p["t"] > 0)
		if _attack_timer <= 0:
			_attacking = false
		queue_redraw()


func _draw() -> void:
	if not _attacking:
		return
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return

	var t := 1.0 - (_attack_timer / ATTACK_DURATION)
	var direction: Vector2 = player.facing * float(-_attack_side)
	var area: float = GameData.get_weapon_area(weapon_type, weapon_level)
	var length := WHIP_LENGTH * area * 0.5
	var alpha := 1.0 - t * t

	var base_angle := direction.angle()
	var sweep := lerpf(-PI * 0.4, PI * 0.4, t)

	# Afterimage whip traces (3 layers fading)
	for ghost in range(3):
		var ghost_t := clampf(t - ghost * 0.08, 0.0, 1.0)
		var ghost_sweep := lerpf(-PI * 0.4, PI * 0.4, ghost_t)
		var ghost_alpha := alpha * (0.3 - ghost * 0.08)
		for i in range(20):
			var ratio := float(i) / 19.0
			var angle := base_angle + lerpf(-PI * 0.4, ghost_sweep, ratio)
			var r := length * (0.25 + ratio * 0.75)
			var pos := Vector2(cos(angle), sin(angle)) * r
			var size := (4.0 + ratio * 6.0) * (1.0 - ghost * 0.3)
			draw_circle(pos, size, Color(1.0, 0.4 - ghost * 0.1, 0.0, ghost_alpha * ratio))

	# Main whip body with fire gradient
	var prev_pos := Vector2.ZERO
	for i in range(24):
		var ratio := float(i) / 23.0
		var angle := base_angle + lerpf(-PI * 0.4, sweep, ratio)
		var r := length * (0.25 + ratio * 0.75)
		var pos := Vector2(cos(angle), sin(angle)) * r
		var width := lerpf(6.0, 2.0, ratio)
		var fire_t := clampf(ratio * 1.5, 0.0, 1.0)
		var col := Color(1.0, lerpf(0.95, 0.2, fire_t), lerpf(0.6, 0.0, fire_t), alpha * (0.5 + ratio * 0.5))

		if i > 0:
			draw_line(prev_pos, pos, col, width)
			draw_line(prev_pos, pos, Color(1.0, 0.8, 0.3, alpha * 0.15), width * 3.0)

		# Fire sparks along whip
		if i % 3 == 0 and ratio > 0.3:
			var spark_offset := Vector2(randf_range(-5, 5), randf_range(-8, -2))
			draw_circle(pos + spark_offset, randf_range(1.5, 3.5), Color(1.0, 0.7, 0.1, alpha * 0.6))

		prev_pos = pos

	# Whip tip explosion
	var tip_angle := base_angle + sweep
	var tip_pos := Vector2(cos(tip_angle), sin(tip_angle)) * length
	var tip_pulse := sin(t * PI * 3.0) * 0.3 + 0.7
	draw_circle(tip_pos, 16.0 * alpha * tip_pulse, Color(1.0, 0.5, 0.0, alpha * 0.2))
	draw_circle(tip_pos, 10.0 * alpha * tip_pulse, Color(1.0, 0.7, 0.2, alpha * 0.4))
	draw_circle(tip_pos, 5.0 * alpha, Color(1.0, 0.95, 0.7, alpha * 0.8))
	draw_circle(tip_pos, 2.5 * alpha, Color(1, 1, 1, alpha))

	# Radiating light rays from tip
	for i in range(8):
		var ray_angle := tip_angle + (TAU / 8.0) * i + t * 2.0
		var ray_len := 20.0 * alpha * tip_pulse
		var ray_end := tip_pos + Vector2(cos(ray_angle), sin(ray_angle)) * ray_len
		draw_line(tip_pos, ray_end, Color(1.0, 0.6, 0.1, alpha * 0.3), 1.5)

	# Crack particles (ember sparks)
	for p in _crack_particles:
		var pa := clampf(p["t"] / 0.4, 0.0, 1.0)
		draw_circle(p["pos"], p["s"] * pa, Color(1.0, 0.6, 0.1, pa * 0.8))
		draw_circle(p["pos"], p["s"] * 0.4 * pa, Color(1.0, 0.95, 0.6, pa * 0.5))

	# Hit impact flashes
	for hp in _hit_positions:
		var flash_a := alpha * 0.6
		draw_circle(hp, 12.0, Color(1, 1, 1, flash_a * 0.3))
		draw_circle(hp, 6.0, Color(1.0, 0.8, 0.2, flash_a))
