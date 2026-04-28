extends WeaponBase

const SLOW_AMOUNT := 0.35
const SLOW_DURATION := 2.0


func _ready() -> void:
	weapon_type = GameData.WeaponType.FREEZE_RAY


func attack() -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		start_cooldown()
		return

	var dir: Vector2 = player.facing
	var count := 1 + weapon_level / 3
	for i in range(count):
		var spread := 0.0
		if count > 1:
			spread = deg_to_rad(15.0) * (i - count / 2.0)
		_fire(player.global_position, dir.rotated(spread))

	play_weapon_sound("weapon_freeze")
	start_cooldown()


func _fire(pos: Vector2, dir: Vector2) -> void:
	var ray := Node2D.new()
	ray.set_script(preload("res://scripts/weapons/freeze_ray_beam.gd"))
	get_scene().add_child(ray)
	ray.global_position = pos
	var slow_mult := SLOW_AMOUNT - weapon_level * 0.03
	ray.setup(dir, 400.0, get_damage(), slow_mult, SLOW_DURATION)
