extends Node2D

var _direction: Vector2 = Vector2.RIGHT
var _speed: float = 350.0
var _damage: int = 30
var _target: Node2D
var _weapon_ref: WeaponBase
var _lifetime: float = 3.0
var _time: float = 0.0
var _trail: Array[Vector2] = []
var _hit_enemies: Array = []
const TRAIL_LEN := 16
const HOMING_STRENGTH := 5.0
const EXPLOSION_RADIUS := 80.0
const CHAIN_RANGE := 120.0


func setup(pos: Vector2, dir: Vector2, dmg: int, target: Node2D, weapon: WeaponBase) -> void:
	global_position = pos
	_direction = dir.normalized()
	_damage = dmg
	_target = target
	_weapon_ref = weapon
	z_index = 4


func _process(delta: float) -> void:
	_time += delta
	_lifetime -= delta
	if _lifetime <= 0:
		_explode()
		return

	if is_instance_valid(_target):
		var to_target := (_target.global_position - global_position).normalized()
		_direction = _direction.lerp(to_target, HOMING_STRENGTH * delta).normalized()

	global_position += _direction * _speed * delta

	_trail.push_front(global_position)
	if _trail.size() > TRAIL_LEN:
		_trail.resize(TRAIL_LEN)

	var hit_r_sq := 20.0 * 20.0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy in _hit_enemies:
			continue
		if global_position.distance_squared_to(enemy.global_position) < hit_r_sq:
			enemy.take_damage(_damage)
			if _weapon_ref:
				_weapon_ref.spawn_damage_number(enemy.global_position, _damage)
			_hit_enemies.append(enemy)

			if _weapon_ref and is_instance_valid(GameData.player_ref):
				var heal_amt := maxi(1, int(_damage * 0.15))
				if GameData.player_ref.has_method("heal"):
					GameData.player_ref.heal(heal_amt)

			_explode()
			return

	queue_redraw()


func _explode() -> void:
	var half_dmg := int(_damage * 0.5)
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy in _hit_enemies:
			continue
		if global_position.distance_squared_to(enemy.global_position) < EXPLOSION_RADIUS * EXPLOSION_RADIUS:
			enemy.take_damage(half_dmg)
			if _weapon_ref:
				_weapon_ref.spawn_damage_number(enemy.global_position, half_dmg)

	VfxPool.ring_wave(global_position, Color(0.5, 0.0, 0.7), EXPLOSION_RADIUS, 0.4, 4.0)
	VfxPool.spark_burst(global_position, 12, Color(0.6, 0.1, 0.9), EXPLOSION_RADIUS * 0.8, 0.4)

	_chain_to_nearby()
	queue_free()


func _chain_to_nearby() -> void:
	var chain_count := 2
	var chained := 0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if chained >= chain_count:
			break
		if enemy in _hit_enemies:
			continue
		if global_position.distance_squared_to(enemy.global_position) > CHAIN_RANGE * CHAIN_RANGE:
			continue
		var chain_dmg := int(_damage * 0.3)
		enemy.take_damage(chain_dmg)
		if _weapon_ref:
			_weapon_ref.spawn_damage_number(enemy.global_position, chain_dmg)

		var bolt := Node2D.new()
		bolt.set_script(preload("res://scripts/weapons/lightning_bolt.gd"))
		var tree := get_tree()
		if tree and tree.current_scene:
			tree.current_scene.add_child(bolt)
			bolt.setup(global_position, enemy.global_position)
		chained += 1


func _draw() -> void:
	for i in range(_trail.size() - 1):
		var t := 1.0 - float(i) / float(_trail.size())
		var from := _trail[i] - global_position
		var to := _trail[i + 1] - global_position
		draw_line(from, to, Color(0.5, 0.0, 0.7, t * 0.1), 8.0 * t)
		draw_line(from, to, Color(0.6, 0.1, 0.9, t * 0.3), 3.0 * t)
		draw_line(from, to, Color(0.8, 0.4, 1.0, t * 0.5), 1.0 * t)
		if i % 2 == 0:
			var mid := (from + to) * 0.5
			var perp := (to - from).normalized().orthogonal()
			var spiral := perp * sin(_time * 14.0 + float(i)) * 6.0 * t
			draw_circle(mid + spiral, 2.0 * t, Color(0.7, 0.2, 1.0, t * 0.6))

	var pulse := sin(_time * 12.0) * 0.25 + 0.75
	draw_circle(Vector2.ZERO, 14.0 * pulse, Color(0.3, 0.0, 0.5, 0.1))
	draw_circle(Vector2.ZERO, 8.0 * pulse, Color(0.5, 0.0, 0.7, 0.25))
	draw_circle(Vector2.ZERO, 5.0, Color(0.6, 0.1, 0.9, 0.5))
	draw_circle(Vector2.ZERO, 2.5, Color(0.9, 0.5, 1.0, 0.8))

	for i in range(6):
		var sa := _time * 10.0 + (TAU / 6.0) * float(i)
		var sp_end := Vector2(cos(sa), sin(sa)) * 12.0 * pulse
		draw_line(Vector2.ZERO, sp_end, Color(0.6, 0.1, 0.9, 0.35), 1.0)

	var eye_r := 6.0 + sin(_time * 6.0) * 2.0
	draw_arc(Vector2.ZERO, eye_r, 0, TAU, 16, Color(0.7, 0.2, 1.0, 0.4), 1.5)
