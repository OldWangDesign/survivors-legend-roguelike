extends Node2D

const TILE := 32
const REDRAW_THRESHOLD := 16.0

var _tiles: Array[ImageTexture] = []
var _current_style: String = ""
var _last_cam_pos: Vector2 = Vector2.INF


func _ready() -> void:
	add_to_group("background")
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	load_style(GameData.bg_style)


func load_style(style: String) -> void:
	if style == _current_style and _tiles.size() > 0:
		return
	_current_style = style

	var base_dir: String = "res://assets/bg/" + style + "/"
	var loaded: Array[ImageTexture] = []
	for i in range(6):
		var path: String = base_dir + "tile_" + str(i) + ".png"
		if FileAccess.file_exists(path):
			var abs_path: String = ProjectSettings.globalize_path(path)
			var img := Image.load_from_file(abs_path)
			if img:
				loaded.append(ImageTexture.create_from_image(img))

	if loaded.size() > 0:
		_tiles = loaded
	else:
		_tiles = preload("res://scripts/bg_tile_gen.gd").generate_style(style)
	queue_redraw()


func _process(_delta: float) -> void:
	var cam := get_viewport().get_camera_2d()
	if not cam:
		return
	var cam_pos := cam.global_position
	var redraw_threshold := REDRAW_THRESHOLD * 2.0 if GameData.is_mobile() else REDRAW_THRESHOLD
	if _last_cam_pos.distance_squared_to(cam_pos) > redraw_threshold * redraw_threshold:
		_last_cam_pos = cam_pos
		queue_redraw()


func _draw() -> void:
	if _tiles.is_empty():
		return

	var camera := get_viewport().get_camera_2d()
	if not camera:
		return

	var vp_size := get_viewport_rect().size
	var cam_pos := camera.global_position
	var half := vp_size * 0.5

	var sx: int = int(floor((cam_pos.x - half.x) / TILE)) * TILE - TILE
	var sy: int = int(floor((cam_pos.y - half.y) / TILE)) * TILE - TILE
	var ex: int = int(ceil((cam_pos.x + half.x) / TILE)) * TILE + TILE
	var ey: int = int(ceil((cam_pos.y + half.y) / TILE)) * TILE + TILE

	var tile_count := _tiles.size()
	for tx in range(sx, ex, TILE):
		for ty in range(sy, ey, TILE):
			var h := _tile_hash(tx, ty)
			var idx := h % tile_count
			draw_texture(_tiles[idx], Vector2(tx, ty))


func _tile_hash(x: int, y: int) -> int:
	return absi((x * 73856093) ^ (y * 19349663) ^ (x * y * 83492791))
