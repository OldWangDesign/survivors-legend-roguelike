class_name BgTileGen

const TILE := 32
const _CLEAR := Color(0, 0, 0, 0)

const BG_STYLES := {
	"grassland": "翠绿草原",
	"dungeon": "暗黑地牢",
	"snowfield": "冰封雪原",
	"volcanic": "炽热熔岩",
	"neon_city": "霓虹都市",
	"mystery": "神秘暗夜",
	"matrix": "黑客帝国",
	"eclipse": "日食风暴",
	"terminal": "终端 CLI",
	"macos": "苹果桌面",
	"mario": "超级玛丽",
	"mystery_rune": "暗黑符阵",
	"mystery_skull": "骷髅低语",
	"mystery_void": "虚空之眼",
	"cosmos": "宇宙星空",
	"nature": "自然风光",
	"church": "教堂圣殿",
}


static func generate_style(style: String) -> Array[ImageTexture]:
	match style:
		"grassland": return _gen_grassland()
		"dungeon": return _gen_dungeon()
		"snowfield": return _gen_snowfield()
		"volcanic": return _gen_volcanic()
		"neon_city": return _gen_neon_city()
		"mystery": return _gen_mystery()
		"matrix": return _gen_matrix()
		"eclipse": return _gen_eclipse()
		"terminal": return _gen_terminal()
		"macos": return _gen_macos()
		"mario": return _gen_mario()
		"mystery_rune": return _gen_mystery_rune()
		"mystery_skull": return _gen_mystery_skull()
		"mystery_void": return _gen_mystery_void()
		"cosmos": return _gen_cosmos()
		"nature": return _gen_nature()
		"church": return _gen_church()
	return _gen_grassland()


# ============================================================
#  1. 翠绿草原 (Lush Grassland)
# ============================================================

static func _gen_grassland() -> Array[ImageTexture]:
	var tiles: Array[ImageTexture] = []
	var base_colors := [
		Color(0.16, 0.28, 0.10), Color(0.14, 0.25, 0.09),
		Color(0.18, 0.30, 0.11), Color(0.15, 0.26, 0.08),
	]
	var grass_hi := Color(0.22, 0.38, 0.14)
	var grass_lo := Color(0.11, 0.20, 0.06)
	var flower_colors := [Color(0.90, 0.30, 0.25), Color(0.95, 0.85, 0.20), Color(0.80, 0.40, 0.80)]
	var dirt := Color(0.22, 0.17, 0.10)
	var pebble := Color(0.28, 0.26, 0.22)

	for t in range(6):
		var img := _img(TILE, TILE)
		var bc: Color = base_colors[t % base_colors.size()]
		img.fill(bc)

		var seed_val := t * 7919
		# Grass texture variation
		for i in range(40):
			var h := _hash(seed_val + i * 13, i * 37)
			var x := h % TILE
			var y := (h >> 8) % TILE
			var col: Color = grass_hi if (h % 3 == 0) else grass_lo
			_safe_px(img, x, y, col)

		if t < 3:
			# Grass blade clusters
			for i in range(8 + t * 3):
				var h := _hash(seed_val + i * 53, t + i * 97)
				var x := h % (TILE - 2)
				var y := (h >> 8) % (TILE - 4)
				var col: Color = grass_hi if (h % 2 == 0) else Color(0.20, 0.35, 0.12)
				_safe_px(img, x, y, col)
				_safe_px(img, x, y - 1, col.darkened(0.15))
				if h % 4 == 0:
					_safe_px(img, x + 1, y - 1, col)

			# Occasional flower
			if t == 0:
				for i in range(2):
					var h := _hash(seed_val + i * 131, 999)
					var fx := 4 + h % (TILE - 8)
					var fy := 4 + (h >> 8) % (TILE - 8)
					var fc: Color = flower_colors[h % flower_colors.size()]
					_safe_px(img, fx, fy, fc)
					_safe_px(img, fx + 1, fy, fc)
					_safe_px(img, fx, fy + 1, fc.darkened(0.2))
					_safe_px(img, fx + 1, fy + 1, fc.darkened(0.2))
					_safe_px(img, fx, fy - 1, grass_hi)
		elif t < 5:
			# Dirt path tile
			for y in range(TILE):
				for x in range(TILE):
					var h := _hash(x + t * 100, y + t * 200)
					if h % 5 < 3:
						_safe_px(img, x, y, dirt.lightened(float(h % 10) * 0.01))
			for i in range(4):
				var h := _hash(seed_val + i * 71, t * 31)
				var px := h % TILE
				var py := (h >> 8) % TILE
				_safe_px(img, px, py, pebble)
		else:
			# Pebble scatter
			for i in range(6):
				var h := _hash(seed_val + i * 41, i)
				var px := h % (TILE - 2)
				var py := (h >> 8) % (TILE - 2)
				_safe_px(img, px, py, pebble)
				_safe_px(img, px + 1, py, pebble.darkened(0.1))

		tiles.append(ImageTexture.create_from_image(img))
	return tiles


# ============================================================
#  2. 暗黑地牢 (Dark Dungeon)
# ============================================================

