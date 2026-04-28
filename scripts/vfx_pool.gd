extends Node

## Lightweight VFX pool — reuses Node2D draw‐calls instead of instancing.
## All public helpers are static‐style: call VfxPool.xxx() from anywhere.

const MAX_PARTICLES := 200
var _particles: Array = []
var _trail_nodes: Array = []


func _get_scene() -> Node:
	var scene := get_tree().current_scene
	if scene == null:
		return null
	return scene


func _get_budget() -> int:
	var enemies := get_tree().get_nodes_in_group("enemies").size()
	if enemies > 50:
		return MAX_PARTICLES / 2
	return MAX_PARTICLES


# ============ HIT FLASH (star burst at hit position) ============

func hit_flash(pos: Vector2, color: Color = Color.WHITE, size: float = 12.0) -> void:
	var scene := _get_scene()
	if scene == null or _particles.size() >= _get_budget():
		return
	var fx := Node2D.new()
	fx.set_script(_HitFlashScript)
	fx.global_position = pos
	fx.set_meta("fx_color", color)
	fx.set_meta("fx_size", size)
	fx.z_index = 10
	scene.add_child(fx)
	_particles.append(fx)


# ============ SCREEN FLASH ============

func screen_flash(color: Color = Color(1, 1, 1, 0.3), duration: float = 0.08) -> void:
	var scene := _get_scene()
	if scene == null:
		return
	var layer := CanvasLayer.new()
	layer.layer = 100
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	layer.set_meta("_flash_created_ms", Time.get_ticks_msec())
	var rect := ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(rect)
	scene.add_child(layer)
	get_tree().create_timer(duration, true).timeout.connect(
		func() -> void:
			if is_instance_valid(layer):
				layer.queue_free()
	)


# ============ SPARK BURST (multiple small particles) ============

func spark_burst(pos: Vector2, count: int, color: Color, spread: float = 80.0, lifetime: float = 0.3) -> void:
	var scene := _get_scene()
	if scene == null:
		return
	var budget := _get_budget()
	for i in range(mini(count, budget - _particles.size())):
		var fx := Node2D.new()
		fx.set_script(_SparkScript)
		fx.global_position = pos
		var angle := randf() * TAU
		var spd := randf_range(spread * 0.4, spread)
		fx.set_meta("vel", Vector2(cos(angle), sin(angle)) * spd)
		fx.set_meta("fx_color", color)
		fx.set_meta("lifetime", lifetime)
		fx.set_meta("max_life", lifetime)
		fx.z_index = 8
		scene.add_child(fx)
		_particles.append(fx)


# ============ RING WAVE (expanding ring) ============

func ring_wave(pos: Vector2, color: Color, max_radius: float = 60.0, duration: float = 0.3, width: float = 3.0) -> void:
	var scene := _get_scene()
	if scene == null or _particles.size() >= _get_budget():
		return
	var fx := Node2D.new()
	fx.set_script(_RingScript)
	fx.global_position = pos
	fx.set_meta("fx_color", color)
	fx.set_meta("max_radius", max_radius)
	fx.set_meta("duration", duration)
	fx.set_meta("width", width)
	fx.z_index = 7
	scene.add_child(fx)
	_particles.append(fx)


# ============ TRAIL ATTACH (attach trail to a moving node) ============

func trail_attach(target: Node2D, color: Color, length: int = 8, width: float = 4.0) -> Node2D:
	var scene := _get_scene()
	if scene == null:
		return null
	var trail := Node2D.new()
	trail.set_script(_TrailScript)
	trail.set_meta("target", target)
	trail.set_meta("trail_color", color)
	trail.set_meta("trail_length", length)
	trail.set_meta("trail_width", width)
	trail.z_index = 5
	scene.add_child(trail)
	_trail_nodes.append(trail)
	return trail


# ============ LINE ATTACK (boss ground attack warning + hit) ============

func line_attack(pos: Vector2, dir: Vector2, length: float, width: float, color: Color, duration: float = 1.0) -> void:
	var scene := _get_scene()
	if scene == null or _particles.size() >= _get_budget():
		return
	var fx := Node2D.new()
	fx.set_script(_LineAttackScript)
	fx.global_position = pos
	fx.set_meta("fx_dir", dir.normalized())
	fx.set_meta("fx_length", length)
	fx.set_meta("fx_width", width)
	fx.set_meta("fx_color", color)
	fx.set_meta("fx_duration", duration)
	fx.z_index = 6
	scene.add_child(fx)
	_particles.append(fx)


# ============ FLOATING TEXT (enhanced damage numbers) ============

func float_text(pos: Vector2, text: String, color: Color, size: float = 16.0, is_crit: bool = false) -> void:
	var scene := _get_scene()
	if scene == null:
		return
	var fx := Node2D.new()
	fx.set_script(_FloatTextScript)
	fx.global_position = pos + Vector2(randf_range(-8, 8), -12)
	fx.set_meta("text", text)
	fx.set_meta("fx_color", color)
	fx.set_meta("font_size", size)
	fx.set_meta("is_crit", is_crit)
	fx.z_index = 20
	scene.add_child(fx)


# ============ CLEANUP ============

func _process(_delta: float) -> void:
	var valid_p: Array = []
	for p in _particles:
		if is_instance_valid(p) and p.is_inside_tree():
			valid_p.append(p)
	_particles = valid_p
	var valid_t: Array = []
	for t in _trail_nodes:
		if is_instance_valid(t) and t.is_inside_tree():
			valid_t.append(t)
	_trail_nodes = valid_t
	_cleanup_stale_flash_layers()


func _cleanup_stale_flash_layers() -> void:
	var scene := _get_scene()
	if scene == null:
		return
	var now := Time.get_ticks_msec()
	for child in scene.get_children():
		if child is CanvasLayer and child.has_meta("_flash_created_ms"):
			var age: int = now - (child.get_meta("_flash_created_ms") as int)
			if age > 3000:
				print("[VFX] Force-removing stale flash overlay (age=%dms)" % age)
				child.queue_free()


# ============ EMBEDDED SCRIPTS ============

var _HitFlashScript: GDScript = preload("res://scripts/vfx/hit_flash.gd")
var _SparkScript: GDScript = preload("res://scripts/vfx/spark.gd")
var _RingScript: GDScript = preload("res://scripts/vfx/ring_wave.gd")
var _TrailScript: GDScript = preload("res://scripts/vfx/trail.gd")
var _FloatTextScript: GDScript = preload("res://scripts/vfx/float_text.gd")
var _LineAttackScript: GDScript = load("res://scripts/vfx/line_attack.gd")
