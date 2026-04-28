extends Control

var _time: float = 0.0
var _stars: Array = []
var _ground_offset: float = 0.0

var _char_cache: Array = []

const ACTIVE_COUNT: int = 3
var _active_chars: Array = []
var _replace_timer: float = 0.0
const REPLACE_INTERVAL: float = 12.0

var _demo_enemies: Array = []
var _enemy_sprites_cache: Dictionary = {}
const MAX_ENEMIES: int = 12

var _weapon_effects: Array = []
var _death_particles: Array = []

const WEAPON_EVO_MAP: Dictionary = {
	0: 17, 1: 21, 2: 15, 4: 16, 5: 15,
	6: 18, 7: 18, 8: 17, 9: 20,
}
const EVO_NAMES: Dictionary = {
	15: "炼狱风暴", 16: "绝对零度", 17: "死神之镰",
	18: "雷神之锤", 19: "瘟疫之王", 20: "天启圣光", 21: "虚空吞噬",
}
const EVO_TRIGGER_AT: float = 5.0
const EVO_DURATION: float = 4.5
const STAR_COUNT := 50


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_cache_all_characters()
	_cache_enemy_sprites()
	_init_stars()
	_start_demo()


func _cache_all_characters() -> void:
	var original_style: String = GameData.current_style
	for char_id in GameData.CHARACTER_ORDER:
		var data: Dictionary = GameData.CHARACTER_DATA[char_id]
		GameData.switch_style(data["style"])
		var frames: Array = GameData.sprites.get("player", [])
		var cached_frames: Array = []
		for f in frames:
			cached_frames.append(f)
		_char_cache.append({
			"id": char_id, "name": data["name"],
			"weapon": data.get("weapon", 0),
			"frames": cached_frames, "style": data["style"],
		})
	GameData.switch_style(original_style)


func _cache_enemy_sprites() -> void:
	for t in ["bat", "skeleton", "zombie", "ghost"]:
		var sd = GameData.sprites.get(t)
		if sd is Array and sd.size() > 0:
			_enemy_sprites_cache[t] = sd.duplicate()
		elif sd is ImageTexture:
			_enemy_sprites_cache[t] = [sd]
	var bd = GameData.sprites.get("boss")
	if bd is Array and bd.size() > 0:
		_enemy_sprites_cache["boss"] = bd.duplicate()
	elif bd is ImageTexture:
		_enemy_sprites_cache["boss"] = [bd]


func _init_stars() -> void:
	var vp := get_viewport_rect().size
	if vp.x < 1: vp = Vector2(1152, 648)
	for i in range(STAR_COUNT):
		_stars.append({"pos": Vector2(randf() * vp.x, randf() * vp.y),
			"size": randf_range(1.0, 2.5), "speed": randf_range(0.3, 1.2),
			"phase": randf() * TAU})


func _make_active_char(char_idx: int, start_pos: Vector2 = Vector2(-1, -1)) -> Dictionary:
	var vp := get_viewport_rect().size
	if vp.x < 1: vp = Vector2(1152, 648)
	var margin: float = 60.0
	var pos: Vector2
	if start_pos.x >= 0:
		pos = start_pos
	else:
		pos = Vector2(randf_range(margin, vp.x - margin), randf_range(margin, vp.y - margin))
	var wt := Vector2(
		clampf(pos.x + randf_range(-60, 60), margin, vp.x - margin),
		clampf(pos.y + randf_range(-60, 60), margin, vp.y - margin))
	return {
		"idx": char_idx,
		"pos": pos,
		"vel": Vector2.ZERO,
		"wander_target": wt,
		"wander_timer": randf_range(1.5, 3.0),
		"facing_right": randf() > 0.5,
		"anim_frame": 0, "anim_timer": randf() * 0.3,
		"attack_timer": randf_range(0.3, 1.0),
		"evo_active": false, "evo_weapon": -1,
		"evo_timer": 0.0, "evo_flash": 0.0,
		"alive_time": 0.0,
		"fade_alpha": 0.0,
	}


func _start_demo() -> void:
	_active_chars.clear()
	_weapon_effects.clear()
	_demo_enemies.clear()
	var used: Array = []
	for i in range(ACTIVE_COUNT):
		var ci: int = randi() % _char_cache.size()
		while ci in used and _char_cache.size() > ACTIVE_COUNT:
			ci = randi() % _char_cache.size()
		used.append(ci)
		_active_chars.append(_make_active_char(ci))
	_replace_timer = REPLACE_INTERVAL
	for i in range(MAX_ENEMIES):
		_spawn_enemy()


func _spawn_enemy() -> void:
	var vp := get_viewport_rect().size
	if vp.x < 1: vp = Vector2(1152, 648)
	var t: String
	if randf() < 0.08 and _enemy_sprites_cache.has("boss"):
		t = "boss"
	else:
		var types: Array = ["bat", "skeleton", "zombie", "ghost"]
		t = types[randi() % types.size()]
	var side: int = randi() % 4
	var pos: Vector2
	match side:
		0: pos = Vector2(randf() * vp.x, -30)
		1: pos = Vector2(randf() * vp.x, vp.y + 30)
		2: pos = Vector2(-30, randf() * vp.y)
		_: pos = Vector2(vp.x + 30, randf() * vp.y)
	var is_boss: bool = t == "boss"
	_demo_enemies.append({"pos": pos, "type": t,
		"speed": 20.0 if is_boss else randf_range(30.0, 60.0),
		"hp": 12.0 if is_boss else 3.0, "anim_frame": 0,
		"anim_timer": randf() * 0.35,
		"size": 24.0 if is_boss else 12.0, "flash": 0.0})


func _get_nearest_char_pos(from: Vector2) -> Vector2:
	var best_d: float = 99999.0
	var best_p: Vector2 = from
	for ac in _active_chars:
		var d: float = from.distance_to(ac["pos"])
		if d < best_d:
			best_d = d
			best_p = ac["pos"]
	return best_p


func _process(delta: float) -> void:
	_time += delta
	var vp := get_viewport_rect().size
	if vp.x < 1: return
	_ground_offset = fmod(_ground_offset + delta * 15.0, 32.0)

	for ac in _active_chars:
		_update_one_char(ac, delta, vp)

	_update_enemies(delta)
	_update_weapon_effects(delta)
	_update_death_particles(delta)

	_replace_timer -= delta
	if _replace_timer <= 0:
		_replace_timer = REPLACE_INTERVAL
		_replace_one_char()

	queue_redraw()


func _replace_one_char() -> void:
	if _char_cache.size() <= ACTIVE_COUNT: return
	var ri: int = randi() % _active_chars.size()
	var old_pos: Vector2 = _active_chars[ri]["pos"]
	var used: Array = []
	for ac in _active_chars: used.append(ac["idx"])
	var new_ci: int = randi() % _char_cache.size()
	var attempts: int = 0
	while new_ci in used and attempts < 20:
		new_ci = randi() % _char_cache.size()
		attempts += 1
	_remove_char_effects(ri)
	_active_chars[ri] = _make_active_char(new_ci, old_pos)


func _remove_char_effects(char_slot: int) -> void:
	var keep: Array = []
	for fx in _weapon_effects:
		if fx.get("char_slot", -1) != char_slot:
			keep.append(fx)
	_weapon_effects = keep


func _update_one_char(ac: Dictionary, delta: float, vp: Vector2) -> void:
	ac["alive_time"] += delta
	ac["fade_alpha"] = clampf(ac["alive_time"] / 0.5, 0.0, 1.0)

	ac["wander_timer"] -= delta
	if ac["wander_timer"] <= 0:
		ac["wander_timer"] = randf_range(2.5, 5.0)
		var cur: Vector2 = ac["pos"]
		var wander_radius: float = 60.0
		var tx: float = cur.x + randf_range(-wander_radius, wander_radius)
		var ty: float = cur.y + randf_range(-wander_radius, wander_radius)
		ac["wander_target"] = Vector2(
			clampf(tx, 60.0, vp.x - 60.0),
			clampf(ty, 60.0, vp.y - 60.0))

	var dir: Vector2 = ac["wander_target"] - ac["pos"]
	if dir.length() > 2.0:
		ac["vel"] = (ac["vel"] as Vector2).lerp(dir.normalized() * 25.0, delta * 1.8)
	else:
		ac["vel"] = (ac["vel"] as Vector2).lerp(Vector2.ZERO, delta * 4.0)
	ac["pos"] += ac["vel"] * delta
	ac["pos"].x = clampf(ac["pos"].x, 40, vp.x - 40)
	ac["pos"].y = clampf(ac["pos"].y, 40, vp.y - 40)

	var vel: Vector2 = ac["vel"]
	if vel.length() > 5.0:
		if vel.x > 3.0: ac["facing_right"] = true
		elif vel.x < -3.0: ac["facing_right"] = false

	ac["anim_timer"] += delta
	if ac["anim_timer"] >= 0.3:
		ac["anim_timer"] -= 0.3
		ac["anim_frame"] = 1 - (ac["anim_frame"] as int)

	var slot: int = _active_chars.find(ac)
	var elapsed: float = ac["alive_time"]
	if not ac["evo_active"] and elapsed >= EVO_TRIGGER_AT:
		var cd: Dictionary = _char_cache[ac["idx"]]
		var wt: int = cd["weapon"]
		ac["evo_active"] = true
		ac["evo_weapon"] = WEAPON_EVO_MAP.get(wt, EVO_NAMES.keys()[randi() % EVO_NAMES.size()])
		ac["evo_timer"] = EVO_DURATION
		ac["evo_flash"] = 0.3
		_remove_char_effects(slot)

	if ac["evo_active"]:
		ac["evo_timer"] -= delta
		if ac["evo_flash"] > 0: ac["evo_flash"] -= delta
		if ac["evo_timer"] <= 0:
			ac["evo_active"] = false
			ac["evo_weapon"] = -1

	ac["attack_timer"] -= delta
	if ac["attack_timer"] <= 0:
		ac["attack_timer"] = randf_range(0.6, 1.2)
		_spawn_attack_for(ac, slot)