static func _gen_dungeon() -> Array[ImageTexture]:
	var tiles: Array[ImageTexture] = []
	var stone := Color(0.18, 0.18, 0.22)
	var stone_hi := Color(0.25, 0.25, 0.30)
	var stone_lo := Color(0.10, 0.10, 0.14)
	var grout := Color(0.08, 0.08, 0.10)
	var moss := Color(0.12, 0.22, 0.10)
	var puddle := Color(0.10, 0.12, 0.20)

	for t in range(6):
		var img := _img(TILE, TILE)
		img.fill(stone.lightened(float(t % 3) * 0.02))
		var seed_val := t * 6271

		# Brick grid pattern
		var brick_h := 8
		var brick_w := 16
		var offset := (t % 2) * 8
		for y in range(TILE):
			for x in range(TILE):
				var row := y / brick_h
				var bx := (x + offset * row) % TILE
				if y % brick_h == 0 or bx % brick_w == 0:
					_safe_px(img, x, y, grout)

		# Highlight top edge of bricks
		for y in range(1, TILE):
			for x in range(TILE):
				var row := y / brick_h
				var bx := (x + offset * row) % TILE
				if y % brick_h == 1 and bx % brick_w != 0:
					_safe_px(img, x, y, stone_hi)

		# Stone texture noise
		for i in range(20):
			var h := _hash(seed_val + i * 17, i * 53)
			var x := h % TILE
			var y := (h >> 8) % TILE
			_safe_px(img, x, y, stone_lo if h % 2 == 0 else stone_hi)

		if t == 0 or t == 3:
			# Cracks
			var cx := 8 + (seed_val % 12)
			var cy := 8 + ((seed_val >> 4) % 12)
			for i in range(5):
				_safe_px(img, cx + i, cy + (i % 3), grout)
				_safe_px(img, cx + i, cy + (i % 3) + 1, stone_lo)

		if t == 1 or t == 4:
			# Moss patches
			for i in range(3):
				var h := _hash(seed_val + i * 89, 42)
				var mx := h % (TILE - 4)
				var my := (h >> 8) % (TILE - 2)
				_safe_px(img, mx, my, moss)
				_safe_px(img, mx + 1, my, moss.lightened(0.1))
				_safe_px(img, mx, my + 1, moss.darkened(0.15))

		if t == 2 or t == 5:
			# Water puddle
			var h := _hash(seed_val, 77)
			var wx := 6 + h % 12
			var wy := 6 + (h >> 4) % 12
			for dy in range(3):
				for dx in range(4):
					_safe_px(img, wx + dx, wy + dy, puddle)
			_safe_px(img, wx + 1, wy, puddle.lightened(0.15))

		tiles.append(ImageTexture.create_from_image(img))
	return tiles


# ============================================================
#  3. 冰封雪原 (Frozen Snowfield)
# ============================================================

static func _gen_snowfield() -> Array[ImageTexture]:
	var tiles: Array[ImageTexture] = []
	var snow := Color(0.88, 0.90, 0.95)
	var snow_hi := Color(0.95, 0.96, 0.98)
	var snow_lo := Color(0.72, 0.76, 0.85)
	var shadow := Color(0.60, 0.65, 0.78)
	var ice := Color(0.55, 0.78, 0.92)
	var ice_hi := Color(0.75, 0.90, 1.0)
	var frost_grass := Color(0.50, 0.65, 0.55)

	for t in range(6):
		var img := _img(TILE, TILE)
		img.fill(snow.lightened(float(t % 2) * 0.03))
		var seed_val := t * 5381

		# Snow texture
		for i in range(30):
			var h := _hash(seed_val + i * 19, i * 41)
			var x := h % TILE
			var y := (h >> 8) % TILE
			_safe_px(img, x, y, snow_hi if h % 3 == 0 else snow_lo)

		if t < 2:
			# Smooth snow with wind streaks
			for i in range(3):
				var h := _hash(seed_val + i * 67, 13)
				var sy := 4 + (h >> 4) % (TILE - 8)
				var sx := h % (TILE - 10)
				for dx in range(6 + h % 5):
					_safe_px(img, sx + dx, sy, shadow)

		elif t < 4:
			# Snow drifts with shadow
			var h := _hash(seed_val, 29)
			var dx := 4 + h % 10
			var dy := 4 + (h >> 4) % 10
			var dw := 8 + h % 8
			for x in range(dw):
				_safe_px(img, dx + x, dy, snow_hi)
				_safe_px(img, dx + x, dy + 1, snow_hi)
				_safe_px(img, dx + x, dy + 2, shadow)
			# Ice crystals
			if t == 2:
				for i in range(2):
					var ch := _hash(seed_val + i * 113, 7)
					var cx := ch % (TILE - 4)
					var cy := (ch >> 8) % (TILE - 4)
					_safe_px(img, cx + 1, cy, ice)
					_safe_px(img, cx, cy + 1, ice)
					_safe_px(img, cx + 1, cy + 1, ice_hi)
					_safe_px(img, cx + 2, cy + 1, ice)
					_safe_px(img, cx + 1, cy + 2, ice)
		else:
			# Frozen grass tufts
			for i in range(4):
				var h := _hash(seed_val + i * 83, i * 7)
				var gx := h % (TILE - 3)
				var gy := (h >> 8) % (TILE - 4)
				_safe_px(img, gx, gy, frost_grass)
				_safe_px(img, gx + 1, gy, frost_grass.lightened(0.1))
				_safe_px(img, gx, gy - 1, frost_grass.darkened(0.15))
				_safe_px(img, gx + 1, gy - 1, frost_grass)
			# Footprint-like shadows
			if t == 5:
				var h := _hash(seed_val, 53)
				var fx := 8 + h % 10
				var fy := 8 + (h >> 4) % 10
				_safe_px(img, fx, fy, shadow); _safe_px(img, fx + 1, fy, shadow)
				_safe_px(img, fx + 3, fy + 2, shadow); _safe_px(img, fx + 4, fy + 2, shadow)

		tiles.append(ImageTexture.create_from_image(img))
	return tiles


# ============================================================
#  4. 炽热熔岩 (Volcanic) — 深灰底 + 零星岩浆裂缝
# ============================================================

