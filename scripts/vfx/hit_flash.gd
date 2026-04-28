extends Node2D

var _timer: float = 0.15
var _max_time: float = 0.15
var _color: Color = Color.WHITE
var _size: float = 12.0


func _ready() -> void:
	_color = get_meta("fx_color", Color.WHITE)
	_size = get_meta("fx_size", 12.0)
	_max_time = 0.15
	_timer = _max_time


func _process(delta: float) -> void:
	_timer -= delta
	if _timer <= 0:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var t := _timer / _max_time
	var s := _size * (1.5 - t * 0.5)
	var alpha := t

	# Cross flash
	var col := Color(_color, alpha)
	var col_core := Color(1, 1, 1, alpha * 0.8)
	draw_line(Vector2(-s, 0), Vector2(s, 0), col, 2.5)
	draw_line(Vector2(0, -s), Vector2(0, s), col, 2.5)
	# Diagonal cross
	var d := s * 0.6
	draw_line(Vector2(-d, -d), Vector2(d, d), col, 1.5)
	draw_line(Vector2(-d, d), Vector2(d, -d), col, 1.5)
	# Core glow
	draw_circle(Vector2.ZERO, s * 0.25, col_core)
	draw_circle(Vector2.ZERO, s * 0.5, Color(_color, alpha * 0.3))
