extends Node2D

var xp_value: int = 1
var _being_attracted: bool = false
var _attract_target: Vector2 = Vector2.ZERO
var _attract_speed: float = 0.0
var _bob_offset: float = 0.0
var _sprite: Sprite2D


func _ready() -> void:
	add_to_group("gems")
	_bob_offset = randf() * TAU

	_sprite = Sprite2D.new()
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_sprite)
	_update_sprite()


func _update_sprite() -> void:
	var tex_key: String
	var gem_scale: float
	if xp_value >= 20:
		tex_key = "gem_large"
		gem_scale = 1.8
	elif xp_value >= 5:
		tex_key = "gem_medium"
		gem_scale = 1.3
	else:
		tex_key = "gem_small"
		gem_scale = 1.0
	var tex = GameData.sprites.get(tex_key)
	if tex:
		_sprite.texture = tex
	_sprite.scale = Vector2.ONE * gem_scale


func start_attract(target: Vector2) -> void:
	_being_attracted = true
	_attract_target = target


func _physics_process(delta: float) -> void:
	if _being_attracted:
		_attract_speed = minf(_attract_speed + 800.0 * delta, 600.0)
		var dir := (_attract_target - global_position).normalized()
		global_position += dir * _attract_speed * delta
	elif _attract_speed > 0:
		_attract_speed = maxf(_attract_speed - 300.0 * delta, 0.0)
	_being_attracted = false

	var bob := sin(Time.get_ticks_msec() / 300.0 + _bob_offset) * 2.0
	_sprite.position.y = bob
