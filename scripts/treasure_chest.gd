extends Node2D

enum ChestRarity { COMMON, RARE, EPIC }
enum RewardType { SMALL_HEAL, BIG_HEAL, FULL_HEAL, XP_BONUS, SKILL_UP, BOMB, MAGNET, SHIELD_BUFF, SPEED_BUFF, DAMAGE_BUFF, XP_VACUUM }

var rarity: int = ChestRarity.COMMON
var _bob_offset: float = 0.0
var _opened: bool = false
var _lifetime: float = 0.0
const MAX_LIFETIME := 30.0
const CHEST_SIZE := 12.0
const COLLECT_RANGE := 35.0

var _glow_time: float = 0.0

const RARITY_COLORS: Dictionary = {
	ChestRarity.COMMON: Color(0.72, 0.53, 0.25),
	ChestRarity.RARE: Color(0.6, 0.7, 0.85),
	ChestRarity.EPIC: Color(1.0, 0.84, 0.0),
}

const RARITY_WEIGHTS: Dictionary = {
	ChestRarity.COMMON: 65,
	ChestRarity.RARE: 25,
	ChestRarity.EPIC: 10,
}

const REWARD_TABLE: Dictionary = {
	ChestRarity.COMMON: [
		{"type": RewardType.SMALL_HEAL, "weight": 30},
		{"type": RewardType.XP_BONUS, "weight": 30},
		{"type": RewardType.SPEED_BUFF, "weight": 15},
		{"type": RewardType.MAGNET, "weight": 10},
		{"type": RewardType.XP_VACUUM, "weight": 15},
	],
	ChestRarity.RARE: [
		{"type": RewardType.BIG_HEAL, "weight": 22},
		{"type": RewardType.XP_BONUS, "weight": 18},
		{"type": RewardType.SKILL_UP, "weight": 18},
		{"type": RewardType.BOMB, "weight": 12},
		{"type": RewardType.DAMAGE_BUFF, "weight": 10},
		{"type": RewardType.SHIELD_BUFF, "weight": 8},
		{"type": RewardType.XP_VACUUM, "weight": 12},
	],
	ChestRarity.EPIC: [
		{"type": RewardType.FULL_HEAL, "weight": 12},
		{"type": RewardType.SKILL_UP, "weight": 28},
		{"type": RewardType.BOMB, "weight": 18},
		{"type": RewardType.DAMAGE_BUFF, "weight": 14},
		{"type": RewardType.SHIELD_BUFF, "weight": 8},
		{"type": RewardType.MAGNET, "weight": 8},
		{"type": RewardType.XP_VACUUM, "weight": 12},
	],
}

const REWARD_NAMES: Dictionary = {
	RewardType.SMALL_HEAL: "小血包 +25HP",
	RewardType.BIG_HEAL: "大血包 +60HP",
	RewardType.FULL_HEAL: "满血恢复",
	RewardType.XP_BONUS: "经验奖励",
	RewardType.SKILL_UP: "技能升级",
	RewardType.BOMB: "全屏炸弹",
	RewardType.MAGNET: "经验磁铁",
	RewardType.SHIELD_BUFF: "护盾 5秒",
	RewardType.SPEED_BUFF: "加速 8秒",
	RewardType.DAMAGE_BUFF: "攻击+20% 10秒",
	RewardType.XP_VACUUM: "经验收割",
}

const REWARD_COLORS: Dictionary = {
	RewardType.SMALL_HEAL: Color(0.3, 0.9, 0.3),
	RewardType.BIG_HEAL: Color(0.2, 1.0, 0.4),
	RewardType.FULL_HEAL: Color(0.0, 1.0, 0.5),
	RewardType.XP_BONUS: Color(0.4, 0.7, 1.0),
	RewardType.SKILL_UP: Color(1.0, 0.84, 0.0),
	RewardType.BOMB: Color(1.0, 0.3, 0.2),
	RewardType.MAGNET: Color(0.8, 0.5, 1.0),
	RewardType.SHIELD_BUFF: Color(0.3, 0.6, 1.0),
	RewardType.SPEED_BUFF: Color(0.2, 0.9, 0.8),
	RewardType.DAMAGE_BUFF: Color(1.0, 0.5, 0.2),
	RewardType.XP_VACUUM: Color(0.3, 1.0, 0.9),
}


func _ready() -> void:
	add_to_group("chests")
	_bob_offset = randf() * TAU
	z_index = 3


func setup_random() -> void:
	rarity = _pick_weighted(RARITY_WEIGHTS)


func _pick_weighted(weights: Dictionary) -> int:
	var total: int = 0
	for w in weights.values():
		total += w
	var roll: int = randi() % total
	var acc: int = 0
	for key in weights.keys():
		acc += weights[key]
		if roll < acc:
			return key
	return weights.keys()[0]


