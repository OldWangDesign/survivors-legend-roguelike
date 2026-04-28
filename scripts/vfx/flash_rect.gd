extends ColorRect

var _duration: float = 0.1
var _elapsed: float = 0.0
var _initial_alpha: float = 0.3
const MAX_LIFETIME := 3.0


func _ready() -> void:
	_duration = get_meta("fade_duration", 0.1)
	_initial_alpha = get_meta("initial_alpha", 0.3)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= _duration or _elapsed >= MAX_LIFETIME:
		var parent := get_parent()
		if parent:
			parent.queue_free()
		else:
			queue_free()
		return
	color.a = _initial_alpha * (1.0 - _elapsed / _duration)
