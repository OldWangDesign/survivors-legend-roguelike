extends WeaponBase


func _ready() -> void:
	weapon_type = GameData.WeaponType.VOID_DEVOUR
	z_index = 3


func attack() -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		start_cooldown()
		return

	var count := 8
	var enemies := get_tree().get_nodes_in_group("enemies")

	for i in range(count):
		var target: Node2D = null
		if enemies.size() > 0:
			target = enemies[randi() % enemies.size()]
		var angle := (TAU / count) * float(i) + randf_range(-0.3, 0.3)
		var dir := Vector2(cos(angle), sin(angle))
		_fire_void_bolt(player.global_position, dir, target)

	play_weapon_sound("weapon_fire")
	start_cooldown()


func _fire_void_bolt(pos: Vector2, dir: Vector2, target: Node2D) -> void:
	var bolt := Node2D.new()
	bolt.set_script(preload("res://scripts/weapons/void_bolt.gd"))
	var scene := get_scene()
	if scene == null:
		return
	scene.add_child(bolt)
	bolt.setup(pos, dir, get_damage(), target, self)
