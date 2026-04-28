extends WeaponBase


func _ready() -> void:
	weapon_type = GameData.WeaponType.METEOR


func attack() -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		start_cooldown()
		return

	var enemies := get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		start_cooldown()
		return

	var count := 1 + weapon_level / 3
	var shuffled := enemies.duplicate()
	shuffled.shuffle()
	var targets: Array[Vector2] = []
	for i in range(mini(count, shuffled.size())):
		targets.append(shuffled[i].global_position)

	for target_pos in targets:
		_spawn_meteor(target_pos)

	play_weapon_sound("weapon_meteor")
	start_cooldown()


func _find_clusters(enemies: Array[Node], count: int) -> Array[Vector2]:
	var targets: Array[Vector2] = []
	var sorted := enemies.duplicate()
	sorted.shuffle()
	for i in range(mini(count, sorted.size())):
		targets.append(sorted[i].global_position)
	return targets


func _spawn_meteor(target: Vector2) -> void:
	var m := Node2D.new()
	m.set_script(preload("res://scripts/weapons/meteor_strike.gd"))
	get_scene().add_child(m)
	var radius := GameData.get_weapon_area(weapon_type, weapon_level)
	m.setup(target, get_damage(), radius)
