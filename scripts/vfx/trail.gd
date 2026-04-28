extends Node2D

var _target: Node2D
var _color: Color
var _length: int = 8
var _width: float = 4.0
var _positions: Array[Vector2] = []


func _ready() -> void:
	_target = get_meta("target", null)
	_color = get_meta("trail_color", Color.WHITE)
	_length = get_meta("trail_length", 8)
	_width = get_meta("trail_width", 4.0)


func _process(_delta: float) -> void:
	if not is_instance_valid(_target):
		queue_free()
		return
	_positions.push_front(_target.global_position)
	if _positions.size() > _length:
		_positions.resize(_length)
	queue_redraw()


func _draw() -> void:
	if _positions.size() < 2:
		return
	for i in range(_positions.size() - 1):
		var t := 1.0 - float(i) / float(_positions.size())
		var alpha := t * t * 0.7
		var w := _width * t
		var from := _positions[i] - global_position
		var to := _positions[i + 1] - global_position
		draw_line(from, to, Color(_color, alpha), w)
		# Glow layer
		draw_line(from, to, Color(1, 1, 1, alpha * 0.3), w * 2.0)