static func _gen_volcanic() -> Array[ImageTexture]:
	var tiles: Array[ImageTexture] = []
	var rock := Color(0.10, 0.08, 0.08)
	var lava := Color(0.90, 0.35, 0.05)
	var lava_dk := Color(0.55, 0.15, 0.02)
	var ember := Color(0.80, 0.50, 0.10)

	for t in range(6):
		var img := _img(TILE, TILE)
		img.fill(rock)
		var seed_val := t * 4937
		# Very sparse texture noise
		for i in range(8):
			var h := _hash(seed_val + i * 23, i * 47)
			_safe_px(img, h % TILE, (h >> 8) % TILE, rock.lightened(0.04))

		if t < 2:
			# Single lava crack line
			var h := _hash(seed_val, 11)
			var cy := 8 + h % 16
			var sx := h % 8
			for j in range(6 + h % 8):
				_safe_px(img, sx + j, cy + (j / 3) % 2, lava)
		elif t < 4:
			# One small ember dot cluster
			var h := _hash(seed_val, 33)
			var ex := 8 + h % 16
			var ey := 8 + (h >> 4) % 16
			_safe_px(img, ex, ey, ember)
			_safe_px(img, ex + 1, ey, lava_dk)
		else:
			# Bare rock, just 2 dark spots
			var h := _hash(seed_val, 55)
			_safe_px(img, h % TILE, (h >> 8) % TILE, rock.darkened(0.1))
			var h2 := _hash(seed_val + 99, 77)
			_safe_px(img, h2 % TILE, (h2 >> 8) % TILE, rock.darkened(0.1))

		tiles.append(ImageTexture.create_from_image(img))
	return tiles


# ============================================================
#  5. 霓虹都市 (Neon City) — 深紫底 + 稀疏网格线
# ============================================================

static func _gen_neon_city() -> Array[ImageTexture]:
	var tiles: Array[ImageTexture] = []
	var floor_dk := Color(0.04, 0.03, 0.08)
	var grid := Color(0.08, 0.06, 0.14)
	var cyan := Color(0.0, 0.60, 0.70)
	var mag := Color(0.65, 0.08, 0.40)

	for t in range(6):
		var img := _img(TILE, TILE)
		img.fill(floor_dk)
		var seed_val := t * 8123

		# Sparse grid (every 16px)
		for y in range(0, TILE, 16):
			for x in range(TILE):
				_safe_px(img, x, y, grid)
		for x in range(0, TILE, 16):
			for y in range(TILE):
				_safe_px(img, x, y, grid)

		if t < 2:
			# One neon accent segment
			var accent: Color = cyan if t == 0 else mag
			var h := _hash(seed_val, 17)
			var ly := (h % 2) * 16
			var seg_start := h % 16
			for x in range(seg_start, mini(seg_start + 8, TILE)):
				_safe_px(img, x, ly, accent)
		elif t < 4:
			# Single bright dot
			var h := _hash(seed_val, 41)
			var col: Color = cyan if t == 2 else mag
			_safe_px(img, h % TILE, (h >> 8) % TILE, col)
		# t==4,5: just grid, nothing extra

		tiles.append(ImageTexture.create_from_image(img))
	return tiles


# ============================================================
#  6. 神秘暗夜 (Mystery Night) — 纯黑底 + 零星暗色点缀
# ============================================================

static func _gen_mystery() -> Array[ImageTexture]:
	var tiles: Array[ImageTexture] = []
	var bg := Color(0.02, 0.02, 0.04)
	var fog := Color(0.07, 0.05, 0.10)
	var rune := Color(0.15, 0.06, 0.20)
	var blood := Color(0.25, 0.02, 0.02)

	for t in range(6):
		var img := _img(TILE, TILE)
		img.fill(bg)
		var seed_val := t * 6661

		# Very sparse fog pixels
		for i in range(6):
			var h := _hash(seed_val + i * 11, i * 29)
			_safe_px(img, h % TILE, (h >> 8) % TILE, fog)

		if t == 0:
			# One blood speck
			var h := _hash(seed_val, 666)
			_safe_px(img, 8 + h % 16, 8 + (h >> 4) % 16, blood)
		elif t == 1:
			# Two tiny rune dots
			var h := _hash(seed_val, 42)
			_safe_px(img, h % TILE, (h >> 8) % TILE, rune)
			var h2 := _hash(seed_val + 50, 43)
			_safe_px(img, h2 % TILE, (h2 >> 8) % TILE, rune)
		elif t == 2:
			# Small circle fragment (5 dots)
			var cx := 16
			var cy := 16
			for ai in range(5):
				var a := float(ai) / 5.0 * TAU
				_safe_px(img, cx + int(cos(a) * 6.0), cy + int(sin(a) * 6.0), rune)
		# t==3,4,5: bare dark ground

		tiles.append(ImageTexture.create_from_image(img))
	return tiles


# ============================================================
#  7. 黑客帝国 (Matrix) — 纯黑底 + 稀疏绿色字符
# ============================================================

static func _gen_matrix() -> Array[ImageTexture]:
	var tiles: Array[ImageTexture] = []
	var bg := Color(0.0, 0.01, 0.0)
	var grn := Color(0.0, 0.30, 0.0)
	var grn_hi := Color(0.0, 0.55, 0.0)

	for t in range(6):
		var img := _img(TILE, TILE)
		img.fill(bg)
		var seed_val := t * 3571

		if t < 3:
			# One code rain column (sparse)
			var h := _hash(seed_val, t * 13)
			var col_x := 4 + (h % 6) * 4
			var start_y := h % 8
			var length := 4 + h % 6
			for dy in range(length):
				var y := (start_y + dy) % TILE
				var fade := 1.0 - float(dy) / float(length)
				var c: Color = grn_hi.lerp(grn, 1.0 - fade)
				if dy == 0:
					c = Color(0.5, 0.9, 0.5)
				var gh := _hash(seed_val + dy, col_x)
				if gh % 3 != 0:
					_safe_px(img, col_x, y, c)
		else:
			# Just 2-3 scattered dim green dots
			for i in range(2 + t % 2):
				var h := _hash(seed_val + i * 47, i * 19)
				_safe_px(img, h % TILE, (h >> 8) % TILE, grn)

		tiles.append(ImageTexture.create_from_image(img))
	return tiles


