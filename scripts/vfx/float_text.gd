extends Node2D

var _text: String
var _color: Color
var _font_size: float
var _is_crit: bool
var _timer: float = 0.6
var _max_time: float = 0.6
var _vel: Vector2
var _label: Label


func _ready() -> void:
	_text = get_meta("text", "0")
	_color = get_meta("fx_color", Color.WHITE)
	_font_size = get_meta("font_size", 16.0)
	_is_crit = get_meta("is_crit", false)
	_vel = Vector2(randf_range(-15, 15), -60)
	if _is_crit:
		_font_size *= 1.6
		_timer = 0.8
		_max_time = 0.8
		_vel.y = -80

	_label = Label.new()
	_label.text = _text
	_label.add_theme_font_size_override("font_size", int(_font_size))
	_label.add_theme_color_override("font_color", _color)
	_label.add_theme_constant_override("outline_size", 3)
	_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_label.add_theme_constant_override("shadow_offset_x", 1)
	_label.add_theme_constant_override("shadow_offset_y", 1)
	_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.position = Vector2(-100, -int(_font_size) / 2)
	_label.size = Vector2(200, 0)
	add_child(_label)


func _process(delta: float) -> void:
	_timer -= delta
	if _timer <= 0:
		queue_free()
		return
	position += _vel * delta
	_vel.y += 80.0 * delta
	if _is_crit:
		_vel.y += 40.0 * delta

	var t := _timer / _max_time
	var alpha: float = t if t > 0.3 else t / 0.3

	var s := 1.0
	if _is_crit:
		var pop := 1.0 - t
		if pop < 0.15:
			s = 1.0 + pop / 0.15 * 0.4
		else:
			s = 1.4 - (pop - 0.15) * 0.47

	_label.scale = Vector2(s, s)
	_label.modulate.a = alpha
	if _is_crit:
		_label.add_theme_color_override("font_color", _color.lerp(Color.WHITE, (1.0 - t) * 0.3))
