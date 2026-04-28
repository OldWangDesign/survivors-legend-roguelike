extends WeaponBase

var _trail_timer: float = 0.0
const DROP_INTERVAL := 0.5


func _ready() -> void:
	weapon_type = GameData.WeaponType.POISON_CLOUD


func attack() -> void:
	pass


func _process(delta: float) -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return

	_trail_timer += delta
	if _trail_timer >= DROP_INTERVAL:
		_trail_timer -= DROP_INTERVAL
		_drop_cloud(player.global_position)


func _drop_cloud(pos: Vector2) -> void:
	var cloud := Node2D.new()
	cloud.set_script(preload("res://scripts/weapons/poison_cloud_zone.gd"))
	get_scene().add_child(cloud)
	cloud.global_position = pos
	var data: Dictionary = GameData.WEAPON_DATA[weapon_type]
	var duration: float = data.get("base_duration", 5.0) + weapon_level * 0.5
	var radius := GameData.get_weapon_area(weapon_type, weapon_level)
	cloud.setup(get_damage(), radius, duration)
