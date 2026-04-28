extends Node2D

var text: String = ""
var text_color: Color = Color.YELLOW
var _velocity: Vector2 = Vector2(0, -50)
var _lifetime: float = 0.7
var _elapsed: float = 0.0


func setup(pos: Vector2, value: int, col: Color = Color.YELLOW) -> void:
	global_position = pos
	text = str(value)
	text_color = col
	z_index = 5


func _process(delta: float) -> void:
	_elapsed += delta
	position += _velocity * delta
	_velocity *= 0.95
	modulate.a = 1.0 - (_elapsed / _lifetime)
	if _elapsed >= _lifetime:
		queue_free()
	queue_redraw()


func _draw() -> void:
	var font := ThemeDB.fallback_font
	var size := 12
	draw_string_outline(font, Vector2(-12, 0), text, HORIZONTAL_ALIGNMENT_CENTER, -1, size, 3, Color.BLACK)
	draw_string(font, Vector2(-12, 0), text, HORIZONTAL_ALIGNMENT_CENTER, -1, size, text_color)
