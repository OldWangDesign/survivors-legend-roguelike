extends WeaponBase

const MAX_RANGE := 250.0


func _ready() -> void:
	weapon_type = GameData.WeaponType.CROSS


func attack() -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		start_cooldown()
		return

	var count := 1 + weapon_level / 3
	for i in range(count):
		var dir: Vector2 = player.facing
		if count > 1:
			var spread := deg_to_rad(20.0) * (i - count / 2.0)
			dir = dir.rotated(spread)
		_launch(player.global_position, dir)

	play_weapon_sound()
	start_cooldown()


func _launch(pos: Vector2, dir: Vector2) -> void:
	var boomerang := Node2D.new()
	boomerang.set_script(preload("res://scripts/weapons/cross_projectile.gd"))
	get_scene().add_child(boomerang)
	boomerang.global_position = pos
	var range_mult := 1.0 + weapon_level * 0.15
	boomerang.setup(dir, 350.0, get_damage(), MAX_RANGE * range_mult)
