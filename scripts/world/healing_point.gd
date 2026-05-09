extends Node2D

# 治疗点（PRD 5.7）：15-20% HP，8-12s 寿命，触发半径 25-30px，视觉半径 60px

const TRIGGER_RADIUS := 28.0
const VISUAL_RADIUS := 60.0
const LIFETIME_MIN := 8.0
const LIFETIME_MAX := 12.0
const HEAL_PERCENT := 0.18  # 18%

var _timer: float = 0.0
var _picked := false
var _lifetime: float = 10.0


func _ready() -> void:
	z_index = GameData.Z_HEALING_POINT
	modulate.a = 0.0
	_lifetime = randf_range(LIFETIME_MIN, LIFETIME_MAX)
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.25)


func _physics_process(delta: float) -> void:
	if _picked:
		return
	_timer += delta
	if _timer >= _lifetime:
		_fade_out()
		return
	var player := GameData.player_ref
	if is_instance_valid(player) and global_position.distance_squared_to(player.global_position) <= TRIGGER_RADIUS * TRIGGER_RADIUS:
		_picked = true
		var heal_amount: int = maxi(1, int(player.max_health * HEAL_PERCENT))
		player.heal(heal_amount)
		VfxPool.float_text(global_position + Vector2(0, -24), "治疗 +" + str(heal_amount), GameData.UI_GREEN, 16.0, false)
		VfxPool.ring_wave(global_position, GameData.UI_GREEN, VISUAL_RADIUS * 1.5, 0.3, 3.0)
		VfxPool.spark_burst(global_position, 8, Color(0.4, 1.0, 0.5), 80.0, 0.4)
		_fade_out()
	queue_redraw()


func _draw() -> void:
	# 视觉半径 60px 远大于触发半径，便于发现
	var pulse := 0.5 + (sin(Time.get_ticks_msec() * 0.008) + 1.0) * 0.25
	# 外环（视觉半径，吸引玩家）
	draw_circle(Vector2.ZERO, VISUAL_RADIUS, Color(0.1, 0.85, 0.25, 0.08 + pulse * 0.05))
	draw_arc(Vector2.ZERO, VISUAL_RADIUS, 0.0, TAU, 40, Color(0.3, 1.0, 0.45, 0.55), 1.8)
	# 触发环（更亮）
	draw_arc(Vector2.ZERO, TRIGGER_RADIUS, 0.0, TAU, 32, Color(0.4, 1.0, 0.5, 0.8), 2.0)
	# 中心十字
	draw_line(Vector2(-10, 0), Vector2(10, 0), Color(0.75, 1.0, 0.75, 0.9), 4.0)
	draw_line(Vector2(0, -10), Vector2(0, 10), Color(0.75, 1.0, 0.75, 0.9), 4.0)


func _fade_out() -> void:
	_picked = true
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.35)
	tw.tween_callback(queue_free)
