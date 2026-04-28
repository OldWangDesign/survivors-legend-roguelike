extends WeaponBase


func _ready() -> void:
	weapon_type = GameData.WeaponType.INFERNO_STORM
	z_index = 3


func attack() -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		start_cooldown()
		return

	var area: float = GameData.get_weapon_area(weapon_type, weapon_level)
	var count := 8 + weapon_level * 2
	for i in range(count):
		var offset := Vector2(randf_range(-area, area), randf_range(-area, area))
		var target := player.global_position + offset
		_spawn_meteor(target, area * 0.4)

	play_weapon_sound("weapon_meteor")
	VfxPool.screen_flash(Color(1.0, 0.4, 0.0, 0.15), 0.08)
	if GameData.player_ref:
		var gm := get_tree().current_scene
		if gm and gm.has_method("shake_camera"):
			gm.shake_camera(8.0)
	start_cooldown()


func _spawn_meteor(target: Vector2, radius: float) -> void:
	var m := Node2D.new()
	m.set_script(preload("res://scripts/weapons/inferno_strike.gd"))
	var scene := get_scene()
	if scene == null:
		return
	scene.add_child(m)
	m.setup(target, get_damage(), radius, self)