func _spawn_attack_for(ac: Dictionary, slot: int) -> void:
	var cd: Dictionary = _char_cache[ac["idx"]]
	var wt: int = cd["weapon"]
	var cp: Vector2 = ac["pos"]
	var fr: bool = ac["facing_right"]

	if ac["evo_active"] and ac["evo_weapon"] >= 0:
		_spawn_evo_effect_for(ac["evo_weapon"], cp, fr, slot)
		return

	match wt:
		0: _spawn_whip_effect_for(cp, fr, slot)
		1: _spawn_projectile_fx_for(cp, fr, Color.CYAN, 6.0, slot)
		2: _spawn_projectile_fx_for(cp, fr, Color.SILVER, 5.0, slot)
		3: _spawn_garlic_effect_for(cp, slot)
		4: _spawn_holy_water_effect_for(cp, slot)
		5: _spawn_fireball_effect_for(cp, fr, slot)
		6: _spawn_lightning_effect_for(cp, slot)
		7: _spawn_cross_effect_for(cp, fr, slot)
		8: _spawn_spin_blade_effect_for(slot)
		9: _spawn_bible_effect_for(slot)
		_: _spawn_whip_effect_for(cp, fr, slot)


# ============ Spawn functions ============

func _spawn_whip_effect_for(cp: Vector2, fr: bool, slot: int) -> void:
	var dir_f: float = 1.0 if fr else -1.0
	_weapon_effects.append({"type": "whip", "timer": 0.35, "max_timer": 0.35,
		"dir": dir_f, "char_slot": slot})
	_damage_enemies_in_range(cp + Vector2(dir_f * 50, 0), 60.0)


func _spawn_projectile_fx_for(cp: Vector2, fr: bool, col: Color, rad: float, slot: int) -> void:
	var ne: Dictionary = _find_nearest_enemy_to(cp)
	var dir: Vector2
	if not ne.is_empty():
		dir = cp.direction_to(ne["pos"]).rotated(randf_range(-0.2, 0.2))
	else:
		dir = Vector2.RIGHT if fr else Vector2.LEFT
	_weapon_effects.append({"type": "projectile", "pos": Vector2(cp),
		"vel": dir * 220.0, "color": col, "radius": rad,
		"timer": 1.5, "trail": [], "char_slot": slot})


func _spawn_garlic_effect_for(cp: Vector2, slot: int) -> void:
	_weapon_effects.append({"type": "garlic", "timer": 0.8, "max_timer": 0.8,
		"rune_angle": randf() * TAU, "spark_angle": randf() * TAU, "char_slot": slot})
	_damage_enemies_in_range(cp, 55.0)


func _spawn_holy_water_effect_for(cp: Vector2, slot: int) -> void:
	var offset := Vector2(randf_range(-50, 50), randf_range(-20, 20))
	_weapon_effects.append({"type": "holy_water", "pos": cp + offset,
		"timer": 2.5, "max_timer": 2.5, "area_r": 30.0, "char_slot": slot})


func _spawn_fireball_effect_for(cp: Vector2, fr: bool, slot: int) -> void:
	var ne: Dictionary = _find_nearest_enemy_to(cp)
	var dir: Vector2
	if not ne.is_empty():
		dir = cp.direction_to(ne["pos"])
	else:
		dir = Vector2.RIGHT if fr else Vector2.LEFT
	_weapon_effects.append({"type": "fireball", "pos": Vector2(cp),
		"vel": dir * 180.0, "timer": 1.5, "trail": [], "exploded": false,
		"color": Color.ORANGE_RED, "radius": 7.0, "char_slot": slot})


func _spawn_lightning_effect_for(cp: Vector2, slot: int) -> void:
	var sorted_e := _demo_enemies.duplicate()
	sorted_e.sort_custom(func(a, b): return cp.distance_to(a["pos"]) < cp.distance_to(b["pos"]))
	if sorted_e.is_empty(): return
	var targets: Array = []
	var start := Vector2(cp)
	for i in range(mini(3, sorted_e.size())):
		var e: Dictionary = sorted_e[i]
		if start.distance_to(e["pos"]) < 250:
			targets.append(Vector2(e["pos"]))
			e["hp"] -= 1.5
			e["flash"] = 0.12
			start = e["pos"]
	if targets.is_empty(): return
	var all_segs: Array = []
	var all_branches: Array = []
	var prev := Vector2(cp)
	for tgt in targets:
		var segs: Array = [prev]
		var seg_count: int = maxi(4, int(prev.distance_to(tgt) / 20.0))
		for s in range(1, seg_count):
			var ratio := float(s) / float(seg_count)
			var p := prev.lerp(tgt, ratio) + Vector2(randf_range(-15, 15), randf_range(-15, 15))
			segs.append(p)
		segs.append(tgt)
		all_segs.append_array(segs)
		if segs.size() > 3:
			var bi := randi() % (segs.size() - 2) + 1
			var bp: Vector2 = segs[bi]
			var bdir := Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
			all_branches.append([bp, bp + bdir * 25, bp + bdir * 40 + Vector2(randf_range(-10, 10), randf_range(-10, 10))])
		prev = tgt
	_weapon_effects.append({"type": "lightning", "segments": all_segs,
		"branches": all_branches, "origin": Vector2(cp),
		"target": targets[-1] if targets.size() > 0 else cp,
		"timer": 0.4, "max_timer": 0.4, "flicker": randf() * TAU, "char_slot": slot})


func _spawn_cross_effect_for(cp: Vector2, fr: bool, slot: int) -> void:
	var dir_f: float = 1.0 if fr else -1.0
	_weapon_effects.append({"type": "cross", "pos": Vector2(cp),
		"vel_x": dir_f * 200.0, "vel_y": -80.0, "timer": 2.0,
		"phase": 0, "origin": Vector2(cp), "trail": [],
		"rot_angle": 0.0, "char_slot": slot})


func _spawn_spin_blade_effect_for(slot: int) -> void:
	_weapon_effects.append({"type": "spin_blade",
		"angle": randf() * TAU, "radius": 50.0, "timer": 3.5, "char_slot": slot})


func _spawn_bible_effect_for(slot: int) -> void:
	_weapon_effects.append({"type": "bible",
		"angle": randf() * TAU, "radius": 55.0, "timer": 4.0,
		"book_count": 3, "char_slot": slot})


func _spawn_evo_effect_for(evo_type: int, cp: Vector2, fr: bool, slot: int) -> void:
	match evo_type:
		15:
			for i in range(4):
				var tgt := Vector2(randf_range(cp.x - 100, cp.x + 100),
					randf_range(cp.y - 60, cp.y + 60))
				_weapon_effects.append({"type": "evo_inferno",
					"pos": Vector2(tgt.x, -20), "target": tgt,
					"timer": 2.0, "phase": 0, "radius": 40.0, "char_slot": slot})
			_damage_enemies_in_range(cp, 150.0)
		16:
			_weapon_effects.append({"type": "evo_freeze",
				"timer": 1.2, "max_timer": 1.2, "area": 120.0, "char_slot": slot})
			_damage_enemies_in_range(cp, 120.0)
		17:
			_weapon_effects.append({"type": "evo_scythe",
				"angle": 0.0, "radius": 65.0, "timer": 3.5, "char_slot": slot})
			_damage_enemies_in_range(cp, 75.0)
		18:
			var dir_f: float = 1.0 if fr else -1.0
			_weapon_effects.append({"type": "evo_thor",
				"pos": Vector2(cp), "vel": Vector2(dir_f * 250.0, 0),
				"timer": 2.0, "trail": [], "exploded": false, "char_slot": slot})
		19:
			_weapon_effects.append({"type": "evo_plague",
				"timer": 3.5, "max_timer": 3.5, "area": 100.0, "char_slot": slot})
			_damage_enemies_in_range(cp, 100.0)
		20:
			_weapon_effects.append({"type": "evo_divine",
				"angle": 0.0, "radius": 65.0, "timer": 4.0, "char_slot": slot})
			_damage_enemies_in_range(cp, 75.0)
		21:
			for i in range(3):
				var ne: Dictionary = _find_nearest_enemy_to(cp)
				var dir: Vector2
				if not ne.is_empty():
					dir = cp.direction_to(ne["pos"]).rotated(randf_range(-0.4, 0.4))
				else:
					dir = Vector2.from_angle(randf() * TAU)
				_weapon_effects.append({"type": "evo_void",
					"pos": Vector2(cp), "vel": dir * 160.0,
					"timer": 2.0, "trail": [], "char_slot": slot})
			_damage_enemies_in_range(cp, 80.0)


