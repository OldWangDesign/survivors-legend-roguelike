extends Control

var direction: Vector2 = Vector2.ZERO

var _active: bool = false
var _touch_index: int = -1
var _mouse_active: bool = false
var _base_center: Vector2 = Vector2.ZERO
var _knob_pos: Vector2 = Vector2.ZERO

const MAX_RADIUS := 64.0
const KNOB_RADIUS := 24.0
const DEAD_ZONE := 10.0
const BASE_COLOR := Color(0.3, 0.3, 0.3, 0.4)
const KNOB_COLOR := Color(0.9, 0.9, 0.9, 0.6)
const KNOB_ACTIVE_COLOR := Color(1.0, 1.0, 1.0, 0.8)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	z_index = 50


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_on_screen_touch(event as InputEventScreenTouch)
	elif event is InputEventScreenDrag:
		_on_screen_drag(event as InputEventScreenDrag)
	elif event is InputEventMouseButton:
		_on_mouse_button(event as InputEventMouseButton)
	elif event is InputEventMouseMotion:
		_on_mouse_motion(event as InputEventMouseMotion)


func _is_left_half(pos: Vector2) -> bool:
	return pos.x < get_viewport_rect().size.x * 0.5


# ── Touch ──

func _on_screen_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		if _active:
			return
		if not _is_left_half(event.position):
			return
		_active = true
		_touch_index = event.index
		_start(event.position)
	else:
		if event.index == _touch_index:
			_reset()


func _on_screen_drag(event: InputEventScreenDrag) -> void:
	if _active and event.index == _touch_index:
		_move(event.position)


# ── Mouse (PC testing) ──

func _on_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index != MOUSE_BUTTON_LEFT:
		return
	if event.pressed:
		if _active:
			return
		if not _is_left_half(event.position):
			return
		_active = true
		_mouse_active = true
		_start(event.position)
	else:
		if _mouse_active:
			_reset()


func _on_mouse_motion(event: InputEventMouseMotion) -> void:
	if _active and _mouse_active:
		_move(event.position)


# ── Shared logic ──

func _start(pos: Vector2) -> void:
	_base_center = pos
	_knob_pos = pos
	direction = Vector2.ZERO
	queue_redraw()


func _move(pos: Vector2) -> void:
	var offset: Vector2 = pos - _base_center
	var dist: float = offset.length()
	if dist > MAX_RADIUS:
		offset = offset.normalized() * MAX_RADIUS
	_knob_pos = _base_center + offset
	if dist < DEAD_ZONE:
		direction = Vector2.ZERO
	else:
		direction = offset.normalized() * clampf((dist - DEAD_ZONE) / (MAX_RADIUS - DEAD_ZONE), 0.0, 1.0)
	queue_redraw()


func _reset() -> void:
	_active = false
	_touch_index = -1
	_mouse_active = false
	direction = Vector2.ZERO
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_UNPAUSED or what == NOTIFICATION_PAUSED:
		if _active:
			_reset()


func _draw() -> void:
	if not _active:
		return
	draw_circle(_base_center, MAX_RADIUS, BASE_COLOR)
	draw_arc(_base_center, MAX_RADIUS, 0, TAU, 48, Color(0.5, 0.5, 0.5, 0.3), 2.0)
	var knob_c: Color = KNOB_ACTIVE_COLOR if direction.length() > 0.1 else KNOB_COLOR
	draw_circle(_knob_pos, KNOB_RADIUS, knob_c)
