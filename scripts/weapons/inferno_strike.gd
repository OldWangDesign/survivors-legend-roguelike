extends Node2D

var _target: Vector2
var _damage: int = 50
var _radius: float = 80.0
var _weapon_ref: WeaponBase
var _fall_time: float = 0.4
var _timer: float = 0.0
var _phase: int = 0
var _linger: float = 0.6
var _particles: Array = []


func setup(target: Vector2, dmg: int, radius: float, weapon: WeaponBase) -> void:
	_target = target
	_damage = dmg
	_radius = radius
	_weapon_ref = weapon
	z_index = 5
	global_position = _target + Vector2(randf_range(-30, 30), -400)
	for i in range(12):
		_particles.append({
			"pos": Vector2(randf_range(-_radius, _radius), randf_range(-_radius, _radius)),
			"vel": Vector2(randf_range(-60, 60), randf_range(-100, -20)),
			"life": randf_range(0.3, 0.8),
		})


func _process(delta: float) -> void:
	_timer += delta
	if _phase == 0:
		var t := _timer / _fall_time
		global_position = global_position.lerp(_target, minf(t * 3.0, 1.0) * delta * 8.0)
		if _timer >= _fall_time:
			_phase = 1
			_timer = 0.0
			global_position = _target
			_impact()
	elif _phase == 1:
		for p in _particles:
			p["pos"] += p["vel"] * delta
			p["vel"].y += 200.0 * delta
			p["life"] -= delta
		if _timer >= _linger:
			queue_free()
			return
	queue_redraw()


func _impact() -> void:
	var r_sq := _radius * _radius
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if _target.distance_squared_to(enemy.global_position) < r_sq:
			enemy.take_damage(_damage)
			if _weapon_ref:
				_weapon_ref.spawn_damage_number(enemy.global_position, _damage)
	VfxPool.ring_wave(_target, Color(1.0, 0.5, 0.0), _radius * 1.5, 0.4, 4.0)
	VfxPool.spark_burst(_target, 16, Color(1.0, 0.3, 0.0), _radius, 0.5)


func _draw() -> void:
	var center := Vector2.ZERO
	if _phase == 0:
		var diff := _target - global_position
		draw_circle(center, 10.0, Color(1.0, 0.5, 0.0, 0.9))
		draw_circle(center, 16.0, Color(1.0, 0.3, 0.0, 0.4))
		draw_circle(center, 24.0, Color(1.0, 0.2, 0.0, 0.15))
		for i in range(4):
			var trail_end := center - diff.normalized() * (20.0 + float(i) * 12.0)
			var a := 0.5 - float(i) * 0.1
			draw_line(center, trail_end, Color(1.0, 0.6, 0.1, a), 3.0 - float(i) * 0.5)
	else:
		var t := _timer / _linger
		var expand := _radius * (0.5 + t * 0.5)
		draw_circle(center, expand, Color(1.0, 0.4, 0.0, 0.3 * (1.0 - t)))
		draw_circle(center, expand * 0.6, Color(1.0, 0.6, 0.1, 0.5 * (1.0 - t)))
		draw_circle(center, expand * 0.3, Color(1.0, 0.9, 0.3, 0.7 * (1.0 - t)))
		draw_arc(center, expand, 0, TAU, 32, Color(1.0, 0.3, 0.0, 0.6 * (1.0 - t)), 3.0)
		for p in _particles:
			if p["life"] > 0:
				var pa: float = p["life"]
				var pp: Vector2 = p["pos"]
				draw_circle(pp, 3.0, Color(1.0, 0.5, 0.0, pa))
				draw_circle(pp, 1.5, Color(1.0, 0.9, 0.3, pa * 0.8))