# ============================================================
#  8. 日食风暴 (Eclipse) — 深空黑底 + 零星星点 + 微弱弧线
# ============================================================

static func _gen_eclipse() -> Array[ImageTexture]:
	var tiles: Array[ImageTexture] = []
	var void_bg := Color(0.01, 0.01, 0.02)
	var corona := Color(0.80, 0.45, 0.08)
	var star := Color(0.50, 0.50, 0.60)

	for t in range(6):
		var img := _img(TILE, TILE)
		img.fill(void_bg)
		var seed_val := t * 7331

		# Very sparse stars (3-4 dots)
		for i in range(3 + t % 2):
			var h := _hash(seed_val + i * 13, i * 41)
			_safe_px(img, h % TILE, (h >> 8) % TILE, star.darkened(float(h % 4) * 0.12))

		if t == 0:
			# Small corona arc fragment (6 dots)
			for ai in range(6):
				var a := float(ai) / 6.0 * TAU * 0.2 + 1.0
				_safe_px(img, 16 + int(cos(a) * 12.0), 16 + int(sin(a) * 12.0), corona)
		elif t == 1:
			# One ember streak
			var h := _hash(seed_val, 37)
			var sx := h % 20
			var sy := (h >> 4) % TILE
			for j in range(4):
				var fade := float(j) / 4.0
				_safe_px(img, sx + j, sy, corona.lerp(void_bg, fade))
		# t>=2: just stars

		tiles.append(ImageTexture.create_from_image(img))
	return tiles


# ============================================================
#  9. 终端 CLI (Terminal) — 纯黑底 + 稀疏绿色文字行
# ============================================================

static func _gen_terminal() -> Array[ImageTexture]:
	var tiles: Array[ImageTexture] = []
	var bg := Color(0.0, 0.0, 0.0)
	var grn := Color(0.0, 0.70, 0.0)
	var grn_dk := Color(0.0, 0.30, 0.0)
	var scan := Color(0.0, 0.04, 0.0)

	for t in range(6):
		var img := _img(TILE, TILE)
		img.fill(bg)
		var seed_val := t * 4219

		# Subtle scan lines (every 4 rows)
		for y in range(0, TILE, 4):
			for x in range(TILE):
				_safe_px(img, x, y, scan)

		if t < 2:
			# One short text line
			var h := _hash(seed_val, 4)
			var ry := 4 + (h >> 4) % 24
			# Prompt "$"
			_safe_px(img, 1, ry, grn); _safe_px(img, 2, ry, grn)
			# A few text pixels
			for i in range(3 + h % 4):
				var ch := _hash(h + i, ry)
				if ch % 3 != 0:
					_safe_px(img, 5 + i * 3, ry, grn_dk)
		elif t < 4:
			# Sparse dim text fragments
			var h := _hash(seed_val, 17)
			var ry := 8 + h % 16
			for i in range(3):
				var ch := _hash(h + i * 7, ry)
				if ch % 2 == 0:
					_safe_px(img, 2 + i * 4, ry, grn_dk)
		# t==4,5: scan lines only

		tiles.append(ImageTexture.create_from_image(img))
	return tiles


# ============================================================
#  10. 苹果桌面 (macOS) — 蓝色渐变底 + 极少装饰
# ============================================================

static func _gen_macos() -> Array[ImageTexture]:
	var tiles: Array[ImageTexture] = []
	var desktop_hi := Color(0.22, 0.38, 0.65)
	var desktop_lo := Color(0.13, 0.25, 0.48)
	var dot := Color(0.30, 0.45, 0.72)

	for t in range(6):
		var img := _img(TILE, TILE)
		var seed_val := t * 2753

		# Gradient fill
		for y in range(TILE):
			var blend := float(y) / float(TILE)
			var row_c: Color = desktop_hi.lerp(desktop_lo, blend)
			for x in range(TILE):
				_safe_px(img, x, y, row_c)

		# Very sparse highlights (1-2 dots)
		if t < 3:
			var h := _hash(seed_val, 7)
			_safe_px(img, h % TILE, (h >> 8) % TILE, dot)
		# Otherwise pure gradient

		tiles.append(ImageTexture.create_from_image(img))
	return tiles


# ============================================================
#  11. 超级玛丽 (Mario) — 天蓝底 + 偶尔一块砖/云
# ============================================================

static func _gen_mario() -> Array[ImageTexture]:
	var tiles: Array[ImageTexture] = []
	var sky := Color(0.40, 0.62, 1.0)
	var brick := Color(0.72, 0.35, 0.10)
	var brick_hi := Color(0.85, 0.48, 0.18)
	var grout := Color(0.30, 0.15, 0.04)
	var cloud := Color(0.92, 0.95, 1.0)
	var ground := Color(0.55, 0.35, 0.12)
	var grass := Color(0.15, 0.60, 0.12)

	for t in range(6):
		var img := _img(TILE, TILE)
		img.fill(sky)
		var _seed_val := t * 8867

		if t == 0:
			# One brick block (8x8) in corner
			for by in range(4, 12):
				for bx in range(4, 12):
					if by == 4 or by == 7 or bx == 4 or bx == 7 or bx == 11:
						_safe_px(img, bx, by, grout)
					elif by == 5:
						_safe_px(img, bx, by, brick_hi)
					else:
						_safe_px(img, bx, by, brick)

		elif t == 1:
			# Small cloud (5x3)
			var cx := 10
			var cy := 8
			_safe_px(img, cx + 1, cy, cloud); _safe_px(img, cx + 2, cy, cloud)
			for dx in range(5):
				_safe_px(img, cx + dx, cy + 1, cloud)
			_safe_px(img, cx + 1, cy + 2, cloud); _safe_px(img, cx + 2, cy + 2, cloud)

		elif t == 2:
			# Ground strip at bottom
			for x in range(TILE):
				_safe_px(img, x, 30, grass)
				_safe_px(img, x, 31, ground)

		# t==3,4,5: pure sky

		tiles.append(ImageTexture.create_from_image(img))
	return tiles


