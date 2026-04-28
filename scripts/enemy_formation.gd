class_name EnemyFormation

enum Type { LINE, CIRCLE, PINCER, RUSH, V_SHAPE, SPIRAL }

const SPAWN_DISTANCE := 350.0


static func get_positions(formation: int, player_pos: Vector2, count: int) -> Array:
	match formation:
		Type.LINE: return _line(player_pos, count)
		Type.CIRCLE: return _circle(player_pos, count)
		Type.PINCER: return _pincer(player_pos, count)
		Type.RUSH: return _rush(player_pos, count)
		Type.V_SHAPE: return _v_shape(player_pos, count)
		Type.SPIRAL: return _spiral(player_pos, count)
	return []


static func pick_formation(available: Array) -> int:
	return available[randi() % available.size()]


static func _line(player_pos: Vector2, count: int) -> Array:
	var result: Array = []
	var angle := randf() * TAU
	var dir := Vector2(cos(angle), sin(angle))
	var perp := Vector2(-dir.y, dir.x)
	var center := player_pos + dir * SPAWN_DISTANCE
	var spread: float = 30.0
	var half_w: float = float(count - 1) * spread * 0.5
	for i in range(count):
		var offset: float = float(i) * spread - half_w
		result.append({
			"pos": center + perp * offset,
			"rush_target": Vector2.ZERO,
			"delay": 0.0,
		})
	return result


static func _circle(player_pos: Vector2, count: int) -> Array:
	var result: Array = []
	var radius := 250.0
	for i in range(count):
		var angle: float = TAU * float(i) / float(count)
		result.append({
			"pos": player_pos + Vector2(cos(angle), sin(angle)) * radius,
			"rush_target": Vector2.ZERO,
			"delay": 0.0,
		})
	return result


static func _pincer(player_pos: Vector2, count: int) -> Array:
	var result: Array = []
	var angle := randf() * TAU
	var dir := Vector2(cos(angle), sin(angle))
	var perp := Vector2(-dir.y, dir.x)
	var half_count: int = count / 2
	var other := count - half_count
	var spread := 28.0
	for g in range(2):
		var side_dir := dir if g == 0 else -dir
		var center := player_pos + side_dir * SPAWN_DISTANCE
		var n: int = half_count if g == 0 else other
		var half_w: float = float(n - 1) * spread * 0.5
		for i in range(n):
			var offset: float = float(i) * spread - half_w
			result.append({
				"pos": center + perp * offset,
				"rush_target": Vector2.ZERO,
				"delay": 0.0,
			})
	return result


static func _rush(player_pos: Vector2, count: int) -> Array:
	var result: Array = []
	var angle := randf() * TAU
	var dir := Vector2(cos(angle), sin(angle))
	var perp := Vector2(-dir.y, dir.x)
	var center := player_pos + dir * SPAWN_DISTANCE
	var target := player_pos - dir * SPAWN_DISTANCE
	var cols := ceili(sqrt(float(count)))
	var rows := ceili(float(count) / float(cols))
	var spacing := 24.0
	var idx := 0
	for r in range(rows):
		for c in range(cols):
			if idx >= count:
				break
			var off_perp: float = (float(c) - float(cols - 1) * 0.5) * spacing
			var off_dir: float = float(r) * spacing
			result.append({
				"pos": center + perp * off_perp + dir * off_dir,
				"rush_target": target + perp * off_perp + dir * off_dir,
				"delay": 0.0,
			})
			idx += 1
	return result


static func _v_shape(player_pos: Vector2, count: int) -> Array:
	var result: Array = []
	var angle := randf() * TAU
	var dir := Vector2(cos(angle), sin(angle))
	var perp := Vector2(-dir.y, dir.x)
	var tip := player_pos + dir * SPAWN_DISTANCE
	var arm_spacing := 35.0
	var depth_spacing := 40.0
	var half_count: int = count / 2
	for i in range(count):
		var side: int = 0 if i < half_count else 1
		var idx_in_arm: int = i if side == 0 else i - half_count
		var depth: float = float(idx_in_arm) * depth_spacing
		var lateral: float = float(idx_in_arm) * arm_spacing
		if side == 1:
			lateral = -lateral
		result.append({
			"pos": tip + dir * depth + perp * lateral,
			"rush_target": Vector2.ZERO,
			"delay": 0.0,
		})
	return result


static func _spiral(player_pos: Vector2, count: int) -> Array:
	var result: Array = []
	var base_radius := 250.0
	var radius_growth := 15.0
	var angle_step := TAU * 0.22
	var start_angle := randf() * TAU
	for i in range(count):
		var a: float = start_angle + float(i) * angle_step
		var r: float = base_radius + float(i) * radius_growth
		result.append({
			"pos": player_pos + Vector2(cos(a), sin(a)) * r,
			"rush_target": Vector2.ZERO,
			"delay": float(i) * 0.15,
		})
	return result
