extends Node2D

var _timer: float
var _duration: float
var _dir: Vector2
var _length: float
var _width: float
var _color: Color
var _warning_phase: float = 0.5


func _ready() -> void:
	_dir = get_meta("fx_dir", Vector2.RIGHT)
	_length = get_meta("fx_length", 300.0)
	_width = get_meta("fx_width", 40.0)
	_color = get_meta("fx_color", Color(0.9, 0.8, 0.6))
	_duration = get_meta("fx_duration", 1.0)
	_timer = _duration


func _process(delta: float) -> void:
	_timer -= delta
	if _timer <= 0:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var progress := 1.0 - (_timer / _duration)
	var perp := Vector2(-_dir.y, _dir.x)

	if progress < _warning_phase:
		var warn_t: float = progress / _warning_phase
		var alpha: float = 0.15 + warn_t * 0.25
		var w: float = _width * warn_t
		var p1: Vector2 = perp * w * 0.5
		var p2: Vector2 = _dir * _length
		var warn_color := Color(_color.r, _color.g, _color.b, alpha)
		draw_line(-p1, p2 - p1, warn_color, 1.5)
		draw_line(p1, p2 + p1, warn_color, 1.5)
		var flash: float = (sin(Time.get_ticks_msec() * 0.02) + 1.0) * 0.5
		var inner_alpha: float = alpha * 0.3 * flash
		var points := PackedVector2Array([
			-p1, p2 - p1, p2 + p1, p1
		])
		var colors := PackedColorArray([
			Color(_color.r, _color.g, _color.b, inner_alpha),
			Color(_color.r, _color.g, _color.b, inner_alpha),
			Color(_color.r, _color.g, _color.b, inner_alpha),
			Color(_color.r, _color.g, _color.b, inner_alpha),
		])
		draw_polygon(points, colors)
	else:
		var hit_t: float = (progress - _warning_phase) / (1.0 - _warning_phase)
		var alpha: float = (1.0 - hit_t) * 0.8
		var w: float = _width * (1.0 - hit_t * 0.3)
		var p1: Vector2 = perp * w * 0.5
		var p2: Vector2 = _dir * _length
		var hit_color := Color(_color.r * 1.5, _color.g * 0.5, _color.b * 0.3, alpha)
		var points := PackedVector2Array([
			-p1, p2 - p1, p2 + p1, p1
		])
		var colors := PackedColorArray([
			hit_color, hit_color, hit_color, hit_color,
		])
		draw_polygon(points, colors)