# ============================================================
#  12. 暗黑符阵 (Mystery Rune) — 黑底 + 稀疏符文
# ============================================================

static func _gen_mystery_rune() -> Array[ImageTexture]:
	var tiles: Array[ImageTexture] = []
	var bg := Color(0.02, 0.02, 0.04)
	var rune := Color(0.16, 0.06, 0.22)
	var rune_hi := Color(0.28, 0.10, 0.36)

	for t in range(6):
		var img := _img(TILE, TILE)
		img.fill(bg)
		var seed_val := t * 5779

		if t == 0:
			# Small pentagram (5 line segments, thin)
			var cx := 16.0
			var cy := 16.0
			var r := 10.0
			for pi in range(5):
				var a1 := float(pi) / 5.0 * TAU - PI / 2.0
				var a2 := float((pi + 2) % 5) / 5.0 * TAU - PI / 2.0
				_draw_line(img, int(cx + cos(a1) * r), int(cy + sin(a1) * r),
					int(cx + cos(a2) * r), int(cy + sin(a2) * r), rune)

		elif t == 1:
			# Single rune circle (dots)
			var cx := 16
			var cy := 16
			for ai in range(12):
				var a := float(ai) / 12.0 * TAU
				_safe_px(img, cx + int(cos(a) * 8.0), cy + int(sin(a) * 8.0), rune)
			_safe_px(img, cx, cy, rune_hi)

		elif t == 2:
			# One small cross symbol
			var h := _hash(seed_val, 7)
			var ox := 12 + h % 8
			var oy := 12 + (h >> 4) % 8
			for d in range(5):
				_safe_px(img, ox, oy + d - 2, rune)
				_safe_px(img, ox + d - 2, oy, rune)

		elif t == 3:
			# One small diamond
			var ox := 16
			var oy := 16
			_safe_px(img, ox, oy - 3, rune)
			_safe_px(img, ox - 3, oy, rune); _safe_px(img, ox + 3, oy, rune)
			_safe_px(img, ox, oy + 3, rune)
			_safe_px(img, ox - 1, oy - 2, rune); _safe_px(img, ox + 1, oy - 2, rune)
			_safe_px(img, ox - 2, oy - 1, rune); _safe_px(img, ox + 2, oy - 1, rune)
			_safe_px(img, ox - 2, oy + 1, rune); _safe_px(img, ox + 2, oy + 1, rune)
			_safe_px(img, ox - 1, oy + 2, rune); _safe_px(img, ox + 1, oy + 2, rune)

		# t==4,5: pure dark

		tiles.append(ImageTexture.create_from_image(img))
	return tiles


# ============================================================
#  13. 骷髅低语 (Mystery Skull) — 黑底 + 偶现骷髅轮廓
# ============================================================

static func _gen_mystery_skull() -> Array[ImageTexture]:
	var tiles: Array[ImageTexture] = []
	var bg := Color(0.03, 0.02, 0.04)
	var bone := Color(0.40, 0.36, 0.30)
	var bone_dk := Color(0.22, 0.20, 0.16)
	var eye_c := Color(0.12, 0.30, 0.08)

	for t in range(6):
		var img := _img(TILE, TILE)
		img.fill(bg)
		var seed_val := t * 6637

		if t == 0:
			# One skull face outline
			# Cranium arc
			for ai in range(10):
				var a := float(ai) / 10.0 * PI
				_safe_px(img, 16 + int(cos(a) * 6.0), 10 - int(sin(a) * 4.0), bone_dk)
			# Face sides
			for dy in range(5):
				_safe_px(img, 10, 10 + dy, bone_dk)
				_safe_px(img, 22, 10 + dy, bone_dk)
			# Eye sockets
			_safe_px(img, 13, 11, eye_c); _safe_px(img, 19, 11, eye_c)
			# Jaw line
			for dx in range(-4, 5):
				_safe_px(img, 16 + dx, 15, bone_dk)

		elif t == 1:
			# Single tiny skull (4x4)
			var h := _hash(seed_val, 67)
			var sx := 8 + h % 16
			var sy := 8 + (h >> 8) % 16
			_safe_px(img, sx, sy, bone); _safe_px(img, sx + 1, sy, bone)
			_safe_px(img, sx + 2, sy, bone); _safe_px(img, sx + 3, sy, bone)
			_safe_px(img, sx, sy + 1, bone); _safe_px(img, sx + 3, sy + 1, bone)
			_safe_px(img, sx + 1, sy + 1, bg); _safe_px(img, sx + 2, sy + 1, bg)
			_safe_px(img, sx, sy + 2, bone_dk); _safe_px(img, sx + 1, sy + 2, bone_dk)
			_safe_px(img, sx + 2, sy + 2, bone_dk); _safe_px(img, sx + 3, sy + 2, bone_dk)

		elif t == 2:
			# Circular eye pattern (sparse)
			var cx := 16
			var cy := 16
			for ai in range(8):
				var a := float(ai) / 8.0 * TAU
				_safe_px(img, cx + int(cos(a) * 8.0), cy + int(sin(a) * 8.0), bone_dk)
			_safe_px(img, cx, cy, eye_c)

		elif t == 3:
			# Two scattered bone fragments
			for i in range(2):
				var h := _hash(seed_val + i * 31, i)
				var bx := h % (TILE - 4)
				var by := (h >> 8) % TILE
				_safe_px(img, bx, by, bone); _safe_px(img, bx + 1, by, bone_dk)
				_safe_px(img, bx + 2, by, bone)

		# t==4,5: pure dark

		tiles.append(ImageTexture.create_from_image(img))
	return tiles


