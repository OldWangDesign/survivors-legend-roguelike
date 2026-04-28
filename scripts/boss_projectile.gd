extends Node2D

var direction: Vector2 = Vector2.RIGHT
var proj_speed: float = 150.0
var proj_damage: int = 10
var proj_color: Color = Color(0.8, 0.2, 0.8)
var _lifetime: float = 5.0
var _size: float = 5.0


func _ready() -> void:
	_lifetime = 5.0


func _physics_process(delta: float) -> void:
	position += direction * proj_speed * delta
	_lifetime -= delta
	if _lifetime <= 0:
		queue_free()
		return

	var player := GameData.player_ref
	if is_instance_valid(player):
		if global_position.distance_to(player.global_position) < player.hit_radius + _size:
			player.take_damage(proj_damage)
			VfxPool.hit_flash(global_position, proj_color, 12.0)
			queue_free()

	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, _size, proj_color)
	draw_circle(Vector2.ZERO, _size * 0.5, proj_color.lightened(0.5))
