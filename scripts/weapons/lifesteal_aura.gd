extends WeaponBase

var _tick_timer: float = 0.0
var _pulse_anim: float = 0.0
var _drain_particles: Array = []
var _chain_links: Array = []

const TICK_RATE := 0.5
const HEAL_RATIO := 0.3


func _ready() -> void:
	weapon_type = GameData.WeaponType.LIFESTEAL_AURA


func attack() -> void:
	start_cooldown()


func _process(delta: float) -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return

	_pulse_anim += delta * 2.5
	if _pulse_anim > TAU:
		_pulse_anim -= TAU

	_tick_timer += delta
	if _tick_timer >= TICK_RATE:
		_tick_timer -= TICK_RATE
		_tick_effect(player)

	var to_remove: Array = []
	for i in range(_drain_particles.size()):
		var p: Dictionary = _drain_particles[i]
		p["t"] += delta * 2.0
		if p["t"] >= 1.0:
			to_remove.append(i)
	to_remove.reverse()
	for idx in to_remove:
		_drain_particles.remove_at(idx)

	# Update chain links
	for c in _chain_links:
		c["t"] += delta * 3.0
	_chain_links = _chain_links.filter(func(c: Dictionary) -> bool: return c["t"] < 1.0)

	queue_redraw()


func _tick_effect(player: Node2D) -> void:
	var radius := GameData.get_weapon_area(weapon_type, weapon_level)
	var dmg := get_damage()
	var total_healed := 0.0

	for enemy in SpatialGrid.get_in_range(player.global_position, radius):
		enemy.take_damage(dmg)
		total_healed += dmg * HEAL_RATIO
		if _drain_particles.size() < 25:
			_drain_particles.append({
				"from": enemy.global_position,
				"to": player.global_position,
				"t": 0.0,
				"wobble": randf_range(-1.0, 1.0),
			})
		if _chain_links.size() < 10:
			_chain_links.append({
				"from": enemy.global_position,
				"to": player.global_position,
				"t": 0.0,
			})

	if total_healed > 0 and player.has_method("heal"):
		player.heal(int(total_healed))


func _draw() -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return
	var radius := GameData.get_weapon_area(weapon_type, weapon_level)
	var pos := player.global_position - global_position
	var pulse := sin(_pulse_anim) * 0.15 + 0.85
	var r := radius * pulse

	# Dark vortex spiral (3 arms, more dramatic)
	for i in range(3):
		var base_angle := _pulse_anim * 1.2 + (TAU / 3.0) * i
		var pts := PackedVector2Array()
		for s in range(16):
			var t := float(s) / 15.0
			var angle := base_angle + t * PI * 2.0
			var sr := r * (0.15 + t * 0.85)
			pts.append(pos + Vector2(cos(angle), sin(angle)) * sr)
		for s in range(pts.size() - 1):
			var alpha := 0.25 * (float(s) / float(pts.size()))
			draw_line(pts[s], pts[s + 1], Color(0.5, 0.05, 0.6, alpha), 2.5)
			draw_line(pts[s], pts[s + 1], Color(0.7, 0.1, 0.8, alpha * 0.3), 6.0)

	# Outer dark aura rings with pulse
	draw_arc(pos, r, 0, TAU, 48, Color(0.5, 0.05, 0.6, 0.25), 3.0)
	draw_arc(pos, r, 0, TAU, 48, Color(0.6, 0.1, 0.7, 0.08), 8.0)
	draw_arc(pos, r * 0.8, 0, TAU, 36, Color(0.7, 0.15, 0.8, 0.12), 1.5)
	# Dark inner field
	draw_circle(pos, r * 0.3, Color(0.3, 0.0, 0.4, 0.06))

	# Soul chain links (dark lines connecting enemies to player)
	for c in _chain_links:
		var ct: float = c["t"]
		var cf: Vector2 = c["from"] - global_position
		var cto: Vector2 = c["to"] - global_position
		var ca := (1.0 - ct) * 0.4
		# Chain segments
		var seg_count := 6
		var prev := cf
		for s in range(1, seg_count + 1):
			var st := float(s) / float(seg_count)
			var sp := cf.lerp(cto, st)
			sp += Vector2(sin(st * TAU * 2.0 + ct * 5.0) * 6.0, cos(st * TAU * 2.0 + ct * 5.0) * 6.0)
			draw_line(prev, sp, Color(0.6, 0.1, 0.7, ca), 1.5)
			draw_circle(sp, 2.0, Color(0.8, 0.2, 0.9, ca * 0.5))
			prev = sp

	# Blood orb drain particles (enemy to player)
	for p in _drain_particles:
		var t: float = p["t"]
		var from: Vector2 = p["from"] - global_position
		var to: Vector2 = p["to"] - global_position
		var current := from.lerp(to, t * t)
		var wobble: float = p["wobble"]
		current += Vector2(sin(t * TAU * 2.0 + wobble * 3.0) * 12.0, -sin(t * PI) * 25.0 * wobble)
		var pa := (1.0 - t) * 0.9

		# Blood orb outer glow
		draw_circle(current, 6.0, Color(0.8, 0.05, 0.15, pa * 0.15))
		# Blood orb body
		draw_circle(current, 3.5, Color(1.0, 0.15, 0.25, pa * 0.7))
		# Blood orb core
		draw_circle(current, 2.0, Color(1.0, 0.5, 0.6, pa * 0.5))
		draw_circle(current, 1.0, Color(1, 0.8, 0.8, pa * 0.3))

		# Blood trail (longer, curved)
		if t > 0.08:
			var prev_t := t - 0.08
			var prev := from.lerp(to, prev_t * prev_t)
			prev += Vector2(sin(prev_t * TAU * 2.0 + wobble * 3.0) * 12.0, -sin(prev_t * PI) * 25.0 * wobble)
			draw_line(prev, current, Color(1.0, 0.15, 0.2, pa * 0.3), 2.0)
			draw_line(prev, current, Color(1.0, 0.3, 0.4, pa * 0.1), 5.0)
		if t > 0.16:
			var prev_t2 := t - 0.16
			var prev2 := from.lerp(to, prev_t2 * prev_t2)
			prev2 += Vector2(sin(prev_t2 * TAU * 2.0 + wobble * 3.0) * 12.0, -sin(prev_t2 * PI) * 25.0 * wobble)
			draw_line(prev2, current, Color(0.8, 0.1, 0.2, pa * 0.1), 1.0)

	# Dark energy particles orbiting
	var orb_count := 6
	for i in range(orb_count):
		var angle := _pulse_anim * 1.5 + (TAU / orb_count) * i
		var orb_r := r * (0.7 + sin(angle * 2.0 + _pulse_anim) * 0.15)
		var op := pos + Vector2(cos(angle), sin(angle)) * orb_r
		draw_circle(op, 3.0, Color(0.6, 0.1, 0.7, 0.3))
		draw_circle(op, 1.5, Color(0.9, 0.3, 1.0, 0.2))

	# Center dark core pulsating
	draw_circle(pos, 6.0 * pulse, Color(0.4, 0.0, 0.5, 0.1))
	draw_circle(pos, 3.0, Color(0.6, 0.1, 0.7, 0.15))
