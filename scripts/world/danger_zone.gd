extends Node2D

const WARNING_TIME := 1.2
const ACTIVE_TIME := 5.0
const RADIUS := 95.0
const DAMAGE_PER_TICK := 6
const DAMAGE_INTERVAL := 0.65

var _timer: float = 0.0
var _damage_timer: float = 0.0
var _active: bool = false
var _fading: bool = false


func _ready() -> void:
	z_index = -1
	modulate.a = 0.0
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

	if _timer >= WARNING_TIME + ACTIVE_TIME and not _fading:
		_fade_out()
	queue_redraw()


func _draw() -> void:
	var warning_alpha := 0.18 + sin(Time.get_ticks_msec() * 0.012) * 0.06
	if not _active:
		draw_circle(Vector2.ZERO, RADIUS, Color(1.0, 0.25, 0.05, warning_alpha))
		draw_arc(Vector2.ZERO, RADIUS, 0.0, TAU, 48, Color(1.0, 0.65, 0.15, 0.65), 3.0)
		return

	draw_circle(Vector2.ZERO, RADIUS, Color(0.85, 0.05, 0.02, 0.24))
	draw_arc(Vector2.ZERO, RADIUS, 0.0, TAU, 48, Color(1.0, 0.15, 0.08, 0.85), 3.0)


func _damage_player_if_inside() -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return
	if global_position.distance_squared_to(player.global_position) <= RADIUS * RADIUS:
		player.take_damage(DAMAGE_PER_TICK)


func _fade_out() -> void:
	_fading = true
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.35)
	tw.tween_callback(queue_free)
