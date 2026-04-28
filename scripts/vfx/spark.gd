extends Node2D

var _vel: Vector2
var _timer: float
var _max_life: float
var _color: Color
var _size: float


func _ready() -> void:
	_vel = get_meta("vel", Vector2.ZERO)
	_color = get_meta("fx_color", Color.YELLOW)
	_timer = get_meta("lifetime", 0.3)
	_max_life = get_meta("max_life", 0.3)
	_size = randf_range(1.5, 3.5)


func _process(delta: float) -> void:
	_timer -= delta
	if _timer <= 0:
		queue_free()
		return
	position += _vel * delta
	_vel *= 0.92
	queue_redraw()


func _draw() -> void:
	var t := _timer / _max_life
	var alpha := t * t
	var s := _size * (0.5 + t * 0.5)
	# Diamond shape spark
	var col := Color(_color, alpha)
	var pts := PackedVector2Array([
		Vector2(0, -s * 1.5),
		Vector2(s, 0),
		Vector2(0, s * 1.5),
		Vector2(-s, 0),
	])
	draw_colored_polygon(pts, col)
	draw_circle(Vector2.ZERO, s * 0.4, Color(1, 1, 1, alpha * 0.6))
