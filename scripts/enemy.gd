extends Node2D

var health: float = 10.0
var max_health: float = 10.0
var damage: int = 5
var speed: float = 50.0
var xp_value: int = 1
var enemy_size: float = 10.0
var color: Color = Color.RED
var enemy_type: String = "bat"

var elite_type: String = ""
var armor_reduction: float = 0.0

var _flash_timer: float = 0.0
var _dying: bool = false
var _slow_mult: float = 1.0
var _slow_timer: float = 0.0
var _sprite: Sprite2D
var _anim_frame: int = 0
var _anim_timer: float = 0.0
const ANIM_SPEED := 0.35

var _elite_aura_timer: float = 0.0
var _rush_mode: bool = false
var _rush_target: Vector2 = Vector2.ZERO
var _rush_speed_mult: float = 2.5
var _formation_delay: float = 0.0
const ELITE_AURA_COLORS: Dictionary = {
	"berserk": Color(1.0, 0.2, 0.1, 0.5),
	"armored": Color(0.2, 0.4, 1.0, 0.5),
	"splitter": Color(0.2, 1.0, 0.3, 0.5),
}


func _ready() -> void:
	add_to_group("enemies")
	SpatialGrid.register(self)


func setup(type_key: String, difficulty_mult: float = 1.0) -> void:
	enemy_type = type_key
	var data: Dictionary = GameData.ENEMY_TYPES[type_key]
	max_health = data["health"] * difficulty_mult
	health = max_health
	damage = int(data["damage"] * difficulty_mult)
	speed = data["speed"]
	xp_value = data["xp_value"]
	enemy_size = data["size"]
	color = data["color"]

	_sprite = Sprite2D.new()
	var sprite_data = GameData.sprites.get(type_key)
	if sprite_data is Array and sprite_data.size() > 0:
		_sprite.texture = sprite_data[0]
	elif sprite_data is ImageTexture:
		_sprite.texture = sprite_data
	var sprite_base := 16.0 if type_key != "boss" else 24.0
	_sprite.scale = Vector2.ONE * (enemy_size * 2.0 / sprite_base)
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if type_key == "ghost":
		_sprite.modulate.a = 0.75
	add_child(_sprite)

	_anim_timer = randf() * ANIM_SPEED


func setup_elite(type: String) -> void:
	elite_type = type
	match type:
		"berserk":
			speed *= 2.0
			damage = int(damage * 1.5)
			enemy_size *= 1.3
			xp_value *= 3
			if is_instance_valid(_sprite):
				_sprite.scale *= 1.3
		"armored":
			max_health *= 5.0
			health = max_health
			speed *= 0.7
			armor_reduction = 0.5
			xp_value *= 2
		"splitter":
			xp_value *= 2
			if is_instance_valid(_sprite):
				_sprite.modulate.a = 0.8


func setup_rush(target: Vector2) -> void:
	_rush_mode = true
	_rush_target = target


func setup_formation_delay(delay: float) -> void:
	_formation_delay = delay


func apply_formation_debuff(health_mult: float = 0.5, damage_mult: float = 0.5, xp_mult: float = 0.6) -> void:
	max_health = int(max_health * health_mult)
	health = max_health
	damage = maxi(1, int(damage * damage_mult))
	xp_value = maxi(1, int(xp_value * xp_mult))


func _physics_process(delta: float) -> void:
	if _dying:
		return
	var player := GameData.player_ref
	if not is_instance_valid(player):
		return

	if _formation_delay > 0:
		_formation_delay -= delta
		return

	var move_dir: Vector2
	var move_speed: float = speed * _slow_mult

	if _rush_mode:
		var to_target := _rush_target - global_position
		if to_target.length() < 30.0:
			_rush_mode = false
		else:
			move_dir = to_target.normalized()
			move_speed *= _rush_speed_mult
	
	if not _rush_mode:
		move_dir = (player.global_position - global_position).normalized()

	position += move_dir * move_speed * delta
	SpatialGrid.update_position(self)

	if _slow_timer > 0:
		_slow_timer -= delta
		if _slow_timer <= 0:
			_slow_mult = 1.0

	if is_instance_valid(_sprite):
		_sprite.flip_h = move_dir.x < -0.1

	if _flash_timer > 0:
		_flash_timer -= delta

	_anim_timer += delta
	if _anim_timer >= ANIM_SPEED:
		_anim_timer -= ANIM_SPEED
		_anim_frame = 1 - _anim_frame
		var anim_data = GameData.sprites.get(enemy_type)
		if anim_data is Array and _anim_frame < anim_data.size():
			_sprite.texture = anim_data[_anim_frame]

	if is_instance_valid(_sprite):
		if _flash_timer > 0:
			_sprite.modulate = Color(3, 3, 3)
		elif _slow_mult < 1.0:
			_sprite.modulate = Color(0.5, 0.7, 1.0)
		elif enemy_type == "ghost":
			_sprite.modulate = Color(1, 1, 1, 0.75)
		elif elite_type == "splitter":
			_sprite.modulate = Color(1, 1, 1, 0.8)
		else:
			_sprite.modulate = Color.WHITE

	if elite_type != "":
		_elite_aura_timer += delta

	if _flash_timer > 0 or elite_type != "" or health < max_health:
		queue_redraw()