func _find_nearest_enemy_to(cp: Vector2) -> Dictionary:
	var best: Dictionary = {}
	var best_d: float = 9999.0
	for e in _demo_enemies:
		var d: float = cp.distance_to(e["pos"])
		if d < best_d:
			best_d = d
			best = e
	return best


func _damage_enemies_in_range(center: Vector2, radius: float) -> void:
	for e in _demo_enemies:
		if e["pos"].distance_to(center) < radius:
			e["hp"] -= 1.5
			e["flash"] = 0.12


func _get_char_pos_for_slot(slot: int) -> Vector2:
	if slot >= 0 and slot < _active_chars.size():
		return _active_chars[slot]["pos"]
	return Vector2.ZERO


# ============ Update ============

func _update_enemies(delta: float) -> void:
	var to_remove: Array = []
	for i in range(_demo_enemies.size()):
		var e: Dictionary = _demo_enemies[i]
		var target: Vector2 = _get_nearest_char_pos(e["pos"])
		e["pos"] += (target - e["pos"]).normalized() * e["speed"] * delta
		e["anim_timer"] += delta
		if e["anim_timer"] >= 0.35:
			e["anim_timer"] -= 0.35
			e["anim_frame"] = 1 - e["anim_frame"]
		if e["flash"] > 0: e["flash"] -= delta
		if e["hp"] <= 0:
			to_remove.append(i)
			_spawn_death_particles(e["pos"])
	to_remove.reverse()
	for idx in to_remove: _demo_enemies.remove_at(idx)
	while _demo_enemies.size() < MAX_ENEMIES: _spawn_enemy()


func _update_weapon_effects(delta: float) -> void:
	var to_remove: Array = []
	for i in range(_weapon_effects.size()):
		var fx: Dictionary = _weapon_effects[i]
		fx["timer"] -= delta
		if fx["timer"] <= 0:
			to_remove.append(i)
			continue
		var slot: int = fx.get("char_slot", 0)
		var cp: Vector2 = _get_char_pos_for_slot(slot)
		match fx["type"]:
			"projectile":
				fx["pos"] += fx["vel"] * delta
				fx["trail"].append(Vector2(fx["pos"]))
				if fx["trail"].size() > 8: fx["trail"].pop_front()
				_damage_enemies_in_range(fx["pos"], fx["radius"] + 8.0)
			"fireball":
				if not fx["exploded"]:
					fx["pos"] += fx["vel"] * delta
					fx["trail"].append(Vector2(fx["pos"]))
					if fx["trail"].size() > 6: fx["trail"].pop_front()
					var hit := false
					for e in _demo_enemies:
						if fx["pos"].distance_to(e["pos"]) < 20:
							hit = true; break
					if hit or fx["timer"] < 0.5:
						fx["exploded"] = true
						fx["timer"] = 0.6
						_damage_enemies_in_range(fx["pos"], 50.0)
			"garlic":
				fx["rune_angle"] += delta * 1.5
				fx["spark_angle"] += delta * 2.0
				_damage_enemies_in_range(cp, 55.0)
			"holy_water":
				_damage_enemies_in_range(fx["pos"], fx["area_r"])
			"cross":
				fx["rot_angle"] += delta * 10.0
				fx["trail"].append(Vector2(fx["pos"]))
				if fx["trail"].size() > 12: fx["trail"].pop_front()
				if fx["phase"] == 0:
					fx["pos"].x += fx["vel_x"] * delta
					fx["pos"].y += fx["vel_y"] * delta
					fx["vel_y"] += 200.0 * delta
					if fx["pos"].distance_to(fx["origin"]) > 180 or fx["vel_y"] > 100:
						fx["phase"] = 1
				else:
					var dir: Vector2 = (fx["origin"] - fx["pos"]).normalized()
					fx["pos"] += dir * 220.0 * delta
					if fx["pos"].distance_to(fx["origin"]) < 20: fx["timer"] = 0
				_damage_enemies_in_range(fx["pos"], 18.0)
			"spin_blade":
				fx["angle"] += delta * 5.0
				var bp: Vector2 = cp + Vector2(cos(fx["angle"]), sin(fx["angle"])) * fx["radius"]
				_damage_enemies_in_range(bp, 22.0)
			"bible":
				fx["angle"] += delta * 2.5
			"lightning":
				fx["flicker"] += delta * 25.0
			"evo_inferno":
				if fx["phase"] == 0:
					fx["pos"] = fx["pos"].lerp(fx["target"], delta * 3.0)
					if fx["pos"].distance_to(fx["target"]) < 10:
						fx["phase"] = 1
						fx["timer"] = minf(fx["timer"], 1.0)
			"evo_freeze": pass
			"evo_scythe":
				fx["angle"] += delta * 4.0
				_damage_enemies_in_range(cp + Vector2(cos(fx["angle"]), sin(fx["angle"])) * fx["radius"], 35.0)
			"evo_thor":
				if not fx["exploded"]:
					fx["pos"] += fx["vel"] * delta
					fx["trail"].append(Vector2(fx["pos"]))
					if fx["trail"].size() > 10: fx["trail"].pop_front()
					_damage_enemies_in_range(fx["pos"], 20.0)
					if absf(fx["pos"].x - cp.x) > 200:
						fx["exploded"] = true
						fx["timer"] = minf(fx["timer"], 0.5)
						_damage_enemies_in_range(fx["pos"], 80.0)
			"evo_plague": pass
			"evo_divine":
				fx["angle"] += delta * 2.0
			"evo_void":
				fx["pos"] += fx["vel"] * delta
				fx["trail"].append(Vector2(fx["pos"]))
				if fx["trail"].size() > 10: fx["trail"].pop_front()
				_damage_enemies_in_range(fx["pos"], 15.0)

	to_remove.reverse()
	for idx in to_remove: _weapon_effects.remove_at(idx)


func _spawn_death_particles(pos: Vector2) -> void:
	for i in range(6):
		_death_particles.append({"pos": Vector2(pos),
			"vel": Vector2(randf_range(-60, 60), randf_range(-80, -20)),
			"color": Color(randf_range(0.7, 1.0), randf_range(0.1, 0.4), 0.1, 0.9),
			"life": randf_range(0.3, 0.6), "size": randf_range(2.0, 4.0)})
	if randf() < 0.4:
		var gc: Array = [Color(0.2, 0.9, 0.3), Color(0.3, 0.5, 1.0), Color(0.9, 0.2, 0.3), Color(0.9, 0.8, 0.2)]
		_death_particles.append({"pos": Vector2(pos),
			"vel": Vector2(randf_range(-30, 30), randf_range(-50, -10)),
			"color": gc[randi() % gc.size()], "life": 1.2, "size": 4.0})


func _update_death_particles(delta: float) -> void:
	var to_remove: Array = []
	for i in range(_death_particles.size()):
		var p: Dictionary = _death_particles[i]
		p["pos"] += p["vel"] * delta
		p["vel"].y += 150.0 * delta
		p["life"] -= delta
		if p["life"] <= 0: to_remove.append(i)
	to_remove.reverse()
	for idx in to_remove: _death_particles.remove_at(idx)


# ============================================================
#  Drawing
# ============================================================

func _draw() -> void:
	var vp := get_viewport_rect().size
	if vp.x < 1: return
	draw_rect(Rect2(Vector2.ZERO, vp), Color(0.03, 0.03, 0.07))
	_draw_stars(vp)
	_draw_ground(vp)
	_draw_enemies_sprites()
	_draw_weapon_effects()
	for ac in _active_chars:
		_draw_one_character(ac)
	_draw_death_particles_fx()
	_draw_vignette(vp)
	for ac in _active_chars:
		if ac["evo_flash"] > 0:
			var ef: float = ac["evo_flash"] / 0.3
			draw_circle(ac["pos"], 80.0 * ef, Color(1, 1, 1, ef * 0.25))


func _draw_stars(_vp: Vector2) -> void:
	for s in _stars:
		var alpha: float = 0.15 + 0.15 * sin(_time * s["speed"] + s["phase"])
		draw_rect(Rect2(s["pos"].x, s["pos"].y, s["size"], s["size"]), Color(0.7, 0.7, 0.9, alpha))


func _draw_ground(vp: Vector2) -> void:
	var gy: float = vp.y * 0.88
	draw_rect(Rect2(0, gy, vp.x, vp.y - gy), Color(0.06, 0.08, 0.04, 0.4))
	var lc := Color(0.12, 0.18, 0.08, 0.3)
	var ix: int = -32 + int(_ground_offset)
	while ix < int(vp.x) + 32:
		draw_rect(Rect2(ix, gy, 1, vp.y - gy), lc)
		ix += 32
	draw_rect(Rect2(0, gy, vp.x, 1), Color(0.2, 0.35, 0.15, 0.4))


