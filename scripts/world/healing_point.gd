extends Node2D

const RADIUS := 42.0
const HEAL_AMOUNT := 35
const MAX_LIFETIME := 16.0

var _timer: float = 0.0
var _picked := false


func _ready() -> void:
	z_index = 2
	modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.25)


func _physics_process(delta: float) -> void:
	if _picked:
		return
	_timer += delta
	if _timer >= MAX_LIFETIME:
		_fade_out()
		return
	var player := GameData.player_ref
	if is_instance_valid(player) and global_position.distance_squared_to(player.global_position) <= RADIUS * RADIUS:
		_picked = true
		player.heal(HEAL_AMOUNT)
		VfxPool.float_text(global_position + Vector2(0, -24), "治疗 +" + str(HEAL_AMOUNT), GameData.UI_GREEN, 16.0, false)
		VfxPool.ring_wave(global_position, GameData.UI_GREEN, RADIUS * 1.5, 0.25, 3.0)
		_fade_out()
	queue_redraw()


func _draw() -> void:
	var pulse := 0.5 + (sin(Time.get_ticks_msec() * 0.008) + 1.0) * 0.25
	draw_circle(Vector2.ZERO, RADIUS, Color(0.1, 0.85, 0.25, 0.12 + pulse * 0.08))
	draw_arc(Vector2.ZERO, RADIUS, 0.0, TAU, 40, Color(0.3, 1.0, 0.45, 0.65), 2.0)
	draw_line(Vector2(-10, 0), Vector2(10, 0), Color(0.75, 1.0, 0.75, 0.9), 4.0)
	draw_line(Vector2(0, -10), Vector2(0, 10), Color(0.75, 1.0, 0.75, 0.9), 4.0)


func _fade_out() -> void:
	_picked = true
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.35)
	tw.tween_callback(queue_free)
