extends WeaponBase

var _orbit_angle: float = 0.0
var _time: float = 0.0
var _shield_hp: float = 100.0
var _dmg_tick: float = 0.0
const BOOK_COUNT := 12
const SHIELD_MAX := 100.0
const DMG_INTERVAL := 0.1


func _ready() -> void:
	weapon_type = GameData.WeaponType.DIVINE_APOCALYPSE
	z_index = 3


func attack() -> void:
	pass


func _process(delta: float) -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return

	_time += delta
	var spin_speed := 2.5 + weapon_level * 0.15
	_orbit_angle += delta * spin_speed
	if _orbit_angle > TAU:
		_orbit_angle -= TAU

	var area: float = GameData.get_weapon_area(weapon_type, weapon_level)
	var dmg := get_damage()

	_dmg_tick += delta
	if _dmg_tick >= DMG_INTERVAL:
		_dmg_tick -= DMG_INTERVAL
		for i in range(BOOK_COUNT):
			var angle := _orbit_angle + (TAU / BOOK_COUNT) * float(i)
			var book_pos := player.global_position + Vector2(cos(angle), sin(angle)) * area
			for enemy in SpatialGrid.get_in_range(book_pos, 28.0):
				enemy.take_damage(dmg * DMG_INTERVAL * 2.0)

	if _shield_hp < SHIELD_MAX:
		_shield_hp = minf(_shield_hp + delta * 5.0, SHIELD_MAX)

	var shield_area := area * 0.7
	for enemy in SpatialGrid.get_in_range(player.global_position, shield_area):
		if enemy.has_method("apply_knockback"):
			var push_dir: Vector2 = (enemy.global_position - player.global_position).normalized()
			enemy.apply_knockback(push_dir * 150.0)

	queue_redraw()


func take_shield_damage(amount: float) -> float:
	if _shield_hp <= 0:
		return amount
	var absorbed := minf(amount, _shield_hp)
	_shield_hp -= absorbed
	return amount - absorbed


func _draw() -> void:
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return
	var area: float = GameData.get_weapon_area(weapon_type, weapon_level)
	var center := player.global_position - global_position

	var shield_ratio := _shield_hp / SHIELD_MAX
	if shield_ratio > 0:
		var shield_r := area * 0.7
		draw_circle(center, shield_r, Color(1.0, 0.9, 0.4, 0.08 * shield_ratio))
		draw_arc(center, shield_r, 0, TAU * shield_ratio, 24, Color(1.0, 0.85, 0.3, 0.3), 2.5)

	draw_arc(center, area, 0, TAU, 24, Color(1.0, 0.9, 0.4, 0.1), 1.5)

	for i in range(BOOK_COUNT):
		var angle := _orbit_angle + (TAU / BOOK_COUNT) * float(i)
		var offset := Vector2(cos(angle), sin(angle)) * area
		var pos := center + offset

		draw_circle(pos, 14.0, Color(1.0, 0.9, 0.4, 0.1))

		draw_rect(Rect2(pos.x - 7, pos.y - 9, 14, 18), Color(0.96, 0.92, 0.75))
		draw_rect(Rect2(pos.x - 7, pos.y - 9, 14, 18), Color(0.85, 0.7, 0.2), false, 2.0)

		draw_circle(pos, 4.0, Color(1.0, 0.95, 0.7, 0.7))
		draw_circle(pos, 2.0, Color(1, 1, 1, 0.9))