func _draw_one_character(ac: Dictionary) -> void:
	if _char_cache.is_empty(): return
	var cd: Dictionary = _char_cache[ac["idx"]]
	var frames: Array = cd["frames"]
	if frames.is_empty(): return
	var tex: Texture2D = frames[(ac["anim_frame"] as int) % frames.size()]
	if tex == null: return
	var sv: float = 4.0
	var ts := tex.get_size()
	var ds := ts * sv
	var dp: Vector2 = ac["pos"] - ds * 0.5
	var alpha: float = ac["fade_alpha"]
	var mod_color := Color(1, 1, 1, alpha)
	if not ac["facing_right"]:
		draw_texture_rect_region(tex, Rect2(dp.x + ds.x, dp.y, -ds.x, ds.y), Rect2(Vector2.ZERO, ts), mod_color)
	else:
		draw_texture_rect(tex, Rect2(dp, ds), false, mod_color)


func _draw_enemies_sprites() -> void:
	for e in _demo_enemies:
		var sprites: Array = _enemy_sprites_cache.get(e["type"], [])
		if sprites.size() > 0:
			var tex: Texture2D = sprites[e["anim_frame"] % sprites.size()]
			if tex != null:
				var ts := tex.get_size()
				var ds := ts * 2.5
				var cm: Color = Color(2.0, 0.5, 0.5) if e["flash"] > 0 else Color.WHITE
				draw_texture_rect(tex, Rect2(e["pos"] - ds * 0.5, ds), false, cm)
				continue
		var sz: float = e["size"]
		draw_rect(Rect2(e["pos"].x - sz * 0.5, e["pos"].y - sz * 0.5, sz, sz),
			Color(1.0, 0.8, 0.8, 0.6) if e["flash"] > 0 else Color(0.8, 0.2, 0.2, 0.4))


# ============ Weapon effect drawing (ported from actual game) ============

func _draw_weapon_effects() -> void:
	for fx in _weapon_effects:
		match fx["type"]:
			"whip": _draw_fx_whip(fx)
			"projectile": _draw_fx_projectile(fx)
			"fireball": _draw_fx_fireball(fx)
			"garlic": _draw_fx_garlic(fx)
			"holy_water": _draw_fx_holy_water(fx)
			"lightning": _draw_fx_lightning(fx)
			"cross": _draw_fx_cross(fx)
			"spin_blade": _draw_fx_spin_blade(fx)
			"bible": _draw_fx_bible(fx)
			"evo_inferno": _draw_fx_evo_inferno(fx)
			"evo_freeze": _draw_fx_evo_freeze(fx)
			"evo_scythe": _draw_fx_evo_scythe(fx)
			"evo_thor": _draw_fx_evo_thor(fx)
			"evo_plague": _draw_fx_evo_plague(fx)
			"evo_divine": _draw_fx_evo_divine(fx)
			"evo_void": _draw_fx_evo_void(fx)


func _draw_fx_whip(fx: Dictionary) -> void:
	var cp: Vector2 = _get_char_pos_for_slot(fx.get("char_slot", 0))
	var t: float = 1.0 - fx["timer"] / fx["max_timer"]
	var dir_f: float = fx["dir"]
	var base_angle: float = 0.0 if dir_f > 0 else PI
	var length: float = 80.0
	var alpha: float = 1.0 - t * t
	var sweep: float = lerpf(-PI * 0.4, PI * 0.4, t)

	for ghost in range(2):
		var gt: float = clampf(t - ghost * 0.1, 0.0, 1.0)
		var gs: float = lerpf(-PI * 0.4, PI * 0.4, gt)
		var ga: float = alpha * (0.25 - ghost * 0.08)
		for i in range(16):
			var ratio: float = float(i) / 15.0
			var angle: float = base_angle + lerpf(-PI * 0.4, gs, ratio)
			var r: float = length * (0.25 + ratio * 0.75)
			var pos: Vector2 = cp + Vector2(cos(angle), sin(angle)) * r
			var sz: float = (3.0 + ratio * 5.0) * (1.0 - ghost * 0.3)
			draw_circle(pos, sz, Color(1.0, 0.4 - ghost * 0.1, 0.0, ga * ratio))

	var prev_pos: Vector2 = cp
	for i in range(20):
		var ratio: float = float(i) / 19.0
		var angle: float = base_angle + lerpf(-PI * 0.4, sweep, ratio)
		var r: float = length * (0.25 + ratio * 0.75)
		var pos: Vector2 = cp + Vector2(cos(angle), sin(angle)) * r
		var width: float = lerpf(5.0, 1.5, ratio)
		var fire_t: float = clampf(ratio * 1.5, 0.0, 1.0)
		var col := Color(1.0, lerpf(0.95, 0.2, fire_t), lerpf(0.6, 0.0, fire_t), alpha * (0.5 + ratio * 0.5))
		if i > 0:
			draw_line(prev_pos, pos, col, width)
			draw_line(prev_pos, pos, Color(1.0, 0.8, 0.3, alpha * 0.12), width * 2.5)
		prev_pos = pos

	var tip_angle: float = base_angle + sweep
	var tip: Vector2 = cp + Vector2(cos(tip_angle), sin(tip_angle)) * length
	var tip_pulse: float = sin(t * PI * 3.0) * 0.3 + 0.7
	draw_circle(tip, 12.0 * alpha * tip_pulse, Color(1.0, 0.5, 0.0, alpha * 0.2))
	draw_circle(tip, 7.0 * alpha * tip_pulse, Color(1.0, 0.7, 0.2, alpha * 0.4))
	draw_circle(tip, 3.5 * alpha, Color(1.0, 0.95, 0.7, alpha * 0.8))
	draw_circle(tip, 2.0 * alpha, Color(1, 1, 1, alpha))
	for i in range(6):
		var ra: float = tip_angle + (TAU / 6.0) * i + t * 2.0
		var re: Vector2 = tip + Vector2(cos(ra), sin(ra)) * 15.0 * alpha * tip_pulse
		draw_line(tip, re, Color(1.0, 0.6, 0.1, alpha * 0.3), 1.5)


func _draw_fx_projectile(fx: Dictionary) -> void:
	var col: Color = fx["color"]
	var rad: float = fx["radius"]
	var trail: Array = fx["trail"]
	for i in range(trail.size() - 1):
		var t: float = 1.0 - float(i) / float(trail.size())
		var from: Vector2 = trail[i]
		var to: Vector2 = trail[i + 1]
		draw_line(from, to, Color(col, t * 0.08), rad * 3.5 * t)
		draw_line(from, to, Color(col, t * 0.25), rad * 1.5 * t)
		draw_line(from, to, Color(1, 1, 1, t * 0.35), rad * 0.5 * t)
		if i % 2 == 0 and trail.size() > 1:
			var mid: Vector2 = (from + to) * 0.5
			var perp: Vector2 = (to - from).normalized().orthogonal()
			var sp: Vector2 = perp * sin(_time * 12.0 + float(i) * 0.8) * rad * 1.2 * t
			draw_circle(mid + sp, 2.0 * t, Color(col, t * 0.6))

	var p: Vector2 = fx["pos"]
	var pulse: float = sin(_time * 15.0) * 0.25 + 0.75
	var cr: float = rad * 1.2
	draw_circle(p, cr * 2.2 * pulse, Color(col, 0.08))
	draw_circle(p, cr * 1.5 * pulse, Color(col, 0.18))
	draw_circle(p, cr, Color(col, 0.35))
	draw_circle(p, cr * 0.6, Color(col.lightened(0.5), 0.6))
	draw_circle(p, cr * 0.3, Color(1, 1, 1, 0.8))
	for i in range(4):
		var sa: float = _time * 8.0 + (TAU / 4.0) * i
		var se: Vector2 = p + Vector2(cos(sa), sin(sa)) * rad * 1.8 * pulse
		draw_line(p, se, Color(col, 0.3), 1.5)
		draw_circle(se, 1.5, Color(1, 1, 1, 0.4))


