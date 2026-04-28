extends Node2D

var _timer: float
var _duration: float
var _max_radius: float
var _color: Color
var _width: float


func _ready() -> void:
	_color = get_meta("fx_color", Color.WHITE)
	_max_radius = get_meta("max_radius", 60.0)
	_duration = get_meta("duration", 0.3)
	_width = get_meta("width", 3.0)
	_timer = _duration


func _process(delta: float) -> void:
	_timer -= delta
	if _timer <= 0:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var progress := 1.0 - (_timer / _duration)
	var r := _max_radius * progress
	var alpha := (1.0 - progress) * 0.8
	# Outer ring
	draw_arc(Vector2.ZERO, r, 0, TAU, 32, Color(_color, alpha), _width)
	# Inner glow ring
	draw_arc(Vector2.ZERO, r * 0.7, 0, TAU, 24, Color(_color, alpha * 0.3), _width * 2.0)