# ============================================================
#  14. 虚空之眼 (Mystery Void) — 深黑底 + 稀疏涟漪/星点
# ============================================================

static func _gen_mystery_void() -> Array[ImageTexture]:
	var tiles: Array[ImageTexture] = []
	var void_bg := Color(0.01, 0.01, 0.02)
	var ring := Color(0.08, 0.04, 0.15)
	var ring_hi := Color(0.15, 0.08, 0.25)
	var star := Color(0.35, 0.35, 0.45)
	var portal := Color(0.25, 0.08, 0.40)

	for t in range(6):
		var img := _img(TILE, TILE)
		img.fill(void_bg)
		var seed_val := t * 9137

		# 2-3 dim star dots
		for i in range(2 + t % 2):
			var h := _hash(seed_val + i * 17, i * 43)
			_safe_px(img, h % TILE, (h >> 8) % TILE, star.darkened(float(h % 3) * 0.15))

		if t == 0:
			# One ripple ring (dots)
			var cx := 16
			var cy := 16
			for ai in range(12):
				var a := float(ai) / 12.0 * TAU
				_safe_px(img, cx + int(cos(a) * 10.0), cy + int(sin(a) * 10.0), ring)
			_safe_px(img, cx, cy, portal)

		elif t == 1:
			# Small spiral (sparse)
			var cx := 16.0
			var cy := 16.0
			for i in range(12):
				var angle := float(i) * 0.5
				var radius := float(i) * 0.8
				_safe_px(img, int(cx + cos(angle) * radius), int(cy + sin(angle) * radius), ring_hi)

		elif t == 2:
			# Portal dot cluster
			var cx := 16
			var cy := 16
			_safe_px(img, cx, cy, portal)
			_safe_px(img, cx - 2, cy, ring); _safe_px(img, cx + 2, cy, ring)
			_safe_px(img, cx, cy - 2, ring); _safe_px(img, cx, cy + 2, ring)

		# t==3,4,5: just stars

		tiles.append(ImageTexture.create_from_image(img))
	return tiles


# ============================================================
#  15. 宇宙星空 (Cosmos) — 参考太空实拍：地球弧面/月球/星云
# ============================================================

static func _gen_cosmos() -> Array[ImageTexture]:
	var tiles: Array[ImageTexture] = []
	var space := Color(0.01, 0.01, 0.02)
	var star_dim := Color(0.35, 0.35, 0.45)
	var star_hi := Color(0.80, 0.80, 0.92)
	var star_warm := Color(0.75, 0.65, 0.50)
	var earth_blue := Color(0.12, 0.22, 0.38)
	var _earth_cyan := Color(0.18, 0.40, 0.45)
	var earth_green := Color(0.14, 0.28, 0.18)
	var earth_atmo := Color(0.25, 0.55, 0.70)
	var earth_cloud := Color(0.60, 0.65, 0.70)
	var moon_lt := Color(0.62, 0.60, 0.58)
	var moon_md := Color(0.45, 0.43, 0.40)
	var moon_dk := Color(0.30, 0.28, 0.26)
	var nebula_red := Color(0.20, 0.06, 0.04)
	var nebula_org := Color(0.22, 0.10, 0.05)

	for t in range(6):
		var img := _img(TILE, TILE)
		img.fill(space)
		var seed_val := t * 4421

		# Sparse stars on all tiles
		for i in range(4 + t % 3):
			var h := _hash(seed_val + i * 17, i * 43)
			var sc: Color
			match h % 4:
				0: sc = star_hi
				1: sc = star_dim
				2: sc = star_warm
				_: sc = star_dim.darkened(0.2)
			_safe_px(img, h % TILE, (h >> 8) % TILE, sc)
			# Occasional cross-sparkle on bright stars
			if h % 7 == 0:
				var sx := h % TILE
				var sy := (h >> 8) % TILE
				_safe_px(img, sx + 1, sy, sc.darkened(0.5))
				_safe_px(img, sx - 1, sy, sc.darkened(0.5))
				_safe_px(img, sx, sy + 1, sc.darkened(0.5))
				_safe_px(img, sx, sy - 1, sc.darkened(0.5))

		if t == 0:
			# Earth arc on left edge (curved limb)
			for y in range(TILE):
				var curve_x := int(sqrt(maxf(0.0, 400.0 - float((y - 16) * (y - 16)))))
				curve_x = mini(curve_x - 14, 10)
				if curve_x < 0:
					continue
				for x in range(curve_x + 1):
					var depth := float(x) / float(maxi(curve_x, 1))
					var col: Color
					if x == curve_x:
						col = earth_atmo
					elif y < 10 or y > 24:
						col = earth_blue.lerp(space, 1.0 - depth)
					elif y % 5 < 2:
						col = earth_green.lerp(earth_blue, depth * 0.5)
					else:
						col = earth_blue
					_safe_px(img, x, y, col)
				# Atmosphere glow edge
				if curve_x + 1 < TILE:
					_safe_px(img, curve_x + 1, y, earth_atmo.darkened(0.6))
			# Sparse cloud wisps
			for i in range(2):
				var h := _hash(seed_val + i * 71, 3)
				var cy := 8 + (h >> 4) % 16
				var cx := h % 5
				_safe_px(img, cx, cy, earth_cloud)
				_safe_px(img, cx + 1, cy, earth_cloud.darkened(0.2))

		elif t == 1:
			# Moon (small, off-center)
			var mx := 18
			var my := 12
			var mr := 5.0
			for dy in range(-6, 7):
				for dx in range(-6, 7):
					var dist := sqrt(float(dx * dx + dy * dy))
					if dist <= mr:
						var light := 1.0 - (float(dx) + mr) / (mr * 2.0)
						var col: Color
						if light > 0.6:
							col = moon_lt
						elif light > 0.3:
							col = moon_md
						else:
							col = moon_dk
						# Crater
						var ch := _hash(mx + dx, my + dy)
						if ch % 11 == 0:
							col = col.darkened(0.15)
						_safe_px(img, mx + dx, my + dy, col)
			# Terminator shadow
			for dy in range(-5, 6):
				var tx := mx + 3
				_safe_px(img, tx, my + dy, moon_dk.darkened(0.2))

		elif t == 2:
			# Nebula wisps (reddish-brown, sparse like the image)
			for i in range(3):
				var h := _hash(seed_val + i * 53, 23)
				var nx := 16 + h % 14
				var ny := 8 + (h >> 8) % 16
				for j in range(4 + h % 3):
					var wobble := int(sin(float(j) * 0.9) * 1.5)
					_safe_px(img, nx + j, ny + wobble, nebula_red)
					if j % 2 == 0:
						_safe_px(img, nx + j, ny + wobble + 1, nebula_org)

		elif t == 3:
			# Dense star cluster patch
			for i in range(8):
				var h := _hash(seed_val + i * 31, i * 11)
				var sx := 8 + h % 16
				var sy := 8 + (h >> 8) % 16
				var sc: Color = star_hi if h % 3 == 0 else star_dim
				_safe_px(img, sx, sy, sc)

		# t==4,5: just sparse stars (already drawn above)

		tiles.append(ImageTexture.create_from_image(img))
	return tiles


