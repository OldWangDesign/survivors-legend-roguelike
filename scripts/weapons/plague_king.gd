extends WeaponBase

var _time: float = 0.0
var _bubble_particles: Array = []


func _ready() -> void:
	weapon_type = GameData.WeaponType.PLAGUE_KING
	z_index = 2
	for i in range(30):
		_bubble_particles.append({
			"angle": randf() * TAU,
			"dist": randf_range(0.3, 1.0),
			"speed": randf_range(0.3, 0.8),
			"size": randf_range(2.0, 5.0),
			"phase": randf() * TAU,
		})


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
		spawn_damage_number(enemy.global_position, dmg)
		if enemy.has_method("apply_slow"):
			enemy.apply_slow(0.4, 1.5)

	start_cooldown()


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return
	var area: float = GameData.get_weapon_area(weapon_type, weapon_level)
	if is_instance_valid(player):
		area *= player.area_mult
	var center := player.global_position - global_position

	draw_circle(center, area, Color(0.2, 0.5, 0.0, 0.06))
	draw_arc(center, area, 0, TAU, 24, Color(0.3, 0.7, 0.0, 0.15), 2.0)

	for p in _bubble_particles:
		var pa: float = p["angle"]
		var pd: float = p["dist"]
		var ps: float = p["speed"]
		var psz: float = p["size"]
		var pp: float = p["phase"]
		var a := pa + _time * ps
		var dist := pd * area + sin(_time * 2.0 + pp) * area * 0.05
		var bpos := center + Vector2(cos(a), sin(a)) * dist
		var pulse := sin(_time * 3.0 + pp) * 0.3 + 0.7
		draw_circle(bpos, psz * pulse, Color(0.3, 0.7, 0.0, 0.25))

	var core_pulse := sin(_time * 4.0) * 0.2 + 0.8
	draw_circle(center, 8.0 * core_pulse, Color(0.3, 0.6, 0.0, 0.1))
	draw_circle(center, 4.0, Color(0.5, 0.8, 0.0, 0.15))


func _draw_mini_skull(pos: Vector2, alpha: float) -> void:
	draw_circle(pos, 4.0, Color(0.4, 0.7, 0.0, alpha))
	draw_circle(pos + Vector2(-1.5, -1), 1.0, Color(0.1, 0.3, 0.0, alpha * 1.5))
	draw_circle(pos + Vector2(1.5, -1), 1.0, Color(0.1, 0.3, 0.0, alpha * 1.5))
	draw_line(pos + Vector2(-1, 2), pos + Vector2(1, 2), Color(0.2, 0.4, 0.0, alpha), 1.0)
