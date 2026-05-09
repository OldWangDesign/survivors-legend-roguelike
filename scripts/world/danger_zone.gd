extends Node2D

# 危险区（PRD 5.7）：2s 预警 + 6-8s 持续伤害

const WARNING_TIME := 2.0
const ACTIVE_TIME_MIN := 6.0
const ACTIVE_TIME_MAX := 8.0
const RADIUS := 90.0
const DAMAGE_INTERVAL := 0.5  # 高频低伤

var _timer: float = 0.0
var _damage_timer: float = 0.0
var _active: bool = false
var _fading: bool = false
var _active_time: float = 7.0


func _ready() -> void:
	z_index = GameData.Z_DANGER_ZONE
	modulate.a = 0.0
	_active_time = randf_range(ACTIVE_TIME_MIN, ACTIVE_TIME_MAX)
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.25)


func _physics_process(delta: float) -> void:
	_timer += delta
	if not _active and _timer >= WARNING_TIME:
		_active = true
		_damage_timer = 0.0
		VfxPool.ring_wave(global_position, Color(1.0, 0.2, 0.1, 0.55), RADIUS, 0.25, 3.0)

	if _active:
		_damage_timer -= delta
		if _damage_timer <= 0.0:
			_damage_timer = DAMAGE_INTERVAL
			_damage_player_if_inside()

	if _timer >= WARNING_TIME + _active_time and not _fading:
		_fade_out()
	queue_redraw()


func _draw() -> void:
	var warning_alpha := 0.18 + sin(Time.get_ticks_msec() * 0.012) * 0.06
	if not _active:
		# 红色虚线圆圈预警（每 24°一段）
		draw_circle(Vector2.ZERO, RADIUS, Color(1.0, 0.25, 0.05, warning_alpha))
		var dash_segs: int = 18
		for i in range(dash_segs):
			if i % 2 == 0:
				continue
			var a1: float = TAU * float(i) / float(dash_segs)
			var a2: float = TAU * float(i + 1) / float(dash_segs)
			var p1: Vector2 = Vector2(cos(a1), sin(a1)) * RADIUS
			var p2: Vector2 = Vector2(cos(a2), sin(a2)) * RADIUS
			draw_line(p1, p2, Color(1.0, 0.4, 0.1, 0.85), 3.0)
		return

	# 激活：红色半透明区域 + 地面裂纹
	draw_circle(Vector2.ZERO, RADIUS, Color(0.85, 0.05, 0.02, 0.24))
	draw_arc(Vector2.ZERO, RADIUS, 0.0, TAU, 48, Color(1.0, 0.15, 0.08, 0.85), 3.0)
	# 地面裂纹（4 条不规则线）
	for i in range(4):
		var ang: float = TAU * float(i) / 4.0 + sin(Time.get_ticks_msec() * 0.001) * 0.2
		var p1: Vector2 = Vector2(cos(ang), sin(ang)) * (RADIUS * 0.3)
		var p2: Vector2 = Vector2(cos(ang), sin(ang)) * (RADIUS * 0.85)
		draw_line(p1, p2, Color(0.6, 0.05, 0.02, 0.55), 2.0)


func _damage_player_if_inside() -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return
	if global_position.distance_squared_to(player.global_position) <= RADIUS * RADIUS:
		# 玩家最大血量的 3-5%
		var dmg: int = maxi(1, int(player.max_health * 0.04))
		player.take_damage(dmg)


func _fade_out() -> void:
	_fading = true
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.35)
	tw.tween_callback(queue_free)
