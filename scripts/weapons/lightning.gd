extends WeaponBase

const CHAIN_RANGE := 100.0


func _ready() -> void:
	weapon_type = GameData.WeaponType.LIGHTNING


func attack() -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		start_cooldown()
		return

	var enemies := get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		start_cooldown()
		return

	var first := enemies[randi() % enemies.size()]
	var chain_count := 3 + weapon_level
	var dmg := get_damage()
	var hit: Array = []

	var current: Node2D = first
	for _i in range(chain_count):
		if not is_instance_valid(current):
			break
		current.take_damage(dmg)
		spawn_damage_number(current.global_position, dmg)
		hit.append(current)

		var next: Node2D = null
		var best_dist := CHAIN_RANGE * CHAIN_RANGE
		for e in get_tree().get_nodes_in_group("enemies"):
			if e in hit or not is_instance_valid(e):
				continue
			var d := current.global_position.distance_squared_to(e.global_position)
			if d < best_dist:
				best_dist = d
				next = e
		if next == null:
			break
		_draw_bolt(current.global_position, next.global_position)
		current = next

	play_weapon_sound("weapon_lightning")
	VfxPool.screen_flash(Color(0.8, 0.9, 1.0, 0.1), 0.04)
	start_cooldown()


func _draw_bolt(from: Vector2, to: Vector2) -> void:
	var bolt := Node2D.new()
	bolt.set_script(preload("res://scripts/weapons/lightning_bolt.gd"))
	var scene := get_scene()
	if scene == null:
		return
	scene.add_child(bolt)
	bolt.setup(from, to)