func _physics_process(delta: float) -> void:
	if _opened:
		return
	_lifetime += delta
	_glow_time += delta
	if _lifetime >= MAX_LIFETIME:
		_fade_out()
		return
	queue_redraw()


func _fade_out() -> void:
	_opened = true
	remove_from_group("chests")
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.5)
	tw.tween_callback(queue_free)


func open(player_node: CharacterBody2D) -> void:
	if _opened:
		return
	_opened = true
	remove_from_group("chests")

	var reward_type: int = _roll_reward()
	var detail: String = _apply_reward(reward_type, player_node)

	var reward_name: String = REWARD_NAMES.get(reward_type, "???")
	var reward_color: Color = REWARD_COLORS.get(reward_type, Color.WHITE)
	var chest_color: Color = RARITY_COLORS.get(rarity, Color.WHITE)

	var rarity_label: String
	match rarity:
		ChestRarity.COMMON: rarity_label = "[普通]"
		ChestRarity.RARE: rarity_label = "[稀有]"
		ChestRarity.EPIC: rarity_label = "[史诗]"
		_: rarity_label = "[宝箱]"

	var display_text: String = reward_name
	if detail != "":
		display_text = detail

	AudioManager.play("chest_open")
	VfxPool.spark_burst(global_position, 12, chest_color, 120.0, 0.5)
	VfxPool.ring_wave(global_position, chest_color, 60.0, 0.3)
	VfxPool.float_text(global_position + Vector2(0, -35), rarity_label, chest_color, 12.0, false)
	VfxPool.float_text(global_position + Vector2(0, 8), display_text, reward_color, 16.0, rarity >= ChestRarity.RARE)

	var tw := create_tween()
	tw.tween_property(self, "scale", Vector2(1.5, 1.5), 0.1)
	tw.tween_property(self, "modulate:a", 0.0, 0.25)
	tw.tween_callback(queue_free)


func _roll_reward() -> int:
	var table: Array = REWARD_TABLE.get(rarity, REWARD_TABLE[ChestRarity.COMMON])
	var total: int = 0
	for entry in table:
		total += entry["weight"]
	var roll: int = randi() % total
	var acc: int = 0
	for entry in table:
		acc += entry["weight"]
		if roll < acc:
			return entry["type"]
	return RewardType.SMALL_HEAL


func _apply_reward(reward_type: int, p: CharacterBody2D) -> String:
	match reward_type:
		RewardType.SMALL_HEAL:
			p.heal(25)
			return ""
		RewardType.BIG_HEAL:
			p.heal(60)
			return ""
		RewardType.FULL_HEAL:
			p.heal(p.max_health)
			VfxPool.screen_flash(Color(0.2, 1.0, 0.3, 0.15), 0.12)
			return ""
		RewardType.XP_BONUS:
			var bonus: int = 10 + p.level * 3
			p.add_xp(bonus)
			return "经验 +" + str(bonus)
		RewardType.SKILL_UP:
			return _upgrade_random_weapon(p)
		RewardType.BOMB:
			return _bomb_effect()
		RewardType.MAGNET:
			_magnet_effect(p)
			return ""
		RewardType.SHIELD_BUFF:
			p.invincible = true
			p._invincible_timer = 5.0
			VfxPool.ring_wave(p.global_position, Color(0.3, 0.6, 1.0), 50.0, 0.3)
			return ""
		RewardType.SPEED_BUFF:
			_apply_temp_buff(p, "speed_mult", 0.5, 8.0)
			return ""
		RewardType.DAMAGE_BUFF:
			_apply_temp_buff(p, "damage_mult", 0.2, 10.0)
			return ""
		RewardType.XP_VACUUM:
			return _vacuum_xp_effect(p)
	return ""


func _upgrade_random_weapon(p: CharacterBody2D) -> String:
	var upgradable: Array = []
	for w in p.weapons:
		if w["level"] < 8:
			upgradable.append(w)
	if upgradable.is_empty():
		p.add_xp(30 + p.level * 5)
		return "技能已满 → 额外经验!"
	var chosen: Dictionary = upgradable[randi() % upgradable.size()]
	chosen["level"] += 1
	chosen["node"].set_weapon_level(chosen["level"])
	var wname: String = GameData.WEAPON_DATA[chosen["type"]].get("name", "?")
	AudioManager.play("level_up")
	return wname + " Lv." + str(chosen["level"])


