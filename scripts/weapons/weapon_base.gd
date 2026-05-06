class_name WeaponBase
extends Node2D

var weapon_type: int = -1
var weapon_level: int = 1
var cooldown_timer: float = 0.0
var can_attack: bool = true


func get_scene() -> Node:
	var tree := get_tree()
	if tree == null:
		return null
	return tree.current_scene


func _physics_process(delta: float) -> void:
	if cooldown_timer > 0:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			can_attack = true
	if can_attack:
		attack()


func attack() -> void:
	pass


func set_weapon_level(new_level: int) -> void:
	weapon_level = new_level


func get_damage() -> int:
	var player := GameData.player_ref
	var base_dmg := GameData.get_weapon_damage(weapon_type, weapon_level)
	if player:
		var mult: float = player.get_effective_damage_mult() if player.has_method("get_effective_damage_mult") else player.damage_mult
		return int(base_dmg * mult)
	return base_dmg


func get_cooldown() -> float:
	var player := GameData.player_ref
	var base_cd := GameData.get_weapon_cooldown(weapon_type, weapon_level)
	if player:
		var mult: float = player.get_effective_cooldown_mult() if player.has_method("get_effective_cooldown_mult") else player.cooldown_mult
		return base_cd * mult
	return base_cd


func start_cooldown() -> void:
	can_attack = false
	cooldown_timer = get_cooldown()


func get_cooldown_percent() -> float:
	if can_attack or cooldown_timer <= 0:
		return 0.0
	var total := get_cooldown()
	if total <= 0:
		return 0.0
	return clampf(cooldown_timer / total, 0.0, 1.0)


func play_weapon_sound(sound_name: String = "weapon_fire") -> void:
	AudioManager.play(sound_name)


func get_enemies_in_range(center: Vector2, range_val: float) -> Array:
	return SpatialGrid.get_in_range(center, range_val)


func get_nearest_enemy(from: Vector2, max_range: float = 999999.0) -> Node2D:
	return SpatialGrid.get_nearest(from, max_range)


func spawn_damage_number(pos: Vector2, dmg: int) -> void:
	var is_crit := dmg >= 20
	var col := Color.GOLD if is_crit else Color(1, 0.9, 0.7)
	VfxPool.float_text(pos + Vector2(randf_range(-5, 5), -10), str(dmg), col, 16.0, is_crit)