func _draw_fx_fireball(fx: Dictionary) -> void:
	if fx["exploded"]:
		var t: float = fx["timer"] / 0.6
		var rad: float = 45.0
		draw_circle(fx["pos"], rad * 1.2 * (1.2 - t * 0.2), Color(1.0, 0.35, 0.0, t * 0.2))
		draw_circle(fx["pos"], rad * 0.9 * (1.15 - t * 0.15), Color(1.0, 0.55, 0.1, t * 0.3))
		draw_circle(fx["pos"], rad * 0.5, Color(1.0, 0.8, 0.2, t * 0.5))
		draw_circle(fx["pos"], rad * 0.25, Color(1.0, 0.95, 0.5, t * 0.7))
		draw_circle(fx["pos"], rad * 0.1 * t, Color(1, 1, 1, t * 0.8))
		draw_arc(fx["pos"], rad * t, 0, TAU, 32, Color(1.0, 0.3, 0.0, t * 0.4), 3.0)
		for i in range(8):
			var angle: float = float(i) / 8.0 * TAU + t * 3.0
			var rl: float = rad * 1.5 * t
			var rp: Vector2 = fx["pos"] + Vector2(cos(angle), sin(angle)) * rl
			draw_line(fx["pos"], rp, Color(1.0, 0.5, 0.0, t * 0.2), 2.0)
		for i in range(6):
			var angle: float = (TAU / 6.0) * i
			var cl: float = rad * 0.8 * (1.0 - t * 0.2)
			var ce: Vector2 = fx["pos"] + Vector2(cos(angle), sin(angle)) * cl
			var cm: Vector2 = ce * 0.5 + fx["pos"] * 0.5 + Vector2(sin(float(i) * 2.3) * 6.0, cos(float(i) * 1.7) * 6.0)
			draw_line(fx["pos"], cm, Color(0.4, 0.15, 0.0, t * 0.35), 1.5)
			draw_line(cm, ce, Color(0.3, 0.1, 0.0, t * 0.2), 1.0)
	else:
		_draw_fx_projectile({"pos": fx["pos"], "trail": fx["trail"],
			"color": Color.ORANGE_RED, "radius": 7.0, "timer": fx["timer"]})


func _draw_fx_garlic(fx: Dictionary) -> void:
	var cp: Vector2 = _get_char_pos_for_slot(fx.get("char_slot", 0))
	var t: float = fx["timer"] / fx["max_timer"]
	var area: float = 55.0

	draw_circle(cp, area * 0.5 * t, Color(0.2, 0.6, 0.1, t * 0.08))
	draw_circle(cp, area * 0.3 * t, Color(0.3, 0.8, 0.2, t * 0.12))

	var ring_t: float = 1.0 - t
	var r: float = area * (0.3 + ring_t * 0.7)
	var a: float = t * (1.0 - ring_t) * 0.6
	draw_arc(cp, r, 0, TAU, 48, Color(0.3, 1.0, 0.2, a), 2.5)
	draw_arc(cp, r, 0, TAU, 48, Color(0.4, 1.0, 0.3, a * 0.2), 6.0)

	for i in range(6):
		var angle: float = fx["rune_angle"] + (TAU / 6.0) * i
		var rp: Vector2 = cp + Vector2(cos(angle), sin(angle)) * area * 0.6
		var rs: float = 4.0
		draw_line(rp + Vector2(-rs, -rs), rp + Vector2(rs, rs), Color(0.4, 0.9, 0.2, t * 0.4), 1.5)
		draw_line(rp + Vector2(rs, -rs), rp + Vector2(-rs, rs), Color(0.4, 0.9, 0.2, t * 0.4), 1.5)
		draw_circle(rp, 2.0, Color(0.5, 1.0, 0.3, t * 0.4))

	for i in range(8):
		var angle: float = fx["spark_angle"] + (TAU / 8.0) * i
		var wobble: float = sin(angle * 3.0 + fx["spark_angle"] * 2.0) * 0.25
		var sr: float = area * (0.5 + wobble)
		var sp: Vector2 = cp + Vector2(cos(angle), sin(angle)) * sr
		draw_circle(sp, 2.5, Color(0.3, 0.9, 0.1, t * 0.25))
		draw_circle(sp, 1.5, Color(0.5, 1.0, 0.3, t * 0.6))
		draw_circle(sp, 0.8, Color(1, 1, 1, t * 0.3))


func _draw_fx_holy_water(fx: Dictionary) -> void:
	var p: Vector2 = fx["pos"]
	var ar: float = fx["area_r"]
	var alpha: float = clampf(fx["timer"] / 0.5, 0.0, 1.0) * 0.5
	var rt: float = _time

	draw_circle(p, ar * 1.05, Color(0.1, 0.25, 0.8, alpha * 0.15))
	draw_circle(p, ar, Color(0.15, 0.3, 0.9, alpha * 0.3))
	draw_circle(p, ar * 0.7, Color(0.2, 0.4, 1.0, alpha * 0.2))
	draw_circle(p, ar * 0.4, Color(0.4, 0.6, 1.0, alpha * 0.12))

	for r_idx in range(2):
		var cr: float = ar * (0.5 + float(r_idx) * 0.35)
		var rot: float = rt * (0.5 if r_idx == 0 else -0.3)
		var sc: int = 8 + r_idx * 4
		for i in range(sc):
			var a1: float = rot + (TAU / sc) * i
			var a2: float = a1 + (TAU / sc) * 0.6
			draw_arc(p, cr, a1, a2, 6, Color(0.5, 0.7, 1.0, alpha * 0.35), 1.5)
			draw_circle(p + Vector2(cos(a1), sin(a1)) * cr, 1.5, Color(0.6, 0.8, 1.0, alpha * 0.25))

	for rr in range(3):
		var rip_t: float = fmod(rt * 1.2 + float(rr) * 0.3, 1.0)
		draw_arc(p, ar * rip_t, 0, TAU, 32, Color(0.5, 0.75, 1.0, (1.0 - rip_t) * alpha * 0.5), 2.0)

	draw_arc(p, ar, 0, TAU, 48, Color(0.4, 0.65, 1.0, alpha * 0.6), 2.5)

	for i in range(4):
		var angle: float = (rt * 0.8 + float(i) * 1.5) * 2.0
		var br: float = ar * (0.3 + 0.4 * sin(angle * 0.3 + float(i)))
		var bp: Vector2 = p + Vector2(cos(angle), sin(angle)) * br
		var ba: float = alpha * (0.3 + 0.2 * sin(rt * 3.0 + float(i)))
		draw_circle(bp, 3.0, Color(0.5, 0.7, 1.0, ba))
		draw_circle(bp, 1.5, Color(0.8, 0.9, 1.0, ba * 0.5))

	for i in range(3):
		var px: float = (float(i) / 2.0 - 0.5) * ar
		var ph: float = 25.0 + 10.0 * sin(rt * 2.0 + float(i))
		var pa: float = alpha * (0.2 + 0.15 * sin(rt * 3.0 + float(i)))
		draw_line(p + Vector2(px, 0), p + Vector2(px, -ph), Color(0.4, 0.6, 1.0, pa * 0.3), 8.0)
		draw_line(p + Vector2(px, 0), p + Vector2(px, -ph), Color(0.6, 0.8, 1.0, pa), 2.5)
		draw_circle(p + Vector2(px, -ph), 2.5, Color(0.7, 0.9, 1.0, pa * 0.5))

	var cs: float = 6.0
	draw_line(p + Vector2(0, -cs), p + Vector2(0, cs), Color(1.0, 0.95, 0.8, alpha * 0.25), 1.5)
	draw_line(p + Vector2(-cs * 0.7, -cs * 0.3), p + Vector2(cs * 0.7, -cs * 0.3), Color(1.0, 0.95, 0.8, alpha * 0.25), 1.5)


func _draw_fx_lightning(fx: Dictionary) -> void:
	var t: float = fx["timer"] / fx["max_timer"]
	var flicker: float = 0.6 + sin(fx["flicker"]) * 0.3 + sin(fx["flicker"] * 1.7) * 0.1
	var segs: Array = fx["segments"]

	for i in range(segs.size() - 1):
		var al: float = t * flicker
		draw_line(segs[i], segs[i + 1], Color(0.3, 0.4, 1.0, al * 0.08), 12.0)
		draw_line(segs[i], segs[i + 1], Color(0.4, 0.6, 1.0, al * 0.2), 6.0)
		draw_line(segs[i], segs[i + 1], Color(0.6, 0.8, 1.0, al * 0.5), 3.0)
		draw_line(segs[i], segs[i + 1], Color(1.0, 1.0, 1.0, al * 0.9), 1.5)
		if i % 2 == 0 and i + 1 < segs.size():
			var mid: Vector2 = (segs[i] + segs[i + 1]) * 0.5
			var perp: Vector2 = (segs[i + 1] - segs[i]).normalized().orthogonal()
			draw_circle(mid + perp * sin(_time * 10.0 + float(i)) * 8.0, 2.0 * t, Color(0.7, 0.9, 1.0, al * 0.5))

	for branch in fx["branches"]:
		for i in range(branch.size() - 1):
			var al: float = t * flicker * 0.6
			draw_line(branch[i], branch[i + 1], Color(0.5, 0.7, 1.0, al * 0.12), 4.0)
			draw_line(branch[i], branch[i + 1], Color(0.7, 0.85, 1.0, al * 0.4), 2.0)
			draw_line(branch[i], branch[i + 1], Color(1.0, 1.0, 1.0, al * 0.6), 1.0)

	var ball_phase: float = _time * 8.0
	var ball_r: float = 6.0 * t * (0.8 + sin(ball_phase) * 0.2)
	var orig: Vector2 = fx["origin"]
	draw_circle(orig, ball_r * 1.5, Color(0.4, 0.6, 1.0, t * 0.1))
	draw_circle(orig, ball_r, Color(0.6, 0.8, 1.0, t * 0.25))
	draw_circle(orig, ball_r * 0.5, Color(0.9, 0.95, 1.0, t * 0.5))
	for i in range(4):
		var aa: float = ball_phase + (TAU / 4.0) * i
		draw_line(orig, orig + Vector2(cos(aa), sin(aa)) * ball_r * 2.0, Color(0.7, 0.9, 1.0, t * 0.3 * flicker), 1.0)

	var tgt: Vector2 = fx["target"]
	var ir: float = 10.0 * t * (0.7 + sin(ball_phase * 1.3) * 0.3)
	draw_circle(tgt, ir * 2.0, Color(0.3, 0.5, 1.0, t * 0.1))
	draw_circle(tgt, ir, Color(0.6, 0.8, 1.0, t * 0.3))
	draw_circle(tgt, ir * 0.5, Color(1, 1, 1, t * 0.6))
	draw_arc(tgt, ir * 1.5, 0, TAU, 24, Color(0.5, 0.7, 1.0, t * 0.25), 2.0)


