extends Node2D

# 普通怪弹幕（PRD 5.10.4）：与 boss_projectile 独立，避免修改 Boss 弹幕逻辑

var direction: Vector2 = Vector2.RIGHT
var proj_speed: float = 180.0
var proj_damage: int = 10
var proj_color: Color = Color(0.7, 0.55, 0.95)
var _lifetime: float = 4.0
var _size: float = 4.5


func _ready() -> void:
	_lifetime = 4.0
	z_index = GameData.Z_VFX_MID


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
			VfxPool.hit_flash(global_position, proj_color, 10.0)
			queue_free()
			return

	queue_redraw()


func _draw() -> void:
	# 紫色弹丸，无拖尾（与 Boss 弹幕的高强度视觉区分）
	draw_circle(Vector2.ZERO, _size, proj_color)
	draw_circle(Vector2.ZERO, _size * 0.55, proj_color.lightened(0.5))
