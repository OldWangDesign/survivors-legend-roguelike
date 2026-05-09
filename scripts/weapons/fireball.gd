extends WeaponBase


func _ready() -> void:
	weapon_type = GameData.WeaponType.FIREBALL


func attack() -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		start_cooldown()
		return

	var proj_count := 1 + weapon_level / 4
	for i in range(proj_count):
		var angle := randf() * TAU
		var dir := Vector2(cos(angle), sin(angle))
		_fire(player.global_position, dir)
	play_weapon_sound("weapon_explode")
	start_cooldown()


func _fire(pos: Vector2, dir: Vector2) -> void:
	var scene := get_scene()
	if scene == null:
		return
	var proj := Node2D.new()
	proj.set_script(preload("res://scripts/weapons/projectile.gd"))
	scene.add_child(proj)
	proj.global_position = pos

	var area: float = GameData.get_weapon_area(weapon_type, weapon_level)
	var explosion_radius: float = area
	proj.setup(dir, 250.0, get_damage(), 1.5, Color.ORANGE_RED, 6.0)
	proj.set_meta("explode_radius", explosion_radius)
	proj.set_meta("explode_damage", get_damage())
	proj.set_meta("weapon_ref", self)

	proj.tree_exiting.connect(_on_proj_exit.bind(proj))


func _on_proj_exit(proj: Node2D) -> void:
	if not is_instance_valid(proj):
		return
	var pos := proj.global_position
	var radius: float = proj.get_meta("explode_radius", 60.0)
	var dmg: int = proj.get_meta("explode_damage", get_damage())
	call_deferred("_explode", pos, radius, dmg)


func _explode(pos: Vector2, radius: float, dmg: int) -> void:
	var scene := get_scene()
	if scene == null:
		return
	for enemy in SpatialGrid.get_in_range(pos, radius):
		if not is_instance_valid(enemy):
			continue
		enemy.take_damage(dmg)
		spawn_damage_number(enemy.global_position, dmg)

	var fx := Node2D.new()
	fx.set_script(preload("res://scripts/weapons/fireball_explosion.gd"))
	scene.add_child(fx)
	fx.global_position = pos
	fx.setup(radius)