func _draw_fx_cross(fx: Dictionary) -> void:
	var p: Vector2 = fx["pos"]
	var trail: Array = fx["trail"]
	var rot: float = fx["rot_angle"]

	for i in range(trail.size() - 1):
		var t: float = 1.0 - float(i) / float(trail.size())
		draw_line(trail[i], trail[i + 1], Color(1.0, 0.85, 0.2, t * 0.08), 10.0 * t)
		draw_line(trail[i], trail[i + 1], Color(1.0, 0.9, 0.4, t * 0.3), 3.0 * t)
		draw_line(trail[i], trail[i + 1], Color(1.0, 0.98, 0.8, t * 0.15), 6.0 * t)
		if i % 2 == 0:
			var mid: Vector2 = (trail[i] + trail[i + 1]) * 0.5
			var wb: Vector2 = Vector2(sin(_time * 8.0 + float(i)) * 3.0, cos(_time * 6.0 + float(i)) * 3.0) * t
			draw_circle(mid + wb, 2.0 * t, Color(1.0, 0.95, 0.6, t * 0.6))

	var pulse: float = sin(_time * 10.0) * 0.15 + 0.85
	draw_circle(p, 16.0 * pulse, Color(1.0, 0.85, 0.2, 0.06))
	draw_circle(p, 10.0 * pulse, Color(1.0, 0.9, 0.4, 0.1))

	var s: float = 9.0
	var c: float = cos(rot)
	var sn: float = sin(rot)
	for m in [1.0, -1.0]:
		var a1: Vector2 = Vector2(c * s * m, sn * s * m)
		var a2: Vector2 = Vector2(-sn * s * m, c * s * m)
		draw_line(p, p + a1, Color(1.0, 0.85, 0.2, 0.12), 8.0)
		draw_line(p, p + a2, Color(1.0, 0.85, 0.2, 0.12), 8.0)
		draw_line(p, p + a1, Color(1.0, 0.92, 0.5, 0.5), 3.0)
		draw_line(p, p + a2, Color(1.0, 0.92, 0.5, 0.5), 3.0)
		draw_line(p, p + a1, Color(1, 1, 0.9, 0.7), 1.5)
		draw_line(p, p + a2, Color(1, 1, 0.9, 0.7), 1.5)
		draw_circle(p + a1, 2.5, Color(1.0, 0.95, 0.7, 0.5))
		draw_circle(p + a2, 2.5, Color(1.0, 0.95, 0.7, 0.5))

	for i in range(6):
		var ba: float = rot * 0.5 + (TAU / 6.0) * i
		var be: Vector2 = p + Vector2(cos(ba), sin(ba)) * 14.0 * pulse
		draw_line(p, be, Color(1.0, 0.95, 0.6, 0.1), 1.5)

	draw_circle(p, 4.0, Color(1.0, 0.95, 0.7, 0.7))
	draw_circle(p, 2.0, Color(1, 1, 1, 0.9))


func _draw_fx_spin_blade(fx: Dictionary) -> void:
	var cp: Vector2 = _get_char_pos_for_slot(fx.get("char_slot", 0))
	var radius: float = fx["radius"]
	var ba: float = fx["angle"]
	var bc: int = 2

	for i in range(6):
		var angle: float = ba * 0.3 + (TAU / 6.0) * i
		var inner: Vector2 = cp + Vector2(cos(angle), sin(angle)) * 10.0
		var outer: Vector2 = cp + Vector2(cos(angle + 0.4), sin(angle + 0.4)) * radius * 0.85
		draw_line(inner, outer, Color(0.5, 0.7, 1.0, 0.05), 1.5)

	draw_arc(cp, radius, 0, TAU, 48, Color(0.5, 0.7, 1.0, 0.08), 1.5)

	for i in range(bc):
		var angle: float = ba + (TAU / bc) * i
		var offset: Vector2 = Vector2(cos(angle), sin(angle)) * radius
		var bp: Vector2 = cp + offset
		var dir_out: Vector2 = offset.normalized()
		var perp: Vector2 = dir_out.orthogonal()

		draw_circle(bp, 14.0, Color(0.4, 0.6, 1.0, 0.05))

		var tip: Vector2 = bp + dir_out * 8.0
		var back: Vector2 = bp - dir_out * 4.0
		var s1: Vector2 = bp + perp * 14.0
		var s2: Vector2 = bp - perp * 14.0

		draw_colored_polygon(PackedVector2Array([tip + dir_out * 2.0, s1 + perp * 2.0, back - dir_out * 1.5, s2 - perp * 2.0]),
			Color(0.4, 0.65, 1.0, 0.1))
		draw_colored_polygon(PackedVector2Array([tip, s1, back, s2]), Color(0.75, 0.88, 1.0, 0.65))
		var it: Vector2 = bp + dir_out * 5.0
		var ib: Vector2 = bp - dir_out * 2.0
		var is1: Vector2 = bp + perp * 7.0
		var is2: Vector2 = bp - perp * 7.0
		draw_colored_polygon(PackedVector2Array([it, is1, ib, is2]), Color(0.9, 0.95, 1.0, 0.45))
		draw_line(s1, tip, Color(1, 1, 1, 0.5), 1.0)
		draw_line(s2, tip, Color(1, 1, 1, 0.5), 1.0)
		draw_circle(bp, 4.0, Color(0.7, 0.9, 1.0, 0.5))
		draw_circle(bp, 2.0, Color(1, 1, 1, 0.6))


func _draw_fx_bible(fx: Dictionary) -> void:
	var cp: Vector2 = _get_char_pos_for_slot(fx.get("char_slot", 0))
	var radius: float = fx["radius"]
	var oa: float = fx["angle"]
	var bc: int = fx["book_count"]
	var rp: float = _time * 2.0

	for i in range(32):
		var angle: float = (TAU / 32.0) * i
		var dp: Vector2 = cp + Vector2(cos(angle), sin(angle)) * radius
		draw_circle(dp, 1.2, Color(1.0, 0.9, 0.4, 0.12 + 0.08 * sin(rp * 2.0 + float(i) * 0.5)))

	draw_arc(cp, radius * 0.85, 0, TAU, 48, Color(1.0, 0.85, 0.3, 0.06), 1.5)

	for i in range(8):
		var angle: float = rp * 0.5 + (TAU / 8.0) * i
		var rune_p: Vector2 = cp + Vector2(cos(angle), sin(angle)) * radius
		var rs: float = 2.5
		draw_line(rune_p + Vector2(0, -rs), rune_p + Vector2(0, rs), Color(1.0, 0.9, 0.5, 0.15), 1.0)
		draw_line(rune_p + Vector2(-rs * 0.6, 0), rune_p + Vector2(rs * 0.6, 0), Color(1.0, 0.9, 0.5, 0.15), 1.0)

	for i in range(bc):
		var angle: float = oa + (TAU / bc) * i
		var pos: Vector2 = cp + Vector2(cos(angle), sin(angle)) * radius

		var ph: float = 24.0 + 6.0 * sin(rp * 3.0 + float(i))
		draw_line(pos + Vector2(0, -ph), pos + Vector2(0, ph), Color(1.0, 0.95, 0.6, 0.05), 12.0)
		draw_line(pos + Vector2(0, -ph * 0.7), pos + Vector2(0, ph * 0.7), Color(1.0, 0.9, 0.5, 0.1), 6.0)

		draw_circle(pos, 14.0, Color(1.0, 0.85, 0.3, 0.06))
		draw_circle(pos, 9.0, Color(1.0, 0.9, 0.4, 0.12))

		draw_rect(Rect2(pos.x - 6, pos.y - 7, 12, 14), Color(0.96, 0.92, 0.75))
		draw_rect(Rect2(pos.x - 6, pos.y - 7, 12, 14), Color(0.85, 0.7, 0.2), false, 1.5)
		draw_line(Vector2(pos.x, pos.y - 6), Vector2(pos.x, pos.y + 6), Color(0.7, 0.55, 0.15), 1.0)
		draw_line(Vector2(pos.x, pos.y - 3), Vector2(pos.x, pos.y + 2), Color(0.85, 0.7, 0.2), 1.0)
		draw_line(Vector2(pos.x - 2, pos.y - 1), Vector2(pos.x + 2, pos.y - 1), Color(0.85, 0.7, 0.2), 1.0)

		for r in range(6):
			var ray_a: float = angle + (float(r) / 6.0) * TAU + rp
			var rl: float = 18.0 + 5.0 * sin(rp * 4.0 + float(r))
			draw_line(pos, pos + Vector2(cos(ray_a), sin(ray_a)) * rl, Color(1.0, 0.95, 0.6, 0.12), 1.5)

		draw_circle(pos, 3.0, Color(1.0, 0.95, 0.7, 0.7))
		draw_circle(pos, 1.5, Color(1, 1, 1, 0.85))


