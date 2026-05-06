extends Node2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 300.0
var damage: int = 10
var lifetime: float = 2.0
var color: Color = Color.WHITE
var radius: float = 5.0
var piercing: bool = false
var _hit_enemies: Array = []
var _sprite: Sprite2D
var _trail_positions: Array[Vector2] = []
var _time: float = 0.0
const TRAIL_LENGTH := 14


func setup(dir: Vector2, spd: float, dmg: int, life: float, col: Color, rad: float, pierce: bool = false) -> void:
	direction = dir.normalized()
	speed = spd
	damage = dmg
	lifetime = life
	color = col
	radius = rad
	piercing = pierce
	z_index = 2

	_sprite = Sprite2D.new()
	var tex = GameData.sprites.get("projectile")
	if tex:
		_sprite.texture = tex
	_sprite.scale = Vector2.ONE * (radius * 2.0 / 8.0)
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.modulate = col
	_sprite.rotation = direction.angle()
	add_child(_sprite)


func _physics_process(delta: float) -> void:
	_time += delta
	position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
		return

	_trail_positions.push_front(global_position)
	if _trail_positions.size() > TRAIL_LENGTH:
		_trail_positions.resize(TRAIL_LENGTH)

	var hit_r := radius + 12.0
	var hit_r_sq := hit_r * hit_r
	for enemy in SpatialGrid.get_nearby(global_position, hit_r):
		if enemy in _hit_enemies:
			continue
		if global_position.distance_squared_to(enemy.global_position) < hit_r_sq:
			enemy.take_damage(damage)
			_spawn_damage_number(enemy.global_position, damage)
			if piercing:
				_hit_enemies.append(enemy)
			else:
				VfxPool.spark_burst(global_position, 8, color, 80.0, 0.25)
				VfxPool.ring_wave(global_position, color, 25.0, 0.15, 2.0)
				queue_free()
				return
	queue_redraw()


func _draw() -> void:
	for i in range(_trail_positions.size() - 1):
		var t := 1.0 - float(i) / float(_trail_positions.size())
		var from := _trail_positions[i] - global_position
		var to := _trail_positions[i + 1] - global_position
		draw_line(from, to, Color(color, t * 0.08), radius * 4.0 * t)
		draw_line(from, to, Color(color, t * 0.25), radius * 1.8 * t)
		draw_line(from, to, Color(1, 1, 1, t * 0.4), radius * 0.6 * t)

	var pulse := sin(_time * 15.0) * 0.25 + 0.75
	var core_r := radius * 1.2
	draw_circle(Vector2.ZERO, core_r * 2.5 * pulse, Color(color, 0.08))
	draw_circle(Vector2.ZERO, core_r * 1.8 * pulse, Color(color, 0.18))
	draw_circle(Vector2.ZERO, core_r * 1.2, Color(color, 0.35))
	draw_circle(Vector2.ZERO, core_r * 0.7, Color(color.lightened(0.5), 0.6))
	draw_circle(Vector2.ZERO, core_r * 0.3, Color(1, 1, 1, 0.8))


func _spawn_damage_number(pos: Vector2, dmg: int) -> void:
	var is_crit := dmg >= 20
	var col := Color.GOLD if is_crit else Color(1, 0.9, 0.7)
	VfxPool.float_text(pos + Vector2(randf_range(-5, 5), -10), str(dmg), col, 16.0, is_crit)