func _draw() -> void:
	if elite_type != "" and not _dying:
		_draw_elite_aura()

	if health < max_health and not _dying:
		var bar_w := enemy_size * 2.0
		var bar_h := 3.0
		var bar_y := -enemy_size - 6.0
		if elite_type != "":
			bar_h = 4.0
			bar_y -= 2.0
		draw_rect(Rect2(-bar_w / 2, bar_y, bar_w, bar_h), Color(0.08, 0.08, 0.12, 0.8))
		var fill_w := bar_w * (health / max_health)
		var bar_color := Color(0.85, 0.2, 0.2)
		if elite_type != "":
			bar_color = ELITE_AURA_COLORS.get(elite_type, bar_color)
			bar_color.a = 1.0
		draw_rect(Rect2(-bar_w / 2, bar_y, fill_w, bar_h), bar_color)


func _draw_elite_aura() -> void:
	var aura_color: Color = ELITE_AURA_COLORS.get(elite_type, Color.WHITE)
	var pulse: float = 0.3 + (sin(_elite_aura_timer * 3.0) + 1.0) * 0.2
	aura_color.a = pulse
	var radius: float = enemy_size * 1.6
	draw_circle(Vector2.ZERO, radius, aura_color)
	var ring_color := aura_color
	ring_color.a = pulse * 0.6
	var segments := 16
	for i in range(segments):
		var a1: float = TAU * float(i) / float(segments)
		var a2: float = TAU * float(i + 1) / float(segments)
		var p1 := Vector2(cos(a1), sin(a1)) * radius
		var p2 := Vector2(cos(a2), sin(a2)) * radius
		draw_line(p1, p2, ring_color, 1.5)


func take_damage(amount: float) -> void:
	if _dying:
		return
	var effective_amount := amount
	if armor_reduction > 0:
		effective_amount *= (1.0 - armor_reduction)
	health -= effective_amount
	_flash_timer = 0.08
	AudioManager.play("enemy_hit")
	VfxPool.hit_flash(global_position, color, 10.0 + amount * 0.3)
	if health <= 0:
		_die()


func apply_slow(mult: float, duration: float) -> void:
	_slow_mult = minf(_slow_mult, mult)
	_slow_timer = maxf(_slow_timer, duration)


func apply_knockback(force: Vector2) -> void:
	position += force


func _die() -> void:
	_dying = true
	SpatialGrid.unregister(self)
	remove_from_group("enemies")
	GameData.total_kills += 1
	if enemy_type == "boss":
		GameData.boss_kills_this_stage += 1
	var p = GameData.player_ref
	if is_instance_valid(p) and p.has_method("on_enemy_killed"):
		p.on_enemy_killed()
	AudioManager.play("enemy_die")

	if elite_type != "":
		VfxPool.spark_burst(global_position, 16, color, 150.0, 0.6)
		VfxPool.ring_wave(global_position, color, enemy_size * 4.0, 0.4)
	else:
		VfxPool.spark_burst(global_position, 8, color, 100.0, 0.4)
		VfxPool.ring_wave(global_position, color, enemy_size * 3.0, 0.25)

	_spawn_gem()
	_try_spawn_chest()

	if elite_type == "splitter":
		_spawn_split_children()

	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	tween.tween_callback(queue_free)


func _spawn_split_children() -> void:
	var container := GameData.enemies_container
	if not container or not is_instance_valid(container):
		return
	for i in range(3):
		var child := Node2D.new()
		child.set_script(preload("res://scripts/enemy.gd"))
		var angle: float = TAU * float(i) / 3.0
		child.global_position = global_position + Vector2(cos(angle), sin(angle)) * 20.0
		container.add_child(child)
		var diff: float = max_health / (GameData.ENEMY_TYPES[enemy_type]["health"] * 5.0)
		child.setup(enemy_type, diff * 0.5)
		child.enemy_size *= 0.7
		if is_instance_valid(child._sprite):
			child._sprite.scale *= 0.7


func _spawn_gem() -> void:
	var gem_script := preload("res://scripts/experience_gem.gd")
	var gem := Node2D.new()
	gem.set_script(gem_script)
	gem.global_position = global_position
	gem.xp_value = xp_value
	var container := GameData.pickups_container
	if container and is_instance_valid(container):
		container.add_child(gem)


func _try_spawn_chest() -> void:
	var base_chance: float
	if enemy_type == "boss":
		base_chance = GameData.CHEST_DROP_CHANCE_BOSS
	elif elite_type == "armored":
		base_chance = 1.0
	elif elite_type != "":
		base_chance = 0.15
	else:
		base_chance = GameData.CHEST_DROP_CHANCE_NORMAL
	if randf() > base_chance:
		return
	var chest_script := preload("res://scripts/treasure_chest.gd")
	var chest := Node2D.new()
	chest.set_script(chest_script)
	chest.global_position = global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
	chest.setup_random()
	if enemy_type == "boss":
		if randf() < 0.6:
			chest.rarity = chest_script.ChestRarity.EPIC
		else:
			chest.rarity = chest_script.ChestRarity.RARE
	elif elite_type == "armored":
		chest.rarity = chest_script.ChestRarity.RARE
	var container := GameData.pickups_container
	if container and is_instance_valid(container):
		container.add_child(chest)
		AudioManager.play("chest_spawn")
