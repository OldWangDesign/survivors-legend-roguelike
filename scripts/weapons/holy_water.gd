extends WeaponBase


func _ready() -> void:
	weapon_type = GameData.WeaponType.HOLY_WATER


func attack() -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		start_cooldown()
		return

	var area: float = GameData.get_weapon_area(weapon_type, weapon_level) * player.area_mult
	var dmg := get_damage()
	var duration := 3.0 + weapon_level * 0.3

	var offset := Vector2(randf_range(-150, 150), randf_range(-150, 150))
	var zone_pos := player.global_position + offset

	var zone := Node2D.new()
	zone.set_script(preload("res://scripts/weapons/holy_water_zone.gd"))
	get_scene().add_child(zone)
	zone.global_position = zone_pos
	zone.setup(area, dmg, duration)

	play_weapon_sound()
	start_cooldown()
