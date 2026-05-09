extends Node2D

# 紫色小灵魂粒子，飞向 player（PRD 5.2 #9 灵魂汲取）

const SPEED := 360.0
const MAX_LIFE := 0.9

var _time: float = 0.0
var _bob_offset: float = 0.0


func _ready() -> void:
	_bob_offset = randf() * TAU


func _process(delta: float) -> void:
	_time += delta
	if _time >= MAX_LIFE:
		queue_free()
		return
	# 飞行过程主角已死则就地消失
	var player := GameData.player_ref
	if not is_instance_valid(player):
		queue_free()
		return
	var dir := (player.global_position - global_position).normalized()
	# 加速曲线：先慢后快
	var t := _time / MAX_LIFE
	var spd: float = SPEED * (0.4 + t * 1.6)
	global_position += dir * spd * delta
	# 触达主角
	if global_position.distance_to(player.global_position) < player.hit_radius:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var t: float = clampf(1.0 - _time / MAX_LIFE, 0.0, 1.0)
	var a: float = 0.2 + 0.6 * t
	var bob: float = sin(_time * 12.0 + _bob_offset) * 1.5
	draw_circle(Vector2(0, bob), 5.0, Color(0.55, 0.25, 0.85, a * 0.4))
	draw_circle(Vector2(0, bob), 3.0, Color(0.85, 0.45, 1.0, a))
	draw_circle(Vector2(0, bob), 1.2, Color(1.0, 0.85, 1.0, a))
