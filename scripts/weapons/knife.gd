extends WeaponBase


func _ready() -> void:
	weapon_type = GameData.WeaponType.KNIFE


func attack() -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		start_cooldown()
		return

	var proj_count := 1 + weapon_level / 3
	for i in range(proj_count):
		var dir: Vector2 = player.facing
		if proj_count > 1:
			var spread := deg_to_rad(8.0) * (i - proj_count / 2.0)
			dir = dir.rotated(spread)
		_fire(player.global_position, dir)

	play_weapon_sound()
	start_cooldown()


func _fire(pos: Vector2, dir: Vector2) -> void:
	var proj := Node2D.new()
	proj.set_script(preload("res://scripts/weapons/projectile.gd"))
	get_scene().add_child(proj)
	proj.global_position = pos
	proj.setup(dir, 500.0, get_damage(), 1.5, Color.SILVER, 4.0, true)
