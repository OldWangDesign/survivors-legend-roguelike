extends WeaponBase

var _time: float = 0.0
var _hammer_pos: Vector2 = Vector2.ZERO
var _hammer_vel: Vector2 = Vector2.ZERO
var _state: int = 0
var _return_timer: float = 0.0
var _trail: Array[Vector2] = []
var _target_pos: Vector2 = Vector2.ZERO
const TRAIL_LEN := 20


func _ready() -> void:
	weapon_type = GameData.WeaponType.THOR_HAMMER
	z_index = 3


func attack() -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		start_cooldown()
		return

	var enemies := SpatialGrid.get_nearby(player.global_position, 500.0)
	if enemies.is_empty():
		start_cooldown()
		return

	var nearest := get_nearest_enemy(player.global_position, 500.0)
	if nearest == null:
		nearest = enemies[randi() % enemies.size()]

	_hammer_pos = player.global_position
	_target_pos = nearest.global_position
	var dir := (_target_pos - _hammer_pos).normalized()
	_hammer_vel = dir * 400.0
	_state = 1
	_return_timer = 0.0
	_trail.clear()

	play_weapon_sound("weapon_lightning")
	start_cooldown()


func _process(delta: float) -> void:
	_time += delta
	if _state == 0:
		return

	var player := GameData.player_ref
	if not is_instance_valid(player):
		_state = 0
		return

	_trail.push_front(_hammer_pos)
	if _trail.size() > TRAIL_LEN:
		_trail.resize(TRAIL_LEN)

	if _state == 1:
		_hammer_pos += _hammer_vel * delta
		_return_timer += delta

		var dmg := get_damage()
		for enemy in SpatialGrid.get_nearby(_hammer_pos, 30.0):
			if _hammer_pos.distance_squared_to(enemy.global_position) < 30.0 * 30.0:
				enemy.take_damage(dmg)
				spawn_damage_number(enemy.global_position, dmg)
				if enemy.has_method("apply_knockback"):
					enemy.apply_knockback(_hammer_vel.normalized() * 200.0)
				_strike_lightning(enemy.global_position)

		if _return_timer > 0.15 and _hammer_pos.distance_to(_target_pos) < 40.0:
			_thunder_explosion()
			_state = 2
			_return_timer = 0.0
		elif _return_timer > 1.5:
			_thunder_explosion()
			_state = 2
			_return_timer = 0.0
	elif _state == 2:
		var back_dir := (player.global_position - _hammer_pos).normalized()
		_hammer_vel = back_dir * 500.0
		_hammer_pos += _hammer_vel * delta

		var dmg := get_damage()
		for enemy in SpatialGrid.get_nearby(_hammer_pos, 30.0):
			if _hammer_pos.distance_squared_to(enemy.global_position) < 30.0 * 30.0:
				enemy.take_damage(int(dmg * 0.5))
				spawn_damage_number(enemy.global_position, int(dmg * 0.5))

		if _hammer_pos.distance_to(player.global_position) < 30.0:
			_state = 0
			return

		_return_timer += delta
		if _return_timer > 2.0:
			_state = 0
			return

	queue_redraw()


func _thunder_explosion() -> void:
	var area: float = GameData.get_weapon_area(weapon_type, weapon_level)
	var dmg := int(get_damage() * 1.5)
	for enemy in SpatialGrid.get_in_range(_hammer_pos, area):
		enemy.take_damage(dmg)
		spawn_damage_number(enemy.global_position, dmg)

	VfxPool.ring_wave(_hammer_pos, Color(0.6, 0.8, 1.0), area * 1.5, 0.5, 5.0)
	VfxPool.spark_burst(_hammer_pos, 24, Color(0.7, 0.9, 1.0), area, 0.5)
	VfxPool.screen_flash(Color(0.7, 0.85, 1.0, 0.15), 0.06)

	var gm := get_scene()
	if gm and gm.has_method("shake_camera"):
		gm.shake_camera(6.0)


func _strike_lightning(pos: Vector2) -> void:
	var bolt := Node2D.new()
	bolt.set_script(preload("res://scripts/weapons/lightning_bolt.gd"))
	var scene := get_scene()
	if scene == null:
		return
	scene.add_child(bolt)
	bolt.setup(pos + Vector2(0, -200), pos)


func _draw() -> void:
	if _state == 0:
		return
	var local := _hammer_pos - global_position

	for i in range(_trail.size() - 1):
		var t := 1.0 - float(i) / float(_trail.size())
		var from := _trail[i] - global_position
		var to := _trail[i + 1] - global_position
		draw_line(from, to, Color(0.6, 0.8, 1.0, t * 0.15), 6.0 * t)
		draw_line(from, to, Color(0.8, 0.9, 1.0, t * 0.3), 2.0 * t)
		if i % 3 == 0:
			var mid := (from + to) * 0.5
			var trail_perp := (to - from).normalized().orthogonal()
			var bolt_off := trail_perp * sin(_time * 20.0 + float(i)) * 8.0 * t
			draw_line(mid, mid + bolt_off, Color(0.7, 0.9, 1.0, t * 0.5), 1.0)

	draw_circle(local, 20.0, Color(0.5, 0.7, 1.0, 0.08))
	draw_circle(local, 12.0, Color(0.6, 0.8, 1.0, 0.15))

	var rot := _time * 6.0
	var head_sz := 10.0
	var handle_dir := _hammer_vel.normalized() if _hammer_vel.length() > 1.0 else Vector2.DOWN
	var perp := handle_dir.orthogonal()

	var h_top := local - handle_dir * head_sz
	var h_bot := local + handle_dir * head_sz * 1.5
	draw_line(h_top, h_bot, Color(0.5, 0.35, 0.2, 0.9), 3.0)

	var head_l := local + perp * head_sz - handle_dir * head_sz * 0.3
	var head_r := local - perp * head_sz - handle_dir * head_sz * 0.3
	var head_lt := local + perp * head_sz + handle_dir * head_sz * 0.4
	var head_rt := local - perp * head_sz + handle_dir * head_sz * 0.4
	var head_pts := PackedVector2Array([head_l, head_lt, head_rt, head_r])
	draw_colored_polygon(head_pts, Color(0.5, 0.55, 0.65, 0.85))
	draw_polyline(PackedVector2Array([head_l, head_lt, head_rt, head_r, head_l]),
		Color(0.7, 0.85, 1.0, 0.6), 1.5)

	draw_circle(local, 4.0, Color(0.7, 0.9, 1.0, 0.7))
	draw_circle(local, 2.0, Color(1.0, 1.0, 1.0, 0.9))

	for i in range(4):
		var sa := rot + (TAU / 4.0) * float(i)
		var spark_end := local + Vector2(cos(sa), sin(sa)) * 18.0
		draw_line(local, spark_end, Color(0.6, 0.85, 1.0, 0.3), 1.0)