# ============ Evo effects ============

func _draw_fx_evo_inferno(fx: Dictionary) -> void:
	var p: Vector2 = fx["pos"]
	if fx["phase"] == 0:
		var diff: Vector2 = fx["target"] - p
		draw_circle(p, 8.0, Color(1.0, 0.5, 0.0, 0.9))
		draw_circle(p, 14.0, Color(1.0, 0.3, 0.0, 0.4))
		draw_circle(p, 20.0, Color(1.0, 0.2, 0.0, 0.15))
		if diff.length() > 1:
			for i in range(3):
				var te: Vector2 = p - diff.normalized() * (15.0 + float(i) * 10.0)
				draw_line(p, te, Color(1.0, 0.6, 0.1, 0.4 - float(i) * 0.1), 2.5 - float(i) * 0.5)
	else:
		var t: float = fx["timer"] / 1.0
		var expand: float = fx["radius"] * (0.5 + t * 0.5)
		draw_circle(p, expand, Color(1.0, 0.4, 0.0, 0.25 * (1.0 - t)))
		draw_circle(p, expand * 0.6, Color(1.0, 0.6, 0.1, 0.4 * (1.0 - t)))
		draw_circle(p, expand * 0.3, Color(1.0, 0.9, 0.3, 0.6 * (1.0 - t)))
		draw_arc(p, expand, 0, TAU, 32, Color(1.0, 0.3, 0.0, 0.5 * (1.0 - t)), 2.5)


func _draw_fx_evo_freeze(fx: Dictionary) -> void:
	var cp: Vector2 = _get_char_pos_for_slot(fx.get("char_slot", 0))
	var t: float = fx["timer"] / fx["max_timer"]
	var area: float = fx["area"]
	var expand: float = area * (1.0 - t * 0.3)

	draw_circle(cp, expand, Color(0.5, 0.9, 1.0, 0.1 * t))
	draw_circle(cp, expand * 0.7, Color(0.7, 0.95, 1.0, 0.18 * t))
	draw_arc(cp, expand, 0, TAU, 64, Color(0.5, 0.9, 1.0, 0.35 * t), 2.5)

	for i in range(12):
		var angle: float = randf() * TAU
		var dist: float = randf() * expand
		var pos: Vector2 = cp + Vector2(cos(angle), sin(angle)) * dist
		var sz: float = randf_range(2.0, 5.0) * t
		_draw_snowflake(pos, sz, Color(0.8, 0.95, 1.0, 0.5 * t))

	for i in range(4):
		var ra: float = _time * 0.5 + (TAU / 4.0) * float(i)
		var re: Vector2 = cp + Vector2(cos(ra), sin(ra)) * expand
		draw_line(cp, re, Color(0.6, 0.9, 1.0, 0.12 * t), 1.5)


func _draw_snowflake(pos: Vector2, sz: float, col: Color) -> void:
	for i in range(6):
		var angle: float = (TAU / 6.0) * float(i)
		var ae: Vector2 = pos + Vector2(cos(angle), sin(angle)) * sz
		draw_line(pos, ae, col, 1.0)
		var branch: Vector2 = pos + Vector2(cos(angle), sin(angle)) * sz * 0.6
		var perp: Vector2 = Vector2(cos(angle + PI / 3.0), sin(angle + PI / 3.0)) * sz * 0.3
		draw_line(branch, branch + perp, col, 1.0)


func _draw_fx_evo_scythe(fx: Dictionary) -> void:
	var cp: Vector2 = _get_char_pos_for_slot(fx.get("char_slot", 0))
	var area: float = fx["radius"]
	var angle: float = fx["angle"]

	draw_arc(cp, area, 0, TAU, 48, Color(0.4, 0.0, 0.5, 0.06), 1.5)

	for i in range(3):
		var a: float = angle + (TAU / 3.0) * float(i)
		var pos: Vector2 = cp + Vector2(cos(a), sin(a)) * area
		_draw_scythe(pos, a, 1.0, 1.0)
		draw_circle(pos, 6.0, Color(0.5, 0.0, 0.7, 0.12))
		for j in range(2):
			var sa: float = _time * 8.0 + float(i) * 2.0 + float(j)
			var sp: Vector2 = pos + Vector2(cos(sa), sin(sa)) * (15.0 + sin(sa) * 8.0)
			draw_circle(sp, 1.5, Color(0.7, 0.2, 1.0, 0.4))

	var vr: float = 10.0 + sin(_time * 3.0) * 2.0
	draw_circle(cp, vr, Color(0.3, 0.0, 0.4, 0.05))
	for i in range(4):
		var sa: float = _time * 1.5 + (TAU / 4.0) * float(i)
		draw_line(cp + Vector2(cos(sa), sin(sa)) * 5.0,
			cp + Vector2(cos(sa + 0.5), sin(sa + 0.5)) * area * 0.5,
			Color(0.4, 0.0, 0.5, 0.04), 1.5)


func _draw_scythe(pos: Vector2, angle: float, alpha: float, scale_f: float) -> void:
	var dir: Vector2 = Vector2(cos(angle), sin(angle))
	var perp: Vector2 = dir.orthogonal()
	var bl: float = 22.0 * scale_f
	var hl: float = 18.0 * scale_f

	draw_line(pos - dir * hl, pos, Color(0.5, 0.4, 0.3, alpha * 0.7), 2.0)

	var tip: Vector2 = pos + perp * bl
	var cm: Vector2 = pos + perp * bl * 0.7 + dir * bl * 0.5
	var b1: Vector2 = pos + dir * 3.0 * scale_f
	var b2: Vector2 = pos - dir * 1.5 * scale_f

	draw_colored_polygon(PackedVector2Array([b2, tip, cm, b1]), Color(0.4, 0.0, 0.5, alpha * 0.65))
	draw_colored_polygon(PackedVector2Array([pos, pos + perp * bl * 0.7, cm]), Color(0.6, 0.1, 0.8, alpha * 0.35))
	draw_line(pos, tip, Color(0.8, 0.3, 1.0, alpha * 0.5), 1.5)
	draw_line(tip, cm, Color(0.8, 0.3, 1.0, alpha * 0.5), 1.5)
	draw_circle(pos, 2.5 * scale_f, Color(0.7, 0.2, 1.0, alpha * 0.7))


func _draw_fx_evo_thor(fx: Dictionary) -> void:
	var _cp: Vector2 = _get_char_pos_for_slot(fx.get("char_slot", 0))
	var p: Vector2 = fx["pos"]
	var trail: Array = fx["trail"]

	for i in range(trail.size() - 1):
		var t: float = 1.0 - float(i) / float(trail.size())
		draw_line(trail[i], trail[i + 1], Color(0.6, 0.8, 1.0, t * 0.12), 5.0 * t)
		draw_line(trail[i], trail[i + 1], Color(0.8, 0.9, 1.0, t * 0.25), 2.0 * t)
		if i % 3 == 0:
			var mid: Vector2 = (trail[i] + trail[i + 1]) * 0.5
			var tp: Vector2 = (trail[i + 1] - trail[i]).normalized().orthogonal()
			draw_line(mid, mid + tp * sin(_time * 20.0 + float(i)) * 6.0 * t, Color(0.7, 0.9, 1.0, t * 0.4), 1.0)

	if fx["exploded"]:
		var t: float = fx["timer"] / 0.5
		var r: float = 60.0 * (1.0 - t)
		draw_circle(p, r, Color(0.5, 0.7, 1.0, t * 0.15))
		draw_circle(p, r * 0.5, Color(0.7, 0.9, 1.0, t * 0.3))
	else:
		draw_circle(p, 16.0, Color(0.5, 0.7, 1.0, 0.06))
		draw_circle(p, 10.0, Color(0.6, 0.8, 1.0, 0.12))

		var vel: Vector2 = fx["vel"]
		var hd: Vector2 = vel.normalized() if vel.length() > 1.0 else Vector2.DOWN
		var hp: Vector2 = hd.orthogonal()
		var hs: float = 8.0
		draw_line(p - hd * hs, p + hd * hs * 1.2, Color(0.5, 0.35, 0.2, 0.8), 2.5)
		var pts := PackedVector2Array([
			p + hp * hs - hd * hs * 0.3, p + hp * hs + hd * hs * 0.4,
			p - hp * hs + hd * hs * 0.4, p - hp * hs - hd * hs * 0.3])
		draw_colored_polygon(pts, Color(0.5, 0.55, 0.65, 0.8))
		draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[0]]),
			Color(0.7, 0.85, 1.0, 0.5), 1.5)
		draw_circle(p, 3.0, Color(0.7, 0.9, 1.0, 0.6))
		draw_circle(p, 1.5, Color(1, 1, 1, 0.8))