# ============================================================
#  16. 自然风光 (Nature) — 草地/沙漠/河流混合
# ============================================================

static func _gen_nature() -> Array[ImageTexture]:
	var tiles: Array[ImageTexture] = []
	# Grass colors
	var grass := Color(0.22, 0.42, 0.12)
	var grass_hi := Color(0.30, 0.55, 0.18)
	var grass_dk := Color(0.15, 0.30, 0.08)
	# Sand/desert colors
	var sand := Color(0.72, 0.62, 0.40)
	var sand_hi := Color(0.82, 0.72, 0.50)
	var sand_dk := Color(0.58, 0.48, 0.30)
	# Water/river colors
	var water := Color(0.15, 0.35, 0.55)
	var water_hi := Color(0.25, 0.50, 0.70)
	var water_dk := Color(0.10, 0.25, 0.40)
	# Misc
	var pebble := Color(0.45, 0.42, 0.38)
	var flower_y := Color(0.90, 0.80, 0.20)
	var flower_r := Color(0.85, 0.25, 0.20)

	for t in range(6):
		var img := _img(TILE, TILE)
		var seed_val := t * 3847

		if t == 0:
			# Pure grass tile
			img.fill(grass)
			for i in range(8):
				var h := _hash(seed_val + i * 13, i * 29)
				_safe_px(img, h % TILE, (h >> 8) % TILE, grass_hi if h % 2 == 0 else grass_dk)
			# One small flower
			var fh := _hash(seed_val, 77)
			var fc: Color = flower_y if fh % 2 == 0 else flower_r
			_safe_px(img, 8 + fh % 16, 8 + (fh >> 4) % 16, fc)

		elif t == 1:
			# Pure sand tile
			img.fill(sand)
			for i in range(6):
				var h := _hash(seed_val + i * 19, i * 37)
				_safe_px(img, h % TILE, (h >> 8) % TILE, sand_hi if h % 2 == 0 else sand_dk)
			# One pebble
			var ph := _hash(seed_val, 33)
			_safe_px(img, ph % TILE, (ph >> 8) % TILE, pebble)

		elif t == 2:
			# Pure water tile
			img.fill(water)
			for i in range(5):
				var h := _hash(seed_val + i * 23, i * 41)
				_safe_px(img, h % TILE, (h >> 8) % TILE, water_hi)
			# Light ripple line
			var rh := _hash(seed_val, 55)
			var ry := 8 + rh % 16
			for j in range(4 + rh % 4):
				_safe_px(img, 8 + j * 3, ry, water_hi)

		elif t == 3:
			# Grass-to-sand transition
			img.fill(grass)
			# Sand on right half with soft edge
			for y in range(TILE):
				var edge := 14 + _hash(seed_val + y, 7) % 5
				for x in range(edge, TILE):
					_safe_px(img, x, y, sand)
				# Transition pixel
				if edge > 0 and edge < TILE:
					_safe_px(img, edge, y, grass_dk.lerp(sand_dk, 0.5))
			# Sparse detail
			var h := _hash(seed_val, 11)
			_safe_px(img, h % 12, (h >> 8) % TILE, grass_hi)
			var h2 := _hash(seed_val + 50, 22)
			_safe_px(img, 20 + h2 % 10, (h2 >> 8) % TILE, sand_hi)

		elif t == 4:
			# Grass-to-water (riverbank)
			img.fill(grass)
			# Water on bottom portion
			for y in range(TILE):
				var edge := 18 + _hash(seed_val + y, 13) % 4
				if y >= edge:
					for x in range(TILE):
						_safe_px(img, x, y, water)
				elif y == edge - 1:
					for x in range(TILE):
						_safe_px(img, x, y, water_dk)
			# Bank detail
			var bh := _hash(seed_val, 44)
			_safe_px(img, bh % TILE, 16 + bh % 4, sand_dk)

		else:
			# Sand-to-water (oasis edge)
			img.fill(sand)
			# Water pool in center-bottom
			for y in range(TILE):
				for x in range(TILE):
					var dx := float(x - 16)
					var dy := float(y - 22)
					var dist := dx * dx / 100.0 + dy * dy / 36.0
					if dist <= 1.0:
						_safe_px(img, x, y, water.lerp(water_hi, 1.0 - dist))
					elif dist <= 1.3:
						_safe_px(img, x, y, water_dk)
			# Sand detail
			var sh := _hash(seed_val, 66)
			_safe_px(img, sh % TILE, (sh >> 8) % 16, sand_hi)

		tiles.append(ImageTexture.create_from_image(img))
	return tiles