func _bomb_effect() -> String:
	var enemies := get_tree().get_nodes_in_group("enemies")
	var kill_count: int = 0
	for e in enemies:
		if not is_instance_valid(e):
			continue
		if global_position.distance_to(e.global_position) < 500.0:
			e.take_damage(99999.0)
			kill_count += 1
	VfxPool.screen_flash(Color(1.0, 0.4, 0.2, 0.25), 0.15)
	var scene := get_tree().current_scene
	if scene and scene.has_method("shake_camera"):
		scene.shake_camera(6.0, 0.2)
	return "BOOM! x" + str(kill_count)


func _magnet_effect(p: CharacterBody2D) -> void:
	var gems := get_tree().get_nodes_in_group("gems")
	for gem in gems:
		if is_instance_valid(gem):
			gem.start_attract(p.global_position)
	VfxPool.ring_wave(p.global_position, Color(0.8, 0.5, 1.0), 200.0, 0.4)


func _vacuum_xp_effect(p: CharacterBody2D) -> String:
	var gems := get_tree().get_nodes_in_group("gems")
	var total_xp: int = 0
	for gem in gems:
		if is_instance_valid(gem):
			total_xp += gem.xp_value
			VfxPool.spark_burst(gem.global_position, 3, Color(0.3, 1.0, 0.9), 40.0, 0.2)
			gem.queue_free()
	if total_xp > 0:
		p.add_xp(total_xp)
		AudioManager.play("xp_pickup")
	VfxPool.ring_wave(p.global_position, Color(0.3, 1.0, 0.9), 400.0, 0.5)
	VfxPool.screen_flash(Color(0.3, 1.0, 0.9, 0.1), 0.12)
	return "经验收割 +" + str(total_xp)


func _apply_temp_buff(p: CharacterBody2D, stat_name: String, amount: float, duration: float) -> void:
	var old_val: float = p.get(stat_name)
	p.set(stat_name, old_val + amount)
	var timer := get_tree().create_timer(duration)
	timer.timeout.connect(func() -> void:
		if is_instance_valid(p):
			var cur: float = p.get(stat_name)
			p.set(stat_name, cur - amount)
	)


func _draw() -> void:
	if _opened:
		return

	var c: Color = RARITY_COLORS.get(rarity, Color.WHITE)
	var bob: float = sin(Time.get_ticks_msec() / 300.0 + _bob_offset) * 2.0
	var glow_pulse: float = 0.3 + 0.2 * sin(_glow_time * 3.0)

	if rarity >= ChestRarity.RARE:
		var glow_c := c
		glow_c.a = glow_pulse * 0.4
		draw_circle(Vector2(0, bob), CHEST_SIZE * 1.5, glow_c)

	var cs := CHEST_SIZE
	var half := cs * 0.5

	draw_rect(Rect2(-cs, bob - half * 0.6, cs * 2, cs * 1.2), c.darkened(0.4))
	draw_rect(Rect2(-cs + 1, bob - half * 0.6 + 1, cs * 2 - 2, cs * 1.2 - 2), c.darkened(0.15))

	var lid_h := cs * 0.5
	draw_rect(Rect2(-cs - 1, bob - half * 0.6 - lid_h, cs * 2 + 2, lid_h), c.darkened(0.2))
	draw_rect(Rect2(-cs, bob - half * 0.6 - lid_h + 1, cs * 2, lid_h - 2), c)

	var lock_c := Color.YELLOW if rarity == ChestRarity.EPIC else Color(0.8, 0.8, 0.7) if rarity == ChestRarity.RARE else Color(0.6, 0.5, 0.3)
	draw_rect(Rect2(-3, bob - 3, 6, 6), lock_c)
	draw_rect(Rect2(-2, bob - 2, 4, 4), lock_c.lightened(0.3))

	var stripe_c := c.lightened(0.2)
	stripe_c.a = 0.4
	draw_rect(Rect2(-cs + 2, bob - half * 0.6 + 2, 3, cs * 1.2 - 4), stripe_c)
	draw_rect(Rect2(cs - 5, bob - half * 0.6 + 2, 3, cs * 1.2 - 4), stripe_c)

	if rarity == ChestRarity.EPIC:
		var star_alpha: float = 0.5 + 0.3 * sin(_glow_time * 5.0)
		var star_c := Color(1.0, 0.95, 0.5, star_alpha)
		for i in range(3):
			var angle: float = _glow_time * 2.0 + i * TAU / 3.0
			var sx: float = cos(angle) * (cs + 6)
			var sy: float = sin(angle) * (cs * 0.7 + 4) + bob
			draw_circle(Vector2(sx, sy), 2.0, star_c)

	var remaining := MAX_LIFETIME - _lifetime
	if remaining < 5.0:
		var blink: float = fmod(remaining * 4.0, 1.0)
		if blink < 0.5:
			modulate.a = 0.4
		else:
			modulate.a = 1.0
	else:
		modulate.a = 1.0