func _draw_fx_evo_plague(fx: Dictionary) -> void:
	var cp: Vector2 = _get_char_pos_for_slot(fx.get("char_slot", 0))
	var t: float = fx["timer"] / fx["max_timer"]
	var area: float = fx["area"]

	draw_circle(cp, area, Color(0.2, 0.5, 0.0, 0.05))
	draw_arc(cp, area, 0, TAU, 64, Color(0.3, 0.7, 0.0, 0.12 * t), 2.0)
	draw_arc(cp, area * 0.92, 0, TAU, 48, Color(0.4, 0.8, 0.0, 0.06 * t), 1.5)

	for i in range(6):
		var a: float = _time * 0.2 + (TAU / 6.0) * float(i)
		var inner: Vector2 = cp + Vector2(cos(a), sin(a)) * area * 0.3
		var outer: Vector2 = cp + Vector2(cos(a + 0.3), sin(a + 0.3)) * area * 0.95
		draw_line(inner, outer, Color(0.3, 0.6, 0.0, 0.05 * t), 1.5)

	for i in range(6):
		var a: float = _time * 0.8 + (TAU / 6.0) * float(i)
		var d: float = area * (0.4 + sin(_time * 2.0 + float(i)) * 0.05)
		var bp: Vector2 = cp + Vector2(cos(a), sin(a)) * d
		var pulse: float = sin(_time * 3.0 + float(i)) * 0.3 + 0.7
		draw_circle(bp, 3.0 * pulse, Color(0.3, 0.7, 0.0, 0.2 * t))
		draw_circle(bp, 1.5 * pulse, Color(0.5, 0.9, 0.1, 0.35 * t))
		draw_arc(bp, 3.0 * pulse, 0, TAU, 8, Color(0.4, 0.8, 0.0, 0.15 * t), 1.0)

	for i in range(8):
		var sa: float = _time * 0.15 + (TAU / 8.0) * float(i)
		var sp: Vector2 = cp + Vector2(cos(sa), sin(sa)) * area * 0.85
		_draw_mini_skull(sp, 0.12 * t + 0.08 * sin(_time * 2.0 + float(i)))

	draw_circle(cp, 6.0 * (sin(_time * 4.0) * 0.2 + 0.8), Color(0.3, 0.6, 0.0, 0.08 * t))


func _draw_mini_skull(pos: Vector2, alpha: float) -> void:
	draw_circle(pos, 3.5, Color(0.4, 0.7, 0.0, alpha))
	draw_circle(pos + Vector2(-1.2, -0.8), 0.8, Color(0.1, 0.3, 0.0, alpha * 1.5))
	draw_circle(pos + Vector2(1.2, -0.8), 0.8, Color(0.1, 0.3, 0.0, alpha * 1.5))
	draw_line(pos + Vector2(-0.8, 1.5), pos + Vector2(0.8, 1.5), Color(0.2, 0.4, 0.0, alpha), 0.8)


func _draw_fx_evo_divine(fx: Dictionary) -> void:
	var cp: Vector2 = _get_char_pos_for_slot(fx.get("char_slot", 0))
	var area: float = fx["radius"]
	var oa: float = fx["angle"]

	for i in range(48):
		var a: float = (TAU / 48.0) * float(i)
		var dp: Vector2 = cp + Vector2(cos(a), sin(a)) * area
		draw_circle(dp, 1.2, Color(1.0, 0.9, 0.4, 0.1 + 0.06 * sin(_time * 2.0 + float(i) * 0.5)))

	for i in range(16):
		var a: float = _time * 0.3 + (TAU / 16.0) * float(i)
		var rp: Vector2 = cp + Vector2(cos(a), sin(a)) * area
		draw_line(rp + Vector2(0, -2.5), rp + Vector2(0, 2.5), Color(1.0, 0.9, 0.5, 0.12), 1.0)
		draw_line(rp + Vector2(-1.5, 0), rp + Vector2(1.5, 0), Color(1.0, 0.9, 0.5, 0.12), 1.0)

	var bc: int = 8
	for i in range(bc):
		var angle: float = oa + (TAU / bc) * float(i)
		var pos: Vector2 = cp + Vector2(cos(angle), sin(angle)) * area

		draw_circle(pos, 18.0, Color(1.0, 0.85, 0.3, 0.04))
		var ph: float = 28.0 + 8.0 * sin(_time * 3.0 + float(i))
		draw_line(pos + Vector2(0, -ph), pos + Vector2(0, ph), Color(1.0, 0.95, 0.6, 0.04), 14.0)

		draw_rect(Rect2(pos.x - 5, pos.y - 7, 10, 14), Color(0.96, 0.92, 0.75))
		draw_rect(Rect2(pos.x - 5, pos.y - 7, 10, 14), Color(0.85, 0.7, 0.2), false, 1.5)
		draw_line(Vector2(pos.x, pos.y - 3), Vector2(pos.x, pos.y + 2), Color(0.85, 0.7, 0.2), 1.0)
		draw_line(Vector2(pos.x - 2, pos.y - 1), Vector2(pos.x + 2, pos.y - 1), Color(0.85, 0.7, 0.2), 1.0)

		for r in range(4):
			var ra: float = angle + (float(r) / 4.0) * TAU + _time * 1.5
			var rl: float = 20.0 + 6.0 * sin(_time * 4.0 + float(r))
			draw_line(pos, pos + Vector2(cos(ra), sin(ra)) * rl, Color(1.0, 0.95, 0.6, 0.1), 1.5)
		draw_circle(pos, 3.0, Color(1.0, 0.95, 0.7, 0.6))
		draw_circle(pos, 1.5, Color(1, 1, 1, 0.8))

	var sr: float = 12.0 + 2.0 * sin(_time * 2.0)
	draw_circle(cp, sr, Color(1.0, 0.9, 0.4, 0.04))
	for i in range(6):
		var a: float = _time * 0.5 + (TAU / 6.0) * float(i)
		draw_line(cp + Vector2(cos(a), sin(a)) * 5.0, cp + Vector2(cos(a), sin(a)) * sr,
			Color(1.0, 0.9, 0.5, 0.08), 1.5)


func _draw_fx_evo_void(fx: Dictionary) -> void:
	var p: Vector2 = fx["pos"]
	var trail: Array = fx["trail"]

	for i in range(trail.size() - 1):
		var t: float = 1.0 - float(i) / float(trail.size())
		draw_line(trail[i], trail[i + 1], Color(0.5, 0.0, 0.7, t * 0.08), 7.0 * t)
		draw_line(trail[i], trail[i + 1], Color(0.6, 0.1, 0.9, t * 0.25), 2.5 * t)
		draw_line(trail[i], trail[i + 1], Color(0.8, 0.4, 1.0, t * 0.4), 1.0 * t)
		if i % 2 == 0:
			var mid: Vector2 = (trail[i] + trail[i + 1]) * 0.5
			var perp: Vector2 = (trail[i + 1] - trail[i]).normalized().orthogonal()
			draw_circle(mid + perp * sin(_time * 14.0 + float(i)) * 5.0 * t, 2.0 * t, Color(0.7, 0.2, 1.0, t * 0.5))

	var pulse: float = sin(_time * 12.0) * 0.25 + 0.75
	draw_circle(p, 11.0 * pulse, Color(0.3, 0.0, 0.5, 0.08))
	draw_circle(p, 7.0 * pulse, Color(0.5, 0.0, 0.7, 0.2))
	draw_circle(p, 4.0, Color(0.6, 0.1, 0.9, 0.45))
	draw_circle(p, 2.0, Color(0.9, 0.5, 1.0, 0.7))
	for i in range(4):
		var sa: float = _time * 10.0 + (TAU / 4.0) * float(i)
		var se: Vector2 = p + Vector2(cos(sa), sin(sa)) * 10.0 * pulse
		draw_line(p, se, Color(0.6, 0.1, 0.9, 0.3), 1.0)
	var er: float = 5.0 + sin(_time * 6.0) * 1.5
	draw_arc(p, er, 0, TAU, 12, Color(0.7, 0.2, 1.0, 0.35), 1.0)


# ============ UI overlays ============

func _draw_death_particles_fx() -> void:
	for p in _death_particles:
		var alpha: float = clampf(p["life"] / 0.4, 0.0, 1.0)
		var c: Color = p["color"]
		c.a = alpha
		draw_rect(Rect2(p["pos"].x, p["pos"].y, p["size"], p["size"]), c)


func _draw_vignette(vp: Vector2) -> void:
	draw_rect(Rect2(0, 0, 70, vp.y), Color(0, 0, 0, 0.3))
	draw_rect(Rect2(vp.x - 70, 0, 70, vp.y), Color(0, 0, 0, 0.3))
	draw_rect(Rect2(0, 0, vp.x, 35), Color(0, 0, 0, 0.25))
	draw_rect(Rect2(0, vp.y - 35, vp.x, 35), Color(0, 0, 0, 0.25))
	draw_rect(Rect2(Vector2.ZERO, vp), Color(0.05, 0.0, 0.0, 0.02 + 0.01 * sin(_time * 0.8)))
