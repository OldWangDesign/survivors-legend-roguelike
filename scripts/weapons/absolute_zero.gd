extends WeaponBase

var _time: float = 0.0
var _pulse_phase: float = 0.0
var _frozen_enemies: Array = []


func _ready() -> void:
	weapon_type = GameData.WeaponType.ABSOLUTE_ZERO
	z_index = 3


func attack() -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		start_cooldown()
		return

	var area: float = GameData.get_weapon_area(weapon_type, weapon_level)
	var dmg := get_damage()
	var freeze_dur := 2.0 + weapon_level * 0.3
	_frozen_enemies.clear()

	for enemy in SpatialGrid.get_in_range(player.global_position, area):
		enemy.take_damage(dmg)
		spawn_damage_number(enemy.global_position, dmg)
		if enemy.has_method("apply_slow"):
			enemy.apply_slow(0.0, freeze_dur)
		_frozen_enemies.append(weakref(enemy))

	_pulse_phase = 1.0
	play_weapon_sound("weapon_freeze")
	VfxPool.screen_flash(Color(0.5, 0.9, 1.0, 0.2), 0.1)
	VfxPool.ring_wave(player.global_position, Color(0.5, 0.9, 1.0), area, 0.6, 5.0)

	var gm := get_scene()
	if gm and gm.has_method("shake_camera"):
		gm.shake_camera(5.0)

	start_cooldown()


func _process(delta: float) -> void:
	_time += delta
	if _pulse_phase > 0:
		_pulse_phase -= delta * 0.8
		queue_redraw()
	elif int(_time * 10) % 20 == 0:
		queue_redraw()


func _draw() -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return
	var center := player.global_position - global_position
	var area: float = GameData.get_weapon_area(weapon_type, weapon_level)

	if _pulse_phase > 0:
		var expand := area * (1.0 - _pulse_phase * 0.3)
		draw_circle(center, expand, Color(0.5, 0.9, 1.0, 0.12 * _pulse_phase))
		draw_circle(center, expand * 0.7, Color(0.7, 0.95, 1.0, 0.2 * _pulse_phase))
		draw_arc(center, expand, 0, TAU, 64, Color(0.5, 0.9, 1.0, 0.4 * _pulse_phase), 3.0)

		for i in range(24):
			var angle := randf() * TAU
			var dist := randf() * expand
			var pos := center + Vector2(cos(angle), sin(angle)) * dist
			var sz := randf_range(2.0, 6.0) * _pulse_phase
			_draw_snowflake(pos, sz, Color(0.8, 0.95, 1.0, 0.6 * _pulse_phase))

		for i in range(6):
			var ray_angle := _time * 0.5 + (TAU / 6.0) * float(i)
			var ray_end := center + Vector2(cos(ray_angle), sin(ray_angle)) * expand
			draw_line(center, ray_end, Color(0.6, 0.9, 1.0, 0.15 * _pulse_phase), 2.0)

	var idle_pulse := sin(_time * 2.0) * 0.3 + 0.7
	draw_arc(center, area * idle_pulse * 0.1, 0, TAU, 24, Color(0.5, 0.9, 1.0, 0.08), 1.5)

	for wr in _frozen_enemies:
		var e: Node2D = wr.get_ref() as Node2D
		if is_instance_valid(e):
			var epos: Vector2 = e.global_position - global_position
			_draw_snowflake(epos + Vector2(0, -16), 4.0, Color(0.5, 0.9, 1.0, 0.6))


func _draw_snowflake(pos: Vector2, sz: float, col: Color) -> void:
	for i in range(6):
		var angle := (TAU / 6.0) * float(i)
		var arm_end := pos + Vector2(cos(angle), sin(angle)) * sz
		draw_line(pos, arm_end, col, 1.0)
		var branch := pos + Vector2(cos(angle), sin(angle)) * sz * 0.6
		var perp := Vector2(cos(angle + PI / 3.0), sin(angle + PI / 3.0)) * sz * 0.3
		draw_line(branch, branch + perp, col, 1.0)
