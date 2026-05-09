extends Node2D

# 暗影巫妖 dark_field 持续可见的紫色半透明区域（PRD 5.5.6 #6）

var zone_radius: float = 120.0
var life_time: float = 4.0

var _timer: float = 0.0
var _slow_applied: bool = false


func _ready() -> void:
	z_index = GameData.Z_DANGER_ZONE
	modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.25)


func _physics_process(delta: float) -> void:
	_timer += delta
	if _timer >= life_time:
		_fade_out()
		return
	# 每帧检查玩家是否在区域内（用低频减速效果，不重复施加）
	var player := GameData.player_ref
	if is_instance_valid(player):
		var inside: bool = global_position.distance_squared_to(player.global_position) <= zone_radius * zone_radius
		if inside and not _slow_applied:
			_slow_applied = true
			player.apply_slow(0.5, 1.0)
		elif not inside:
			_slow_applied = false
	queue_redraw()


func _draw() -> void:
	var pulse: float = (sin(Time.get_ticks_msec() * 0.005) + 1.0) * 0.5
	draw_circle(Vector2.ZERO, zone_radius, Color(0.2, 0.0, 0.3, 0.18 + pulse * 0.05))
	draw_arc(Vector2.ZERO, zone_radius, 0.0, TAU, 48, Color(0.55, 0.2, 0.85, 0.65), 2.5)
	# 内圈装饰
	draw_arc(Vector2.ZERO, zone_radius * 0.7, 0.0, TAU, 36, Color(0.7, 0.3, 1.0, 0.35), 1.5)


func _fade_out() -> void:
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.4)
	tw.tween_callback(queue_free)