# ============================================================
#  17. 教堂圣殿 (Church) — 大理石地板 + 彩色玻璃投影
# ============================================================

static func _gen_church() -> Array[ImageTexture]:
	var tiles: Array[ImageTexture] = []
	var marble := Color(0.85, 0.82, 0.78)
	var marble_hi := Color(0.90, 0.88, 0.85)
	var marble_lo := Color(0.78, 0.75, 0.70)
	var grout := Color(0.45, 0.42, 0.38)
	var grout_dk := Color(0.35, 0.32, 0.28)
	var stain_red := Color(0.65, 0.15, 0.12)
	var stain_blue := Color(0.18, 0.25, 0.58)
	var stain_gold := Color(0.72, 0.58, 0.18)
	var cross_col := Color(0.55, 0.50, 0.44)

	for t in range(6):
		var img := _img(TILE, TILE)
		img.fill(marble.lightened(float(t % 3) * 0.015))
		var seed_val := t * 7193

		# Stone slab grid — cross-shaped seams every 16px
		for y in range(TILE):
			if y % 16 == 0 or y % 16 == 15:
				for x in range(TILE):
					_safe_px(img, x, y, grout if y % 16 == 0 else grout_dk)
		for x in range(TILE):
			if x % 16 == 0 or x % 16 == 15:
				for y in range(TILE):
					_safe_px(img, x, y, grout if x % 16 == 0 else grout_dk)

		# Subtle marble veining
		for i in range(12):
			var h := _hash(seed_val + i * 23, i * 59)
			var x := h % TILE
			var y := (h >> 8) % TILE
			_safe_px(img, x, y, marble_hi if h % 3 == 0 else marble_lo)

		if t == 0 or t == 3:
			# Stained glass projection — very sparse colored specks
			var stain_colors := [stain_red, stain_blue, stain_gold]
			var count := 4 if t == 0 else 3
			for i in range(count):
				var h := _hash(seed_val + i * 71, i * 113)
				var sx := 2 + h % (TILE - 4)
				var sy := 2 + (h >> 8) % (TILE - 4)
				if sx % 16 == 0 or sy % 16 == 0:
					continue
				var sc: Color = stain_colors[h % stain_colors.size()]
				_safe_px(img, sx, sy, sc.lightened(0.15))
				if h % 3 == 0:
					_safe_px(img, sx + 1, sy, sc.darkened(0.1))

		elif t == 1 or t == 4:
			# Simple cross pattern
			var h := _hash(seed_val, 37)
			var cx := 6 + h % 12
			var cy := 6 + (h >> 4) % 12
			# Vertical bar (5px)
			for dy in range(-3, 4):
				_safe_px(img, cx, cy + dy, cross_col)
			# Horizontal bar (3px)
			for dx in range(-2, 3):
				_safe_px(img, cx + dx, cy - 1, cross_col)

		# t == 2, 5: clean marble slabs only

		tiles.append(ImageTexture.create_from_image(img))
	return tiles


# ============================================================
#  Helpers
# ============================================================

static func _img(w: int, h: int) -> Image:
	var i := Image.create(w, h, false, Image.FORMAT_RGBA8)
	i.fill(_CLEAR)
	return i

static func _safe_px(img: Image, x: int, y: int, col: Color) -> void:
	if x >= 0 and x < img.get_width() and y >= 0 and y < img.get_height():
		img.set_pixel(x, y, col)

static func _fill_rect(img: Image, x: int, y: int, w: int, h: int, col: Color) -> void:
	var iw := img.get_width()
	var ih := img.get_height()
	for py in range(maxi(y, 0), mini(y + h, ih)):
		for px in range(maxi(x, 0), mini(x + w, iw)):
			img.set_pixel(px, py, col)

static func _hash(x: int, y: int) -> int:
	return absi((x * 73856093) ^ (y * 19349663) ^ (x * y * 83492791))

static func _draw_line(img: Image, x0: int, y0: int, x1: int, y1: int, col: Color) -> void:
	var dx := absi(x1 - x0)
	var dy := -absi(y1 - y0)
	var sx := 1 if x0 < x1 else -1
	var sy := 1 if y0 < y1 else -1
	var err := dx + dy
	var cx := x0
	var cy := y0
	for _step in range(100):
		_safe_px(img, cx, cy, col)
		if cx == x1 and cy == y1:
			break
		var e2 := 2 * err
		if e2 >= dy:
			err += dy
			cx += sx
		if e2 <= dx:
			err += dx
			cy += sy


static func export_style(style: String, base_dir: String) -> int:
	var dir := DirAccess.open("res://")
	if dir:
		dir.make_dir_recursive(base_dir)
	var textures: Array[ImageTexture] = generate_style(style)
	for i in range(textures.size()):
		var im: Image = textures[i].get_image()
		var path: String = base_dir + "tile_" + str(i) + ".png"
		im.save_png(path)
	return textures.size()
