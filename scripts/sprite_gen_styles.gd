class_name SpriteGenStyles

const _CLEAR := Color(0, 0, 0, 0)
const _OL := Color(0.04, 0.04, 0.08)

# ============================================================
#  Style E — PICO-8 复古 (Retro PICO-8 palette)
#  Ref: pico8wiki.com — bold 16-color NES-like feel
# ============================================================

const _P8_BLACK := Color(0, 0, 0)
const _P8_DBLUE := Color(0.114, 0.169, 0.325)
const _P8_DPURP := Color(0.494, 0.145, 0.325)
const _P8_DGREEN := Color(0, 0.529, 0.318)
const _P8_BROWN := Color(0.671, 0.322, 0.212)
const _P8_DGREY := Color(0.373, 0.341, 0.310)
const _P8_LGREY := Color(0.761, 0.765, 0.780)
const _P8_WHITE := Color(1.0, 0.945, 0.910)
const _P8_RED := Color(1.0, 0, 0.302)
const _P8_ORANGE := Color(1.0, 0.639, 0)
const _P8_YELLOW := Color(1.0, 0.925, 0.153)
const _P8_GREEN := Color(0, 0.894, 0.212)
const _P8_BLUE := Color(0.161, 0.678, 1.0)
const _P8_LAVEN := Color(0.514, 0.463, 0.612)
const _P8_PINK := Color(1.0, 0.467, 0.659)
const _P8_PEACH := Color(1.0, 0.800, 0.667)


static func generate_style_e() -> Dictionary:
	return {
		"player": [_gen_e_player(0), _gen_e_player(1)],
		"bat": [_gen_e_bat(0), _gen_e_bat(1)],
		"skeleton": [_gen_e_skeleton(0), _gen_e_skeleton(1)],
		"zombie": [_gen_e_zombie(0), _gen_e_zombie(1)],
		"ghost": [_gen_e_ghost(0), _gen_e_ghost(1)],
		"boss": [_gen_e_boss(0), _gen_e_boss(1)],
		"gem_small": _gen_gem(_P8_GREEN, _P8_YELLOW, _P8_DGREEN),
		"gem_medium": _gen_gem(_P8_BLUE, _P8_WHITE, _P8_DBLUE),
		"gem_large": _gen_gem(_P8_RED, _P8_PINK, _P8_DPURP),
		"projectile": _gen_colored_proj(_P8_YELLOW, _P8_WHITE, _P8_ORANGE),
	}


static func _gen_e_player(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	# Red cap adventurer
	_fill(img, 5, 0, 6, 1, _P8_DPURP)
	_fill(img, 4, 1, 8, 2, _P8_RED)
	_px(img, 5, 1, _P8_PINK)
	# Face
	_fill(img, 5, 3, 6, 3, _P8_PEACH)
	_px(img, 6, 4, _P8_DBLUE); _px(img, 9, 4, _P8_DBLUE)
	_px(img, 7, 5, _P8_DPURP)
	# Blue tunic
	_fill(img, 4, 6, 8, 4, _P8_BLUE)
	_fill(img, 7, 6, 2, 4, _P8_DBLUE)
	_px(img, 4, 6, _P8_DBLUE); _px(img, 11, 6, _P8_DBLUE)
	# Arms
	_fill(img, 3, 7, 1, 2, _P8_PEACH)
	_fill(img, 12, 7, 1, 2, _P8_PEACH)
	# Belt
	_fill(img, 4, 9, 8, 1, _P8_BROWN)
	_px(img, 7, 9, _P8_YELLOW)
	# Legs
	if frame == 0:
		_fill(img, 5, 10, 6, 3, _P8_BROWN)
		_fill(img, 5, 13, 2, 1, _P8_DGREY)
		_fill(img, 9, 13, 2, 1, _P8_DGREY)
	else:
		_fill(img, 3, 10, 3, 3, _P8_BROWN)
		_fill(img, 10, 10, 3, 3, _P8_BROWN)
		_fill(img, 3, 13, 2, 1, _P8_DGREY)
		_fill(img, 11, 13, 2, 1, _P8_DGREY)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_e_bat(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	if frame == 0:
		_fill(img, 6, 5, 4, 4, _P8_DPURP)
		_fill(img, 7, 4, 2, 1, _P8_DPURP)
		_px(img, 7, 5, _P8_RED); _px(img, 8, 5, _P8_RED)
		_fill(img, 3, 3, 3, 4, _P8_DPURP)
		_fill(img, 1, 2, 2, 3, _P8_LAVEN)
		_px(img, 0, 1, _P8_LAVEN)
		_fill(img, 10, 3, 3, 4, _P8_DPURP)
		_fill(img, 13, 2, 2, 3, _P8_LAVEN)
		_px(img, 15, 1, _P8_LAVEN)
		_px(img, 7, 9, _P8_LAVEN); _px(img, 8, 9, _P8_LAVEN)
	else:
		_fill(img, 6, 4, 4, 4, _P8_DPURP)
		_fill(img, 7, 3, 2, 1, _P8_DPURP)
		_px(img, 7, 4, _P8_RED); _px(img, 8, 4, _P8_RED)
		_fill(img, 3, 6, 3, 4, _P8_DPURP)
		_fill(img, 1, 9, 2, 3, _P8_LAVEN)
		_px(img, 0, 12, _P8_LAVEN)
		_fill(img, 10, 6, 3, 4, _P8_DPURP)
		_fill(img, 13, 9, 2, 3, _P8_LAVEN)
		_px(img, 15, 12, _P8_LAVEN)
		_px(img, 7, 8, _P8_LAVEN); _px(img, 8, 8, _P8_LAVEN)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_e_skeleton(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	_fill(img, 5, 0, 6, 6, _P8_WHITE)
	_fill(img, 6, 0, 4, 1, _P8_LGREY)
	_fill(img, 6, 2, 2, 2, _P8_BLACK); _fill(img, 9, 2, 2, 2, _P8_BLACK)
	_px(img, 6, 2, _P8_LGREY); _px(img, 9, 2, _P8_LGREY)
	_fill(img, 6, 5, 4, 1, _P8_BLACK)
	_px(img, 7, 5, _P8_WHITE); _px(img, 9, 5, _P8_WHITE)
	_fill(img, 7, 6, 2, 5, _P8_LGREY)
	_fill(img, 5, 7, 6, 1, _P8_WHITE); _fill(img, 5, 9, 6, 1, _P8_WHITE)
	if frame == 0:
		_fill(img, 3, 7, 2, 1, _P8_LGREY); _fill(img, 2, 8, 1, 2, _P8_LGREY)
		_fill(img, 11, 7, 2, 1, _P8_LGREY); _fill(img, 13, 8, 1, 2, _P8_LGREY)
	else:
		_fill(img, 3, 7, 2, 1, _P8_LGREY); _fill(img, 2, 7, 1, 2, _P8_LGREY)
		_fill(img, 11, 7, 2, 1, _P8_LGREY); _fill(img, 13, 7, 1, 2, _P8_LGREY)
	_fill(img, 6, 11, 4, 1, _P8_WHITE)
	if frame == 0:
		_fill(img, 6, 12, 1, 3, _P8_LGREY); _fill(img, 9, 12, 1, 3, _P8_LGREY)
	else:
		_fill(img, 5, 12, 1, 3, _P8_LGREY); _fill(img, 10, 12, 1, 3, _P8_LGREY)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_e_zombie(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	_fill(img, 5, 1, 6, 5, _P8_DGREEN)
	_fill(img, 5, 1, 6, 1, _P8_BLACK)
	_px(img, 6, 3, _P8_YELLOW); _px(img, 10, 3, _P8_YELLOW)
	_px(img, 7, 3, _P8_BLACK); _px(img, 10, 4, _P8_BLACK)
	_fill(img, 5, 6, 6, 4, _P8_BROWN)
	_fill(img, 5, 6, 6, 1, _P8_DGREY)
	var ay := 7 if frame == 0 else 6
	_fill(img, 2, ay, 3, 1, _P8_DGREEN); _px(img, 1, ay + 1, _P8_DGREEN)
	_fill(img, 11, ay, 3, 1, _P8_DGREEN); _px(img, 14, ay + 1, _P8_DGREEN)
	if frame == 0:
		_fill(img, 5, 10, 3, 3, _P8_DGREY); _fill(img, 8, 10, 3, 3, _P8_DGREY)
	else:
		_fill(img, 4, 10, 3, 3, _P8_DGREY); _fill(img, 9, 10, 3, 3, _P8_DGREY)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_e_ghost(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	var yo := 0 if frame == 0 else 1
	_fill(img, 6, 1 + yo, 4, 1, _P8_BLUE)
	_fill(img, 5, 2 + yo, 6, 1, _P8_BLUE)
	_fill(img, 4, 3 + yo, 8, 7, _P8_BLUE)
	_fill(img, 5, 2 + yo, 6, 2, _P8_WHITE)
	_px(img, 6, 5 + yo, _P8_BLACK); _px(img, 7, 5 + yo, _P8_BLACK)
	_px(img, 9, 5 + yo, _P8_BLACK); _px(img, 10, 5 + yo, _P8_BLACK)
	_fill(img, 7, 7 + yo, 3, 1, _P8_DBLUE)
	for x in range(4, 12):
		if (10 + yo) < 16:
			img.set_pixel(x, 10 + yo, _CLEAR)
	for x in [5, 7, 9]:
		_px(img, x, 10 + yo, _P8_BLUE)
	for x in [4, 6, 8, 10]:
		_px(img, x, 11 + yo, _P8_DBLUE)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_e_boss(frame: int) -> ImageTexture:
	var img := _img(24, 24)
	_ellipse(img, 11, 12, 9, 8, _P8_RED)
	_ellipse(img, 11, 11, 7, 5, _P8_PINK)
	_ellipse(img, 11, 12, 9, 8, _P8_RED)
	for i in range(6):
		_px(img, 4 - i, 5 - i, _P8_DPURP); _px(img, 5 - i, 5 - i, _P8_RED)
		_px(img, 18 + i, 5 - i, _P8_DPURP); _px(img, 17 + i, 5 - i, _P8_RED)
	var ey := 9 if frame == 0 else 10
	_fill(img, 5, ey, 4, 3, _P8_YELLOW); _fill(img, 14, ey, 4, 3, _P8_YELLOW)
	_fill(img, 6, ey, 2, 2, _P8_WHITE); _fill(img, 15, ey, 2, 2, _P8_WHITE)
	_px(img, 6, ey + 1, _P8_BLACK); _px(img, 15, ey + 1, _P8_BLACK)
	_fill(img, 7, 16, 9, 2, _P8_DPURP)
	for x in range(8, 15, 2):
		_px(img, x, 16, _P8_WHITE)
	_outline(img)
	return ImageTexture.create_from_image(img)


# ============================================================
#  Style F — Sweetie 柔和 (Sweetie-16 palette)
#  Ref: lospec.com/sweetie-16 — warm, friendly
# ============================================================

const _SW_BLK := Color(0.102, 0.110, 0.173)
const _SW_PURP := Color(0.365, 0.153, 0.365)
const _SW_RED := Color(0.694, 0.243, 0.325)
const _SW_ORAN := Color(0.937, 0.490, 0.341)
const _SW_YELL := Color(1.0, 0.804, 0.459)
const _SW_LGRN := Color(0.655, 0.941, 0.439)
const _SW_GRN := Color(0.220, 0.718, 0.392)
const _SW_TEAL := Color(0.145, 0.443, 0.475)
const _SW_DBLU := Color(0.161, 0.212, 0.435)
const _SW_BLU := Color(0.231, 0.365, 0.788)
const _SW_LBLU := Color(0.255, 0.651, 0.965)
const _SW_CYAN := Color(0.451, 0.937, 0.969)
const _SW_WHT := Color(0.957, 0.957, 0.957)
const _SW_LGRY := Color(0.580, 0.690, 0.761)
const _SW_GRY := Color(0.337, 0.424, 0.525)
const _SW_DGRY := Color(0.200, 0.235, 0.341)


static func generate_style_f() -> Dictionary:
	return {
		"player": [_gen_f_player(0), _gen_f_player(1)],
		"bat": [_gen_f_bat(0), _gen_f_bat(1)],
		"skeleton": [_gen_f_skeleton(0), _gen_f_skeleton(1)],
		"zombie": [_gen_f_zombie(0), _gen_f_zombie(1)],
		"ghost": [_gen_f_ghost(0), _gen_f_ghost(1)],
		"boss": [_gen_f_boss(0), _gen_f_boss(1)],
		"gem_small": _gen_gem(_SW_GRN, _SW_LGRN, _SW_TEAL),
		"gem_medium": _gen_gem(_SW_BLU, _SW_LBLU, _SW_DBLU),
		"gem_large": _gen_gem(_SW_RED, _SW_ORAN, _SW_PURP),
		"projectile": _gen_colored_proj(_SW_YELL, _SW_WHT, _SW_ORAN),
	}


static func _gen_f_player(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	# Cute chibi with orange hat
	_fill(img, 5, 0, 6, 1, _SW_RED)
	_fill(img, 4, 1, 8, 2, _SW_ORAN)
	_px(img, 5, 1, _SW_YELL)
	# Big round face
	_fill(img, 4, 3, 8, 4, _SW_YELL)
	_px(img, 4, 3, _SW_ORAN); _px(img, 11, 3, _SW_ORAN)
	# Big eyes
	_fill(img, 5, 4, 2, 2, _SW_WHT)
	_fill(img, 9, 4, 2, 2, _SW_WHT)
	_px(img, 6, 5, _SW_DBLU); _px(img, 10, 5, _SW_DBLU)
	_px(img, 5, 4, _SW_BLU); _px(img, 9, 4, _SW_BLU)
	# Smile
	_px(img, 7, 6, _SW_RED); _px(img, 8, 6, _SW_RED)
	# Body (red tunic)
	_fill(img, 5, 7, 6, 3, _SW_RED)
	_fill(img, 7, 7, 2, 3, _SW_PURP)
	# Arms
	_px(img, 4, 8, _SW_YELL); _px(img, 11, 8, _SW_YELL)
	# Belt
	_fill(img, 5, 9, 6, 1, _SW_YELL)
	# Legs
	if frame == 0:
		_fill(img, 5, 10, 6, 3, _SW_BLU)
		_fill(img, 5, 13, 2, 1, _SW_DBLU)
		_fill(img, 9, 13, 2, 1, _SW_DBLU)
	else:
		_fill(img, 4, 10, 3, 3, _SW_BLU)
		_fill(img, 9, 10, 3, 3, _SW_BLU)
		_fill(img, 4, 13, 2, 1, _SW_DBLU)
		_fill(img, 10, 13, 2, 1, _SW_DBLU)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_f_bat(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	if frame == 0:
		_fill(img, 6, 5, 4, 3, _SW_PURP)
		_fill(img, 7, 4, 2, 1, _SW_RED)
		_px(img, 7, 5, _SW_WHT); _px(img, 8, 5, _SW_WHT)
		_fill(img, 3, 3, 3, 3, _SW_PURP); _fill(img, 1, 2, 2, 2, _SW_RED)
		_fill(img, 10, 3, 3, 3, _SW_PURP); _fill(img, 13, 2, 2, 2, _SW_RED)
		_px(img, 7, 8, _SW_RED)
	else:
		_fill(img, 6, 4, 4, 3, _SW_PURP)
		_fill(img, 7, 3, 2, 1, _SW_RED)
		_px(img, 7, 4, _SW_WHT); _px(img, 8, 4, _SW_WHT)
		_fill(img, 3, 6, 3, 3, _SW_PURP); _fill(img, 1, 8, 2, 3, _SW_RED)
		_fill(img, 10, 6, 3, 3, _SW_PURP); _fill(img, 13, 8, 2, 3, _SW_RED)
		_px(img, 7, 7, _SW_RED)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_f_skeleton(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	_fill(img, 5, 0, 6, 6, _SW_WHT)
	_fill(img, 6, 0, 4, 1, _SW_LGRY)
	_fill(img, 6, 2, 2, 2, _SW_BLK); _fill(img, 9, 2, 2, 2, _SW_BLK)
	_px(img, 6, 2, _SW_LGRY); _px(img, 9, 2, _SW_LGRY)
	_fill(img, 6, 5, 4, 1, _SW_BLK)
	_px(img, 7, 5, _SW_WHT); _px(img, 9, 5, _SW_WHT)
	_fill(img, 7, 6, 2, 5, _SW_LGRY)
	_fill(img, 5, 7, 6, 1, _SW_WHT); _fill(img, 5, 9, 6, 1, _SW_WHT)
	if frame == 0:
		_fill(img, 3, 7, 2, 1, _SW_LGRY); _fill(img, 2, 8, 1, 2, _SW_LGRY)
		_fill(img, 11, 7, 2, 1, _SW_LGRY); _fill(img, 13, 8, 1, 2, _SW_LGRY)
	else:
		_fill(img, 3, 7, 2, 1, _SW_LGRY); _fill(img, 2, 7, 1, 2, _SW_LGRY)
		_fill(img, 11, 7, 2, 1, _SW_LGRY); _fill(img, 13, 7, 1, 2, _SW_LGRY)
	_fill(img, 6, 11, 4, 1, _SW_WHT)
	if frame == 0:
		_fill(img, 6, 12, 1, 3, _SW_LGRY); _fill(img, 9, 12, 1, 3, _SW_LGRY)
	else:
		_fill(img, 5, 12, 1, 3, _SW_LGRY); _fill(img, 10, 12, 1, 3, _SW_LGRY)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_f_zombie(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	_fill(img, 5, 1, 6, 5, _SW_GRN)
	_fill(img, 5, 1, 6, 1, _SW_TEAL)
	_px(img, 6, 3, _SW_YELL); _px(img, 10, 3, _SW_YELL)
	_px(img, 7, 3, _SW_BLK); _px(img, 10, 4, _SW_BLK)
	_fill(img, 5, 6, 6, 4, _SW_GRY)
	_fill(img, 5, 6, 6, 1, _SW_DGRY)
	var ay := 7 if frame == 0 else 6
	_fill(img, 2, ay, 3, 1, _SW_GRN); _px(img, 1, ay + 1, _SW_GRN)
	_fill(img, 11, ay, 3, 1, _SW_GRN); _px(img, 14, ay + 1, _SW_GRN)
	if frame == 0:
		_fill(img, 5, 10, 3, 3, _SW_DGRY); _fill(img, 8, 10, 3, 3, _SW_DGRY)
	else:
		_fill(img, 4, 10, 3, 3, _SW_DGRY); _fill(img, 9, 10, 3, 3, _SW_DGRY)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_f_ghost(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	var yo := 0 if frame == 0 else 1
	_fill(img, 6, 1 + yo, 4, 1, _SW_LBLU)
	_fill(img, 5, 2 + yo, 6, 1, _SW_LBLU)
	_fill(img, 4, 3 + yo, 8, 7, _SW_LBLU)
	_fill(img, 5, 2 + yo, 6, 2, _SW_CYAN)
	_px(img, 6, 5 + yo, _SW_BLK); _px(img, 7, 5 + yo, _SW_BLK)
	_px(img, 9, 5 + yo, _SW_BLK); _px(img, 10, 5 + yo, _SW_BLK)
	# Cute blush
	_px(img, 5, 6 + yo, _SW_ORAN); _px(img, 10, 6 + yo, _SW_ORAN)
	_fill(img, 7, 7 + yo, 3, 1, _SW_DBLU)
	for x in range(4, 12):
		if (10 + yo) < 16:
			img.set_pixel(x, 10 + yo, _CLEAR)
	for x in [5, 7, 9]:
		_px(img, x, 10 + yo, _SW_LBLU)
	for x in [4, 6, 8, 10]:
		_px(img, x, 11 + yo, _SW_BLU)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_f_boss(frame: int) -> ImageTexture:
	var img := _img(24, 24)
	_ellipse(img, 11, 12, 9, 8, _SW_RED)
	_ellipse(img, 11, 11, 7, 5, _SW_ORAN)
	_ellipse(img, 11, 12, 9, 8, _SW_RED)
	for i in range(6):
		_px(img, 4 - i, 5 - i, _SW_PURP); _px(img, 5 - i, 5 - i, _SW_RED)
		_px(img, 18 + i, 5 - i, _SW_PURP); _px(img, 17 + i, 5 - i, _SW_RED)
	var ey := 9 if frame == 0 else 10
	_fill(img, 5, ey, 4, 3, _SW_YELL); _fill(img, 14, ey, 4, 3, _SW_YELL)
	_fill(img, 6, ey, 2, 2, _SW_WHT); _fill(img, 15, ey, 2, 2, _SW_WHT)
	_px(img, 6, ey + 1, _SW_BLK); _px(img, 15, ey + 1, _SW_BLK)
	_fill(img, 7, 16, 9, 2, _SW_PURP)
	for x in range(8, 15, 2):
		_px(img, x, 16, _SW_WHT)
	_outline(img)
	return ImageTexture.create_from_image(img)


# ============================================================
#  Style G — 暗黑哥特 (Dark Gothic)
#  Desaturated darks + blood red accent
# ============================================================

const _GT_BLK := Color(0.06, 0.05, 0.08)
const _GT_DBLU := Color(0.10, 0.10, 0.18)
const _GT_GRY := Color(0.22, 0.22, 0.28)
const _GT_LGRY := Color(0.38, 0.38, 0.45)
const _GT_SILT := Color(0.55, 0.52, 0.58)
const _GT_WHT := Color(0.75, 0.72, 0.78)
const _GT_BLOOD := Color(0.70, 0.08, 0.08)
const _GT_BLOOD_HI := Color(0.88, 0.18, 0.12)
const _GT_BLOOD_DK := Color(0.40, 0.04, 0.04)
const _GT_BONE := Color(0.62, 0.58, 0.52)
const _GT_BONE_DK := Color(0.38, 0.35, 0.30)
const _GT_PURP := Color(0.30, 0.12, 0.38)
const _GT_PURP_HI := Color(0.45, 0.22, 0.55)
const _GT_GREEN := Color(0.15, 0.35, 0.10)
const _GT_GREEN_DK := Color(0.08, 0.20, 0.05)


static func generate_style_g() -> Dictionary:
	return {
		"player": [_gen_g_player(0), _gen_g_player(1)],
		"bat": [_gen_g_bat(0), _gen_g_bat(1)],
		"skeleton": [_gen_g_skeleton(0), _gen_g_skeleton(1)],
		"zombie": [_gen_g_zombie(0), _gen_g_zombie(1)],
		"ghost": [_gen_g_ghost(0), _gen_g_ghost(1)],
		"boss": [_gen_g_boss(0), _gen_g_boss(1)],
		"gem_small": _gen_gem(_GT_GREEN, Color(0.30, 0.55, 0.20), _GT_GREEN_DK),
		"gem_medium": _gen_gem(_GT_BLOOD, _GT_BLOOD_HI, _GT_BLOOD_DK),
		"gem_large": _gen_gem(_GT_PURP, _GT_PURP_HI, Color(0.18, 0.06, 0.22)),
		"projectile": _gen_colored_proj(_GT_BLOOD, _GT_BLOOD_HI, _GT_BLOOD_DK),
	}


static func _gen_g_player(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	# Death knight with dark armor
	_fill(img, 5, 0, 6, 1, _GT_BLK)
	_fill(img, 4, 1, 8, 3, _GT_GRY)
	_px(img, 5, 1, _GT_LGRY); _px(img, 10, 1, _GT_LGRY)
	# Glowing red visor
	_fill(img, 5, 3, 6, 1, _GT_BLK)
	_px(img, 6, 3, _GT_BLOOD); _px(img, 9, 3, _GT_BLOOD)
	# Dark plate armor
	_fill(img, 4, 4, 8, 1, _GT_GRY)
	_fill(img, 4, 5, 8, 5, _GT_DBLU)
	_fill(img, 7, 5, 2, 5, _GT_GRY)
	_px(img, 7, 6, _GT_BLOOD)
	# Pauldrons
	_fill(img, 3, 5, 1, 3, _GT_GRY); _fill(img, 12, 5, 1, 3, _GT_GRY)
	_px(img, 3, 5, _GT_LGRY); _px(img, 12, 5, _GT_LGRY)
	# Belt with skull
	_fill(img, 4, 9, 8, 1, _GT_GRY)
	_px(img, 7, 9, _GT_BONE); _px(img, 8, 9, _GT_BONE)
	if frame == 0:
		_fill(img, 5, 10, 6, 3, _GT_GRY)
		_fill(img, 5, 13, 2, 1, _GT_BLK); _fill(img, 9, 13, 2, 1, _GT_BLK)
	else:
		_fill(img, 3, 10, 3, 3, _GT_GRY); _fill(img, 10, 10, 3, 3, _GT_GRY)
		_fill(img, 3, 13, 2, 1, _GT_BLK); _fill(img, 11, 13, 2, 1, _GT_BLK)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_g_bat(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	if frame == 0:
		_fill(img, 6, 5, 4, 4, _GT_GRY)
		_fill(img, 7, 4, 2, 1, _GT_GRY)
		_px(img, 7, 5, _GT_BLOOD); _px(img, 8, 5, _GT_BLOOD)
		_fill(img, 3, 3, 3, 4, _GT_GRY); _fill(img, 1, 2, 2, 3, _GT_DBLU)
		_px(img, 0, 1, _GT_DBLU)
		_fill(img, 10, 3, 3, 4, _GT_GRY); _fill(img, 13, 2, 2, 3, _GT_DBLU)
		_px(img, 15, 1, _GT_DBLU)
		_px(img, 7, 9, _GT_DBLU); _px(img, 8, 9, _GT_DBLU)
	else:
		_fill(img, 6, 4, 4, 4, _GT_GRY)
		_fill(img, 7, 3, 2, 1, _GT_GRY)
		_px(img, 7, 4, _GT_BLOOD); _px(img, 8, 4, _GT_BLOOD)
		_fill(img, 3, 6, 3, 4, _GT_GRY); _fill(img, 1, 9, 2, 3, _GT_DBLU)
		_px(img, 0, 12, _GT_DBLU)
		_fill(img, 10, 6, 3, 4, _GT_GRY); _fill(img, 13, 9, 2, 3, _GT_DBLU)
		_px(img, 15, 12, _GT_DBLU)
		_px(img, 7, 8, _GT_DBLU); _px(img, 8, 8, _GT_DBLU)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_g_skeleton(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	_fill(img, 5, 0, 6, 6, _GT_BONE)
	_fill(img, 6, 0, 4, 1, _GT_BONE_DK)
	_fill(img, 6, 2, 2, 2, _GT_BLOOD_DK); _fill(img, 9, 2, 2, 2, _GT_BLOOD_DK)
	_px(img, 6, 2, _GT_BONE); _px(img, 9, 2, _GT_BONE)
	# Blood drip from eyes
	_px(img, 7, 4, _GT_BLOOD); _px(img, 10, 4, _GT_BLOOD)
	_fill(img, 6, 5, 4, 1, _GT_BLK)
	_px(img, 7, 5, _GT_BONE); _px(img, 9, 5, _GT_BONE)
	_fill(img, 7, 6, 2, 5, _GT_BONE_DK)
	_fill(img, 5, 7, 6, 1, _GT_BONE); _fill(img, 5, 9, 6, 1, _GT_BONE)
	if frame == 0:
		_fill(img, 3, 7, 2, 1, _GT_BONE_DK); _fill(img, 2, 8, 1, 2, _GT_BONE_DK)
		_fill(img, 11, 7, 2, 1, _GT_BONE_DK); _fill(img, 13, 8, 1, 2, _GT_BONE_DK)
	else:
		_fill(img, 3, 7, 2, 1, _GT_BONE_DK); _fill(img, 2, 7, 1, 2, _GT_BONE_DK)
		_fill(img, 11, 7, 2, 1, _GT_BONE_DK); _fill(img, 13, 7, 1, 2, _GT_BONE_DK)
	_fill(img, 6, 11, 4, 1, _GT_BONE)
	if frame == 0:
		_fill(img, 6, 12, 1, 3, _GT_BONE_DK); _fill(img, 9, 12, 1, 3, _GT_BONE_DK)
	else:
		_fill(img, 5, 12, 1, 3, _GT_BONE_DK); _fill(img, 10, 12, 1, 3, _GT_BONE_DK)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_g_zombie(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	_fill(img, 5, 1, 6, 5, _GT_GREEN)
	_fill(img, 5, 1, 6, 1, _GT_GREEN_DK)
	_px(img, 6, 3, _GT_BLOOD); _px(img, 10, 3, _GT_BLOOD)
	_px(img, 7, 3, _GT_BLK); _px(img, 10, 4, _GT_BLK)
	# Wound
	_px(img, 8, 2, _GT_BLOOD_DK)
	_fill(img, 5, 6, 6, 4, _GT_GRY)
	_fill(img, 5, 6, 6, 1, _GT_DBLU)
	# Blood stain
	_px(img, 7, 7, _GT_BLOOD_DK); _px(img, 8, 8, _GT_BLOOD_DK)
	var ay := 7 if frame == 0 else 6
	_fill(img, 2, ay, 3, 1, _GT_GREEN); _px(img, 1, ay + 1, _GT_GREEN)
	_fill(img, 11, ay, 3, 1, _GT_GREEN); _px(img, 14, ay + 1, _GT_GREEN)
	if frame == 0:
		_fill(img, 5, 10, 3, 3, _GT_DBLU); _fill(img, 8, 10, 3, 3, _GT_DBLU)
	else:
		_fill(img, 4, 10, 3, 3, _GT_DBLU); _fill(img, 9, 10, 3, 3, _GT_DBLU)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_g_ghost(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	var yo := 0 if frame == 0 else 1
	_fill(img, 6, 1 + yo, 4, 1, _GT_SILT)
	_fill(img, 5, 2 + yo, 6, 1, _GT_SILT)
	_fill(img, 4, 3 + yo, 8, 7, _GT_SILT)
	_fill(img, 5, 2 + yo, 6, 2, _GT_WHT)
	_px(img, 6, 5 + yo, _GT_BLK); _px(img, 7, 5 + yo, _GT_BLK)
	_px(img, 9, 5 + yo, _GT_BLK); _px(img, 10, 5 + yo, _GT_BLK)
	# Blood tears
	_px(img, 7, 6 + yo, _GT_BLOOD); _px(img, 10, 6 + yo, _GT_BLOOD)
	_fill(img, 7, 7 + yo, 3, 1, _GT_GRY)
	for x in range(4, 12):
		if (10 + yo) < 16:
			img.set_pixel(x, 10 + yo, _CLEAR)
	for x in [5, 7, 9]:
		_px(img, x, 10 + yo, _GT_SILT)
	for x in [4, 6, 8, 10]:
		_px(img, x, 11 + yo, _GT_GRY)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_g_boss(frame: int) -> ImageTexture:
	var img := _img(24, 24)
	_ellipse(img, 11, 12, 9, 8, _GT_GRY)
	_ellipse(img, 11, 11, 7, 5, _GT_DBLU)
	_ellipse(img, 11, 12, 9, 8, _GT_GRY)
	# Thorned horns
	for i in range(7):
		_px(img, 4 - i, 5 - i, _GT_BLK); _px(img, 5 - i, 5 - i, _GT_GRY)
		_px(img, 18 + i, 5 - i, _GT_BLK); _px(img, 17 + i, 5 - i, _GT_GRY)
	var ey := 9 if frame == 0 else 10
	# Blood-red eyes
	_fill(img, 5, ey, 4, 3, _GT_BLOOD); _fill(img, 14, ey, 4, 3, _GT_BLOOD)
	_fill(img, 6, ey, 2, 2, _GT_BLOOD_HI); _fill(img, 15, ey, 2, 2, _GT_BLOOD_HI)
	_px(img, 6, ey + 1, _GT_BLK); _px(img, 15, ey + 1, _GT_BLK)
	_fill(img, 7, 16, 9, 2, _GT_BLK)
	for x in range(8, 15, 2):
		_px(img, x, 16, _GT_BONE)
	_outline(img)
	return ImageTexture.create_from_image(img)


# ============================================================
#  Style H — 赛博朋克 (Cyberpunk Neon)
#  Dark base + neon cyan/magenta/green
# ============================================================

const _CY_BLK := Color(0.04, 0.02, 0.08)
const _CY_DBLUE := Color(0.06, 0.06, 0.15)
const _CY_GRY := Color(0.18, 0.18, 0.25)
const _CY_LGRY := Color(0.35, 0.35, 0.45)
const _CY_CYAN := Color(0.0, 0.90, 0.95)
const _CY_CYAN_DK := Color(0.0, 0.50, 0.55)
const _CY_MAG := Color(0.95, 0.10, 0.65)
const _CY_MAG_DK := Color(0.55, 0.05, 0.38)
const _CY_NGRN := Color(0.20, 1.0, 0.35)
const _CY_NGRN_DK := Color(0.10, 0.55, 0.18)
const _CY_WHT := Color(0.90, 0.92, 0.95)
const _CY_YELL := Color(1.0, 0.95, 0.20)
const _CY_ORAN := Color(1.0, 0.55, 0.10)


static func generate_style_h() -> Dictionary:
	return {
		"player": [_gen_h_player(0), _gen_h_player(1)],
		"bat": [_gen_h_bat(0), _gen_h_bat(1)],
		"skeleton": [_gen_h_skeleton(0), _gen_h_skeleton(1)],
		"zombie": [_gen_h_zombie(0), _gen_h_zombie(1)],
		"ghost": [_gen_h_ghost(0), _gen_h_ghost(1)],
		"boss": [_gen_h_boss(0), _gen_h_boss(1)],
		"gem_small": _gen_gem(_CY_NGRN, _CY_YELL, _CY_NGRN_DK),
		"gem_medium": _gen_gem(_CY_CYAN, _CY_WHT, _CY_CYAN_DK),
		"gem_large": _gen_gem(_CY_MAG, _CY_WHT, _CY_MAG_DK),
		"projectile": _gen_colored_proj(_CY_CYAN, _CY_WHT, _CY_CYAN_DK),
	}


static func _gen_h_player(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	# Cyber ninja - dark suit + cyan visor
	_fill(img, 5, 0, 6, 1, _CY_GRY)
	_fill(img, 4, 1, 8, 3, _CY_DBLUE)
	_fill(img, 5, 1, 6, 1, _CY_GRY)
	# Visor (glowing cyan)
	_fill(img, 5, 3, 6, 1, _CY_CYAN)
	_px(img, 5, 3, _CY_CYAN_DK); _px(img, 10, 3, _CY_CYAN_DK)
	# Suit body
	_fill(img, 4, 4, 8, 6, _CY_DBLUE)
	_fill(img, 7, 4, 2, 6, _CY_GRY)
	# Neon trim lines
	_px(img, 4, 5, _CY_CYAN); _px(img, 11, 5, _CY_CYAN)
	_px(img, 4, 8, _CY_CYAN); _px(img, 11, 8, _CY_CYAN)
	# Arms
	_fill(img, 3, 5, 1, 3, _CY_GRY)
	_fill(img, 12, 5, 1, 3, _CY_GRY)
	# Belt tech
	_fill(img, 4, 9, 8, 1, _CY_GRY)
	_px(img, 7, 9, _CY_NGRN)
	if frame == 0:
		_fill(img, 5, 10, 6, 3, _CY_DBLUE)
		_fill(img, 5, 13, 2, 1, _CY_GRY); _fill(img, 9, 13, 2, 1, _CY_GRY)
	else:
		_fill(img, 3, 10, 3, 3, _CY_DBLUE); _fill(img, 10, 10, 3, 3, _CY_DBLUE)
		_fill(img, 3, 13, 2, 1, _CY_GRY); _fill(img, 11, 13, 2, 1, _CY_GRY)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_h_bat(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	# Drone-like flying enemy
	if frame == 0:
		_fill(img, 6, 5, 4, 3, _CY_GRY)
		_fill(img, 7, 4, 2, 1, _CY_LGRY)
		_px(img, 7, 5, _CY_MAG); _px(img, 8, 5, _CY_MAG)
		_fill(img, 3, 4, 3, 2, _CY_LGRY); _fill(img, 1, 3, 2, 2, _CY_GRY)
		_fill(img, 10, 4, 3, 2, _CY_LGRY); _fill(img, 13, 3, 2, 2, _CY_GRY)
		_px(img, 7, 8, _CY_MAG_DK)
	else:
		_fill(img, 6, 4, 4, 3, _CY_GRY)
		_fill(img, 7, 3, 2, 1, _CY_LGRY)
		_px(img, 7, 4, _CY_MAG); _px(img, 8, 4, _CY_MAG)
		_fill(img, 3, 6, 3, 2, _CY_LGRY); _fill(img, 1, 7, 2, 3, _CY_GRY)
		_fill(img, 10, 6, 3, 2, _CY_LGRY); _fill(img, 13, 7, 2, 3, _CY_GRY)
		_px(img, 7, 7, _CY_MAG_DK)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_h_skeleton(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	# Mech skeleton
	_fill(img, 5, 0, 6, 6, _CY_LGRY)
	_fill(img, 6, 0, 4, 1, _CY_GRY)
	_fill(img, 6, 2, 2, 2, _CY_BLK); _fill(img, 9, 2, 2, 2, _CY_BLK)
	# Glowing eyes
	_px(img, 7, 2, _CY_NGRN); _px(img, 10, 2, _CY_NGRN)
	_fill(img, 6, 5, 4, 1, _CY_BLK)
	_px(img, 7, 5, _CY_LGRY); _px(img, 9, 5, _CY_LGRY)
	_fill(img, 7, 6, 2, 5, _CY_GRY)
	_fill(img, 5, 7, 6, 1, _CY_LGRY); _fill(img, 5, 9, 6, 1, _CY_LGRY)
	# Neon rib glow
	_px(img, 7, 7, _CY_CYAN_DK); _px(img, 8, 9, _CY_CYAN_DK)
	if frame == 0:
		_fill(img, 3, 7, 2, 1, _CY_GRY); _fill(img, 2, 8, 1, 2, _CY_GRY)
		_fill(img, 11, 7, 2, 1, _CY_GRY); _fill(img, 13, 8, 1, 2, _CY_GRY)
	else:
		_fill(img, 3, 7, 2, 1, _CY_GRY); _fill(img, 2, 7, 1, 2, _CY_GRY)
		_fill(img, 11, 7, 2, 1, _CY_GRY); _fill(img, 13, 7, 1, 2, _CY_GRY)
	_fill(img, 6, 11, 4, 1, _CY_LGRY)
	if frame == 0:
		_fill(img, 6, 12, 1, 3, _CY_GRY); _fill(img, 9, 12, 1, 3, _CY_GRY)
	else:
		_fill(img, 5, 12, 1, 3, _CY_GRY); _fill(img, 10, 12, 1, 3, _CY_GRY)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_h_zombie(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	# Corrupted android
	_fill(img, 5, 1, 6, 5, _CY_GRY)
	_fill(img, 5, 1, 6, 1, _CY_DBLUE)
	_px(img, 6, 3, _CY_MAG); _px(img, 10, 3, _CY_MAG)
	_px(img, 7, 3, _CY_BLK); _px(img, 10, 4, _CY_BLK)
	# Glitch lines
	_px(img, 8, 2, _CY_NGRN); _px(img, 5, 4, _CY_MAG_DK)
	_fill(img, 5, 6, 6, 4, _CY_DBLUE)
	_fill(img, 5, 6, 6, 1, _CY_GRY)
	# Circuit patterns
	_px(img, 7, 7, _CY_CYAN_DK); _px(img, 9, 8, _CY_CYAN_DK)
	var ay := 7 if frame == 0 else 6
	_fill(img, 2, ay, 3, 1, _CY_GRY); _px(img, 1, ay + 1, _CY_GRY)
	_fill(img, 11, ay, 3, 1, _CY_GRY); _px(img, 14, ay + 1, _CY_GRY)
	if frame == 0:
		_fill(img, 5, 10, 3, 3, _CY_GRY); _fill(img, 8, 10, 3, 3, _CY_GRY)
	else:
		_fill(img, 4, 10, 3, 3, _CY_GRY); _fill(img, 9, 10, 3, 3, _CY_GRY)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_h_ghost(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	var yo := 0 if frame == 0 else 1
	# Hologram ghost
	_fill(img, 6, 1 + yo, 4, 1, _CY_CYAN)
	_fill(img, 5, 2 + yo, 6, 1, _CY_CYAN)
	_fill(img, 4, 3 + yo, 8, 7, _CY_CYAN)
	_fill(img, 5, 2 + yo, 6, 2, _CY_WHT)
	_px(img, 6, 5 + yo, _CY_BLK); _px(img, 7, 5 + yo, _CY_BLK)
	_px(img, 9, 5 + yo, _CY_BLK); _px(img, 10, 5 + yo, _CY_BLK)
	_fill(img, 7, 7 + yo, 3, 1, _CY_CYAN_DK)
	# Scan lines
	for x in range(4, 12):
		if (6 + yo) < 16 and x % 2 == 0:
			_px(img, x, 6 + yo, _CY_CYAN_DK)
		if (8 + yo) < 16 and x % 2 == 1:
			_px(img, x, 8 + yo, _CY_CYAN_DK)
	for x in range(4, 12):
		if (10 + yo) < 16:
			img.set_pixel(x, 10 + yo, _CLEAR)
	for x in [5, 7, 9]:
		_px(img, x, 10 + yo, _CY_CYAN)
	for x in [4, 6, 8, 10]:
		_px(img, x, 11 + yo, _CY_CYAN_DK)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_h_boss(frame: int) -> ImageTexture:
	var img := _img(24, 24)
	# Mech boss
	_ellipse(img, 11, 12, 9, 8, _CY_GRY)
	_ellipse(img, 11, 11, 7, 5, _CY_DBLUE)
	_ellipse(img, 11, 12, 9, 8, _CY_GRY)
	# Antenna horns
	for i in range(6):
		_px(img, 4 - i, 5 - i, _CY_LGRY); _px(img, 5 - i, 5 - i, _CY_GRY)
		_px(img, 18 + i, 5 - i, _CY_LGRY); _px(img, 17 + i, 5 - i, _CY_GRY)
	# Neon tips
	_px(img, -1, 0, _CY_MAG); _px(img, 23, 0, _CY_MAG)
	var ey := 9 if frame == 0 else 10
	_fill(img, 5, ey, 4, 3, _CY_MAG); _fill(img, 14, ey, 4, 3, _CY_MAG)
	_fill(img, 6, ey, 2, 2, _CY_WHT); _fill(img, 15, ey, 2, 2, _CY_WHT)
	_px(img, 6, ey + 1, _CY_BLK); _px(img, 15, ey + 1, _CY_BLK)
	# Tech mouth
	_fill(img, 7, 16, 9, 2, _CY_DBLUE)
	for x in range(7, 16):
		if x % 2 == 0:
			_px(img, x, 16, _CY_CYAN_DK)
		else:
			_px(img, x, 17, _CY_NGRN_DK)
	_outline(img)
	return ImageTexture.create_from_image(img)


# ============================================================
#  Style I — 神秘幸存者 (Mystery Survivor)
#  White-shirt-jeans protagonist + zombie-style monsters
# ============================================================

const _MY_BLK := Color(0.02, 0.02, 0.04)
const _MY_DKGRY := Color(0.10, 0.10, 0.12)
const _MY_GRY := Color(0.25, 0.25, 0.28)
const _MY_LGRY := Color(0.40, 0.40, 0.44)
const _MY_WHT := Color(0.92, 0.90, 0.88)
const _MY_SKIN := Color(0.76, 0.63, 0.52)
const _MY_SKIN_DK := Color(0.60, 0.48, 0.38)
const _MY_SHIRT := Color(0.88, 0.86, 0.84)
const _MY_SHIRT_HI := Color(0.96, 0.95, 0.94)
const _MY_JEANS := Color(0.20, 0.30, 0.50)
const _MY_JEANS_DK := Color(0.14, 0.22, 0.38)
const _MY_BELT := Color(0.22, 0.16, 0.10)
const _MY_SHOE := Color(0.15, 0.12, 0.10)
const _MY_HAIR := Color(0.12, 0.08, 0.06)
const _MY_ZGRN := Color(0.28, 0.38, 0.22)
const _MY_ZGRN_DK := Color(0.18, 0.26, 0.14)
const _MY_ZGRN_LT := Color(0.38, 0.48, 0.30)
const _MY_BLOOD := Color(0.50, 0.08, 0.06)
const _MY_BLOOD_DK := Color(0.30, 0.04, 0.04)
const _MY_BONE := Color(0.72, 0.68, 0.60)
const _MY_BONE_DK := Color(0.52, 0.48, 0.40)
const _MY_EYE_RED := Color(0.80, 0.15, 0.08)
const _MY_EYE_YLW := Color(0.85, 0.70, 0.10)
const _MY_PURPLE := Color(0.30, 0.10, 0.35)
const _MY_PURPLE_DK := Color(0.18, 0.06, 0.22)
const _MY_TEAL := Color(0.10, 0.30, 0.28)


static func generate_style_i() -> Dictionary:
	return {
		"player": [_gen_i_player(0), _gen_i_player(1)],
		"bat": [_gen_i_bat(0), _gen_i_bat(1)],
		"skeleton": [_gen_i_skeleton(0), _gen_i_skeleton(1)],
		"zombie": [_gen_i_zombie(0), _gen_i_zombie(1)],
		"ghost": [_gen_i_ghost(0), _gen_i_ghost(1)],
		"boss": [_gen_i_boss(0), _gen_i_boss(1)],
		"gem_small": _gen_gem(_MY_PURPLE, _MY_EYE_RED, _MY_PURPLE_DK),
		"gem_medium": _gen_gem(_MY_TEAL, _MY_WHT, _MY_BLK),
		"gem_large": _gen_gem(_MY_BLOOD, _MY_EYE_YLW, _MY_BLOOD_DK),
		"projectile": _gen_colored_proj(_MY_EYE_YLW, _MY_WHT, _MY_BLOOD),
	}


static func _gen_i_player(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	# Dark brown hair
	_fill(img, 5, 0, 6, 1, _MY_HAIR)
	_fill(img, 4, 1, 8, 2, _MY_HAIR)
	_px(img, 4, 0, _MY_HAIR); _px(img, 11, 0, _MY_HAIR)
	# Face
	_fill(img, 5, 3, 6, 3, _MY_SKIN)
	_fill(img, 4, 3, 1, 2, _MY_SKIN)
	_fill(img, 11, 3, 1, 2, _MY_SKIN)
	# Eyes
	_px(img, 6, 4, _MY_BLK); _px(img, 9, 4, _MY_BLK)
	_px(img, 7, 4, Color(0.30, 0.20, 0.12)); _px(img, 10, 4, Color(0.30, 0.20, 0.12))
	# Mouth
	_px(img, 7, 5, _MY_SKIN_DK); _px(img, 8, 5, _MY_SKIN_DK)
	# White shirt with collar
	_fill(img, 4, 6, 8, 3, _MY_SHIRT)
	_px(img, 7, 6, _MY_SHIRT_HI); _px(img, 8, 6, _MY_SHIRT_HI)
	# Collar V-shape
	_px(img, 7, 6, _MY_SKIN); _px(img, 8, 6, _MY_SKIN)
	_px(img, 6, 6, _MY_SHIRT_HI); _px(img, 9, 6, _MY_SHIRT_HI)
	# Shadow on shirt
	_px(img, 5, 8, _MY_GRY); _px(img, 10, 8, _MY_GRY)
	# Arms (shirt sleeves + skin hands)
	_fill(img, 3, 7, 1, 1, _MY_SHIRT)
	_fill(img, 12, 7, 1, 1, _MY_SHIRT)
	_fill(img, 2, 8, 1, 1, _MY_SKIN)
	_fill(img, 13, 8, 1, 1, _MY_SKIN)
	# Belt
	_fill(img, 4, 9, 8, 1, _MY_BELT)
	_px(img, 7, 9, _MY_LGRY)
	# Jeans
	if frame == 0:
		_fill(img, 5, 10, 6, 3, _MY_JEANS)
		_fill(img, 7, 10, 2, 3, _MY_JEANS_DK)
		_fill(img, 5, 13, 2, 1, _MY_SHOE)
		_fill(img, 9, 13, 2, 1, _MY_SHOE)
	else:
		_fill(img, 3, 10, 3, 3, _MY_JEANS)
		_fill(img, 10, 10, 3, 3, _MY_JEANS)
		_fill(img, 4, 10, 1, 3, _MY_JEANS_DK)
		_fill(img, 11, 10, 1, 3, _MY_JEANS_DK)
		_fill(img, 3, 13, 2, 1, _MY_SHOE)
		_fill(img, 11, 13, 2, 1, _MY_SHOE)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_i_bat(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	# Undead bat with torn wings
	var yo := 0 if frame == 0 else 1
	# Body
	_fill(img, 6, 5 + yo, 4, 4, _MY_ZGRN_DK)
	_fill(img, 7, 5 + yo, 2, 3, _MY_ZGRN)
	# Eyes
	_px(img, 7, 6 + yo, _MY_EYE_RED); _px(img, 8, 6 + yo, _MY_EYE_RED)
	# Fangs
	_px(img, 7, 8 + yo, _MY_BONE); _px(img, 8, 8 + yo, _MY_BONE)
	# Wings
	if frame == 0:
		_fill(img, 1, 4, 5, 1, _MY_ZGRN_DK)
		_fill(img, 10, 4, 5, 1, _MY_ZGRN_DK)
		_fill(img, 0, 5, 3, 3, _MY_ZGRN_DK)
		_fill(img, 13, 5, 3, 3, _MY_ZGRN_DK)
		# Torn holes in wings
		_px(img, 1, 6, _CLEAR); _px(img, 14, 6, _CLEAR)
		# Membrane
		_px(img, 2, 6, _MY_ZGRN); _px(img, 13, 6, _MY_ZGRN)
	else:
		_fill(img, 2, 3, 4, 1, _MY_ZGRN_DK)
		_fill(img, 10, 3, 4, 1, _MY_ZGRN_DK)
		_fill(img, 1, 4, 3, 2, _MY_ZGRN_DK)
		_fill(img, 12, 4, 3, 2, _MY_ZGRN_DK)
		_px(img, 2, 5, _CLEAR); _px(img, 13, 5, _CLEAR)
	# Blood drip
	_px(img, 7, 9 + yo, _MY_BLOOD)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_i_skeleton(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	# Reanimated skeleton with grave dirt
	# Skull
	_fill(img, 5, 1, 6, 4, _MY_BONE)
	_fill(img, 6, 0, 4, 1, _MY_BONE)
	# Eye sockets
	_fill(img, 6, 2, 2, 2, _MY_BLK)
	_fill(img, 9, 2, 2, 2, _MY_BLK)
	_px(img, 6, 2, _MY_EYE_RED); _px(img, 9, 2, _MY_EYE_RED)
	# Jaw cracks
	_px(img, 7, 4, _MY_BLK); _px(img, 8, 4, _MY_BONE_DK); _px(img, 9, 4, _MY_BLK)
	# Neck
	_fill(img, 7, 5, 2, 1, _MY_BONE_DK)
	# Ribcage
	_fill(img, 5, 6, 6, 4, _MY_BONE_DK)
	_fill(img, 6, 6, 4, 1, _MY_BONE); _fill(img, 6, 8, 4, 1, _MY_BONE)
	# Grave dirt on body
	_px(img, 5, 8, _MY_ZGRN_DK); _px(img, 10, 7, _MY_ZGRN_DK)
	_px(img, 8, 9, _MY_ZGRN_DK)
	# Arms
	if frame == 0:
		_fill(img, 3, 7, 2, 1, _MY_BONE); _fill(img, 2, 8, 1, 2, _MY_BONE)
		_fill(img, 11, 7, 2, 1, _MY_BONE); _fill(img, 13, 8, 1, 2, _MY_BONE)
	else:
		_fill(img, 3, 6, 2, 1, _MY_BONE); _fill(img, 2, 7, 1, 2, _MY_BONE)
		_fill(img, 11, 6, 2, 1, _MY_BONE); _fill(img, 13, 7, 1, 2, _MY_BONE)
	# Legs
	if frame == 0:
		_fill(img, 6, 10, 1, 4, _MY_BONE); _fill(img, 9, 10, 1, 4, _MY_BONE)
	else:
		_fill(img, 5, 10, 1, 4, _MY_BONE); _fill(img, 10, 10, 1, 4, _MY_BONE)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_i_zombie(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	# Classic zombie with torn clothes
	# Head
	_fill(img, 5, 1, 6, 4, _MY_ZGRN)
	_fill(img, 6, 0, 4, 1, _MY_ZGRN_DK)
	# Patchy skin
	_px(img, 6, 1, _MY_ZGRN_LT); _px(img, 9, 2, _MY_ZGRN_DK)
	_px(img, 5, 3, _MY_ZGRN_DK)
	# Eyes (one normal, one hanging)
	_px(img, 6, 2, _MY_EYE_YLW); _px(img, 9, 2, _MY_BLK)
	_px(img, 10, 3, _MY_EYE_YLW)
	# Mouth with exposed teeth
	_fill(img, 6, 4, 4, 1, _MY_BLOOD_DK)
	_px(img, 7, 4, _MY_BONE); _px(img, 9, 4, _MY_BONE)
	# Neck
	_fill(img, 7, 5, 2, 1, _MY_ZGRN_DK)
	# Torn shirt/rags (was once clothing)
	_fill(img, 4, 6, 8, 4, _MY_DKGRY)
	_fill(img, 5, 6, 6, 1, _MY_GRY)
	# Tears in clothing
	_px(img, 6, 8, _MY_ZGRN); _px(img, 9, 7, _MY_ZGRN)
	_px(img, 5, 9, _MY_ZGRN_DK)
	# Blood stains
	_px(img, 7, 8, _MY_BLOOD); _px(img, 10, 9, _MY_BLOOD)
	# Arms (outstretched zombie pose)
	var ay := 7 if frame == 0 else 6
	_fill(img, 1, ay, 3, 1, _MY_ZGRN)
	_fill(img, 12, ay, 3, 1, _MY_ZGRN)
	_px(img, 0, ay, _MY_ZGRN_DK)
	_px(img, 15, ay, _MY_ZGRN_DK)
	# Legs
	if frame == 0:
		_fill(img, 5, 10, 3, 3, _MY_JEANS_DK)
		_fill(img, 8, 10, 3, 3, _MY_JEANS_DK)
		# Torn jeans
		_px(img, 6, 12, _MY_ZGRN)
		_fill(img, 5, 13, 2, 1, _MY_SHOE)
		_fill(img, 9, 13, 2, 1, _MY_SHOE)
	else:
		_fill(img, 4, 10, 3, 3, _MY_JEANS_DK)
		_fill(img, 9, 10, 3, 3, _MY_JEANS_DK)
		_px(img, 10, 12, _MY_ZGRN)
		_fill(img, 4, 13, 2, 1, _MY_SHOE)
		_fill(img, 10, 13, 2, 1, _MY_SHOE)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_i_ghost(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	var yo := 0 if frame == 0 else 1
	# Wraith / spectral ghost with dark energy
	_fill(img, 6, 1 + yo, 4, 1, _MY_PURPLE)
	_fill(img, 5, 2 + yo, 6, 1, _MY_PURPLE)
	_fill(img, 4, 3 + yo, 8, 7, _MY_PURPLE)
	_fill(img, 5, 2 + yo, 6, 3, _MY_PURPLE_DK)
	# Hollow eyes
	_px(img, 6, 4 + yo, _MY_EYE_RED); _px(img, 7, 4 + yo, _MY_EYE_RED)
	_px(img, 9, 4 + yo, _MY_EYE_RED); _px(img, 10, 4 + yo, _MY_EYE_RED)
	# Wailing mouth
	_fill(img, 7, 6 + yo, 3, 2, _MY_BLK)
	_px(img, 8, 6 + yo, _MY_PURPLE_DK)
	# Wispy bottom
	for x in range(4, 12):
		if (10 + yo) < 16:
			img.set_pixel(x, 10 + yo, _CLEAR)
	for x in [5, 7, 9, 11]:
		_px(img, x, 10 + yo, _MY_PURPLE)
	for x in [4, 6, 8, 10]:
		_px(img, x, 11 + yo, _MY_PURPLE_DK)
	for x in [5, 7, 9]:
		_px(img, x, 12 + yo, _MY_PURPLE)
	# Tattered energy tendrils
	_px(img, 3, 5 + yo, _MY_PURPLE_DK); _px(img, 12, 6 + yo, _MY_PURPLE_DK)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_i_boss(frame: int) -> ImageTexture:
	var img := _img(24, 24)
	# Giant zombie abomination
	# Massive head
	_ellipse(img, 11, 7, 7, 6, _MY_ZGRN)
	_fill(img, 7, 2, 8, 3, _MY_ZGRN_DK)
	# Patchy rotting skin
	_px(img, 8, 4, _MY_ZGRN_LT); _px(img, 14, 5, _MY_ZGRN_LT)
	_px(img, 10, 3, _MY_ZGRN_DK); _px(img, 6, 7, _MY_ZGRN_DK)
	# Glowing eyes
	var ey := 6 if frame == 0 else 7
	_fill(img, 7, ey, 3, 2, _MY_BLK)
	_fill(img, 13, ey, 3, 2, _MY_BLK)
	_px(img, 8, ey, _MY_EYE_RED); _px(img, 14, ey, _MY_EYE_RED)
	_px(img, 7, ey + 1, _MY_EYE_RED); _px(img, 15, ey + 1, _MY_EYE_RED)
	# Gaping mouth with teeth
	_fill(img, 8, 10, 6, 3, _MY_BLOOD_DK)
	_px(img, 9, 10, _MY_BONE); _px(img, 11, 10, _MY_BONE); _px(img, 13, 10, _MY_BONE)
	_px(img, 8, 12, _MY_BONE); _px(img, 10, 12, _MY_BONE); _px(img, 12, 12, _MY_BONE)
	# Massive body
	_fill(img, 4, 13, 16, 6, _MY_ZGRN_DK)
	_fill(img, 6, 13, 12, 2, _MY_ZGRN)
	# Exposed ribcage
	for x in range(8, 15, 2):
		_px(img, x, 14, _MY_BONE_DK)
		_px(img, x, 16, _MY_BONE_DK)
	# Blood dripping
	_px(img, 9, 17, _MY_BLOOD); _px(img, 12, 18, _MY_BLOOD)
	_px(img, 7, 18, _MY_BLOOD); _px(img, 15, 17, _MY_BLOOD)
	# Arms
	if frame == 0:
		_fill(img, 0, 14, 4, 2, _MY_ZGRN)
		_fill(img, 20, 14, 4, 2, _MY_ZGRN)
		_px(img, 0, 15, _MY_ZGRN_DK); _px(img, 23, 15, _MY_ZGRN_DK)
	else:
		_fill(img, 1, 13, 3, 2, _MY_ZGRN)
		_fill(img, 20, 13, 3, 2, _MY_ZGRN)
		_px(img, 1, 14, _MY_ZGRN_DK); _px(img, 22, 14, _MY_ZGRN_DK)
	# Stumpy legs
	if frame == 0:
		_fill(img, 6, 19, 4, 4, _MY_ZGRN_DK)
		_fill(img, 14, 19, 4, 4, _MY_ZGRN_DK)
	else:
		_fill(img, 5, 19, 4, 4, _MY_ZGRN_DK)
		_fill(img, 15, 19, 4, 4, _MY_ZGRN_DK)
	# Feet
	_fill(img, 5, 22, 6, 1, _MY_ZGRN_DK)
	_fill(img, 13, 22, 6, 1, _MY_ZGRN_DK)
	_outline(img)
	return ImageTexture.create_from_image(img)


# ============================================================
#  Style J — 公主婚礼 (Princess Wedding)
#  White/pink/gold protagonist + fairy-tale enemies
# ============================================================

const _PJ_BLK := Color(0.04, 0.02, 0.06)
const _PJ_DKGRY := Color(0.15, 0.12, 0.18)
const _PJ_GRY := Color(0.35, 0.33, 0.38)
const _PJ_WHT := Color(0.96, 0.95, 0.97)
const _PJ_CREAM := Color(0.95, 0.92, 0.88)
const _PJ_SKIN := Color(0.96, 0.82, 0.75)
const _PJ_SKIN_DK := Color(0.85, 0.70, 0.62)
const _PJ_GOLD := Color(0.95, 0.82, 0.20)
const _PJ_GOLD_DK := Color(0.75, 0.62, 0.12)
const _PJ_GOLD_HI := Color(1.0, 0.92, 0.50)
const _PJ_HAIR := Color(0.85, 0.70, 0.35)
const _PJ_HAIR_DK := Color(0.65, 0.50, 0.22)
const _PJ_DRESS := Color(0.98, 0.96, 0.98)
const _PJ_DRESS_HI := Color(1.0, 1.0, 1.0)
const _PJ_DRESS_SH := Color(0.82, 0.80, 0.85)
const _PJ_PINK := Color(1.0, 0.70, 0.78)
const _PJ_PINK_DK := Color(0.85, 0.45, 0.55)
const _PJ_RAVEN := Color(0.12, 0.08, 0.15)
const _PJ_RAVEN_HI := Color(0.22, 0.15, 0.28)
const _PJ_SILVER := Color(0.75, 0.78, 0.82)
const _PJ_SILVER_HI := Color(0.88, 0.90, 0.94)
const _PJ_SILVER_DK := Color(0.50, 0.52, 0.58)
const _PJ_RED_CAPE := Color(0.75, 0.12, 0.12)
const _PJ_RED_DK := Color(0.50, 0.08, 0.08)
const _PJ_SUIT := Color(0.25, 0.25, 0.28)
const _PJ_SUIT_HI := Color(0.35, 0.35, 0.40)
const _PJ_VEIL := Color(0.92, 0.90, 0.95, 0.7)
const _PJ_PURP := Color(0.30, 0.08, 0.35)
const _PJ_PURP_DK := Color(0.18, 0.04, 0.22)
const _PJ_PURP_HI := Color(0.45, 0.15, 0.55)
const _PJ_RED_EYE := Color(0.90, 0.10, 0.08)


static func generate_style_j() -> Dictionary:
	return {
		"player": [_gen_j_player(0), _gen_j_player(1)],
		"bat": [_gen_j_bat(0), _gen_j_bat(1)],
		"skeleton": [_gen_j_skeleton(0), _gen_j_skeleton(1)],
		"zombie": [_gen_j_zombie(0), _gen_j_zombie(1)],
		"ghost": [_gen_j_ghost(0), _gen_j_ghost(1)],
		"boss": [_gen_j_boss(0), _gen_j_boss(1)],
		"gem_small": _gen_gem(_PJ_PINK, _PJ_PINK_DK, _PJ_DRESS_SH),
		"gem_medium": _gen_gem(_PJ_GOLD, _PJ_GOLD_HI, _PJ_GOLD_DK),
		"gem_large": _gen_gem(_PJ_WHT, _PJ_DRESS_HI, _PJ_DRESS_SH),
		"projectile": _gen_colored_proj(_PJ_GOLD, _PJ_GOLD_HI, _PJ_GOLD_DK),
	}


static func _gen_j_player(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	# Gold crown with 3 points
	_px(img, 5, 0, _PJ_GOLD); _px(img, 7, 0, _PJ_GOLD); _px(img, 10, 0, _PJ_GOLD)
	_fill(img, 5, 1, 6, 1, _PJ_GOLD)
	_px(img, 6, 1, _PJ_GOLD_HI); _px(img, 8, 1, _PJ_GOLD_HI)
	_fill(img, 5, 2, 6, 1, _PJ_GOLD_DK)
	# Golden hair
	_fill(img, 4, 2, 8, 2, _PJ_HAIR)
	_px(img, 4, 2, _PJ_HAIR_DK); _px(img, 11, 2, _PJ_HAIR_DK)
	_px(img, 3, 3, _PJ_HAIR_DK); _px(img, 12, 3, _PJ_HAIR_DK)
	# Face
	_fill(img, 5, 4, 6, 2, _PJ_SKIN)
	_px(img, 4, 4, _PJ_SKIN); _px(img, 11, 4, _PJ_SKIN)
	_px(img, 6, 4, _PJ_BLK); _px(img, 9, 4, _PJ_BLK)
	_px(img, 7, 5, _PJ_PINK_DK); _px(img, 8, 5, _PJ_PINK_DK)
	# Blush
	_px(img, 5, 5, _PJ_PINK); _px(img, 10, 5, _PJ_PINK)
	# White wedding dress bodice
	_fill(img, 5, 6, 6, 2, _PJ_DRESS)
	_px(img, 7, 6, _PJ_DRESS_HI); _px(img, 8, 6, _PJ_DRESS_HI)
	_px(img, 5, 7, _PJ_DRESS_SH); _px(img, 10, 7, _PJ_DRESS_SH)
	# Pink sash
	_fill(img, 5, 8, 6, 1, _PJ_PINK)
	_px(img, 7, 8, _PJ_PINK_DK)
	# Flared skirt
	if frame == 0:
		_fill(img, 4, 9, 8, 4, _PJ_DRESS)
		_fill(img, 3, 11, 10, 2, _PJ_DRESS)
		_fill(img, 3, 13, 10, 1, _PJ_DRESS_SH)
		_px(img, 4, 9, _PJ_DRESS_SH); _px(img, 11, 9, _PJ_DRESS_SH)
		_fill(img, 6, 10, 4, 3, _PJ_DRESS_HI)
	else:
		_fill(img, 3, 9, 10, 4, _PJ_DRESS)
		_fill(img, 2, 11, 12, 2, _PJ_DRESS)
		_fill(img, 2, 13, 12, 1, _PJ_DRESS_SH)
		_px(img, 3, 9, _PJ_DRESS_SH); _px(img, 12, 9, _PJ_DRESS_SH)
		_fill(img, 6, 10, 4, 3, _PJ_DRESS_HI)
	# Arms
	_px(img, 4, 7, _PJ_SKIN); _px(img, 11, 7, _PJ_SKIN)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_j_bat(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	# Raven / dark crow
	if frame == 0:
		_fill(img, 6, 5, 4, 4, _PJ_RAVEN)
		_fill(img, 7, 4, 2, 1, _PJ_RAVEN)
		# Beak
		_px(img, 10, 6, _PJ_GOLD_DK)
		# Eye
		_px(img, 7, 5, _PJ_PURP_HI); _px(img, 8, 5, _PJ_PURP_HI)
		# Wings spread
		_fill(img, 1, 3, 5, 3, _PJ_RAVEN)
		_fill(img, 10, 3, 5, 3, _PJ_RAVEN)
		_px(img, 0, 2, _PJ_RAVEN_HI); _px(img, 15, 2, _PJ_RAVEN_HI)
		_fill(img, 1, 3, 2, 1, _PJ_RAVEN_HI); _fill(img, 13, 3, 2, 1, _PJ_RAVEN_HI)
		# Tail
		_px(img, 7, 9, _PJ_RAVEN); _px(img, 8, 9, _PJ_RAVEN)
	else:
		_fill(img, 6, 4, 4, 4, _PJ_RAVEN)
		_fill(img, 7, 3, 2, 1, _PJ_RAVEN)
		_px(img, 10, 5, _PJ_GOLD_DK)
		_px(img, 7, 4, _PJ_PURP_HI); _px(img, 8, 4, _PJ_PURP_HI)
		# Wings folded down
		_fill(img, 3, 6, 3, 4, _PJ_RAVEN)
		_fill(img, 10, 6, 3, 4, _PJ_RAVEN)
		_fill(img, 1, 9, 2, 3, _PJ_RAVEN_HI)
		_fill(img, 13, 9, 2, 3, _PJ_RAVEN_HI)
		_px(img, 7, 8, _PJ_RAVEN); _px(img, 8, 8, _PJ_RAVEN)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_j_skeleton(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	# Knight / royal guard in silver armor + red cape
	# Helmet
	_fill(img, 5, 0, 6, 2, _PJ_SILVER)
	_fill(img, 4, 2, 8, 3, _PJ_SILVER)
	_fill(img, 6, 0, 4, 1, _PJ_SILVER_HI)
	# Visor slit
	_fill(img, 6, 3, 4, 1, _PJ_BLK)
	_px(img, 6, 3, _PJ_SILVER_DK); _px(img, 9, 3, _PJ_SILVER_DK)
	# Plume on helmet
	_px(img, 7, 0, _PJ_RED_CAPE); _px(img, 8, 0, _PJ_RED_CAPE)
	# Silver breastplate
	_fill(img, 4, 5, 8, 4, _PJ_SILVER)
	_fill(img, 6, 5, 4, 4, _PJ_SILVER_HI)
	_px(img, 7, 6, _PJ_GOLD)
	# Red cape behind
	_px(img, 3, 5, _PJ_RED_CAPE); _px(img, 12, 5, _PJ_RED_CAPE)
	_px(img, 3, 6, _PJ_RED_CAPE); _px(img, 12, 6, _PJ_RED_CAPE)
	_px(img, 2, 7, _PJ_RED_DK); _px(img, 13, 7, _PJ_RED_DK)
	_px(img, 2, 8, _PJ_RED_DK); _px(img, 13, 8, _PJ_RED_DK)
	# Shoulder guards
	_fill(img, 3, 5, 1, 2, _PJ_SILVER_HI); _fill(img, 12, 5, 1, 2, _PJ_SILVER_HI)
	# Belt
	_fill(img, 4, 9, 8, 1, _PJ_GOLD_DK)
	_px(img, 7, 9, _PJ_GOLD)
	# Legs in armor
	if frame == 0:
		_fill(img, 5, 10, 6, 3, _PJ_SILVER_DK)
		_fill(img, 5, 13, 2, 1, _PJ_SILVER); _fill(img, 9, 13, 2, 1, _PJ_SILVER)
	else:
		_fill(img, 3, 10, 3, 3, _PJ_SILVER_DK); _fill(img, 10, 10, 3, 3, _PJ_SILVER_DK)
		_fill(img, 3, 13, 2, 1, _PJ_SILVER); _fill(img, 11, 13, 2, 1, _PJ_SILVER)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_j_zombie(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	# Lost wedding guest in grey suit
	# Head - pale grey skin
	_fill(img, 5, 1, 6, 4, _PJ_GRY)
	_fill(img, 6, 0, 4, 1, _PJ_DKGRY)
	_px(img, 5, 1, Color(0.45, 0.43, 0.48)); _px(img, 10, 1, Color(0.45, 0.43, 0.48))
	# Sunken eyes
	_px(img, 6, 2, _PJ_BLK); _px(img, 9, 2, _PJ_BLK)
	_px(img, 7, 2, Color(0.50, 0.50, 0.55)); _px(img, 10, 2, Color(0.50, 0.50, 0.55))
	# Slack mouth
	_fill(img, 7, 4, 2, 1, _PJ_DKGRY)
	# Suit jacket
	_fill(img, 4, 5, 8, 5, _PJ_SUIT)
	_fill(img, 6, 5, 4, 1, _PJ_SUIT_HI)
	# White shirt peeking through
	_px(img, 7, 5, _PJ_WHT); _px(img, 8, 5, _PJ_WHT)
	_px(img, 7, 6, _PJ_CREAM); _px(img, 8, 6, _PJ_CREAM)
	# Bow tie
	_px(img, 7, 5, _PJ_DKGRY); _px(img, 8, 5, _PJ_DKGRY)
	# Arms
	var ay := 6 if frame == 0 else 5
	_fill(img, 2, ay, 2, 1, _PJ_GRY); _px(img, 1, ay + 1, _PJ_GRY)
	_fill(img, 12, ay, 2, 1, _PJ_GRY); _px(img, 14, ay + 1, _PJ_GRY)
	# Legs
	if frame == 0:
		_fill(img, 5, 10, 3, 3, _PJ_SUIT); _fill(img, 8, 10, 3, 3, _PJ_SUIT)
		_fill(img, 5, 13, 2, 1, _PJ_BLK); _fill(img, 9, 13, 2, 1, _PJ_BLK)
	else:
		_fill(img, 4, 10, 3, 3, _PJ_SUIT); _fill(img, 9, 10, 3, 3, _PJ_SUIT)
		_fill(img, 4, 13, 2, 1, _PJ_BLK); _fill(img, 10, 13, 2, 1, _PJ_BLK)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_j_ghost(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	var yo := 0 if frame == 0 else 1
	# Ghost bride with veil
	_fill(img, 6, 0 + yo, 4, 1, _PJ_VEIL)
	_fill(img, 5, 1 + yo, 6, 1, _PJ_VEIL)
	_fill(img, 4, 2 + yo, 8, 8, _PJ_WHT)
	# Translucent shimmer
	_fill(img, 5, 2 + yo, 6, 2, _PJ_DRESS_HI)
	# Veil drape on sides
	_px(img, 3, 3 + yo, _PJ_VEIL); _px(img, 12, 3 + yo, _PJ_VEIL)
	_px(img, 2, 4 + yo, _PJ_VEIL); _px(img, 13, 4 + yo, _PJ_VEIL)
	_px(img, 2, 5 + yo, _PJ_VEIL); _px(img, 13, 5 + yo, _PJ_VEIL)
	# Sad eyes
	_px(img, 6, 4 + yo, _PJ_BLK); _px(img, 7, 4 + yo, _PJ_BLK)
	_px(img, 9, 4 + yo, _PJ_BLK); _px(img, 10, 4 + yo, _PJ_BLK)
	# Tear drops
	_px(img, 7, 5 + yo, _PJ_DRESS_SH); _px(img, 10, 5 + yo, _PJ_DRESS_SH)
	# Mournful mouth
	_fill(img, 7, 6 + yo, 3, 1, _PJ_DRESS_SH)
	# Wispy trailing bottom
	for x in range(4, 12):
		if (10 + yo) < 16:
			img.set_pixel(x, 10 + yo, _CLEAR)
	for x in [5, 7, 9]:
		_px(img, x, 10 + yo, _PJ_WHT)
	for x in [4, 6, 8, 10]:
		if (11 + yo) < 16:
			_px(img, x, 11 + yo, _PJ_DRESS_SH)
	# Trailing veil wisps
	for x in [5, 7, 9, 11]:
		if (12 + yo) < 16:
			_px(img, x, 12 + yo, _PJ_VEIL)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_j_boss(frame: int) -> ImageTexture:
	var img := _img(24, 24)
	# Dark dragon prince — purple-black body + red eyes
	_ellipse(img, 11, 13, 9, 8, _PJ_PURP_DK)
	_ellipse(img, 11, 12, 7, 6, _PJ_PURP)
	_ellipse(img, 11, 13, 9, 8, _PJ_PURP_DK)
	# Horns curving upward
	for i in range(6):
		_px(img, 4 - i, 5 - i, _PJ_BLK); _px(img, 5 - i, 5 - i, _PJ_PURP_DK)
		_px(img, 18 + i, 5 - i, _PJ_BLK); _px(img, 17 + i, 5 - i, _PJ_PURP_DK)
	# Horn tips glow
	_px(img, -1, 0, _PJ_PURP_HI); _px(img, 23, 0, _PJ_PURP_HI)
	# Glowing red eyes
	var ey := 9 if frame == 0 else 10
	_fill(img, 5, ey, 4, 3, _PJ_RED_EYE); _fill(img, 14, ey, 4, 3, _PJ_RED_EYE)
	_fill(img, 6, ey, 2, 2, _PJ_GOLD_HI); _fill(img, 15, ey, 2, 2, _PJ_GOLD_HI)
	_px(img, 6, ey + 1, _PJ_BLK); _px(img, 15, ey + 1, _PJ_BLK)
	# Jagged mouth with fangs
	_fill(img, 7, 16, 9, 2, _PJ_BLK)
	for x in range(8, 15, 2):
		_px(img, x, 16, _PJ_WHT)
	_px(img, 9, 17, _PJ_WHT); _px(img, 13, 17, _PJ_WHT)
	# Dark crown atop
	_fill(img, 8, 3, 7, 2, _PJ_GOLD_DK)
	_px(img, 9, 2, _PJ_GOLD); _px(img, 11, 2, _PJ_GOLD); _px(img, 13, 2, _PJ_GOLD)
	# Cape / wing edges
	_px(img, 2, 10, _PJ_PURP_HI); _px(img, 21, 10, _PJ_PURP_HI)
	_px(img, 1, 12, _PJ_PURP_HI); _px(img, 22, 12, _PJ_PURP_HI)
	_outline(img)
	return ImageTexture.create_from_image(img)


# ============================================================
#  Shared helpers
# ============================================================

static func _gen_gem(base: Color, hi: Color, lo: Color) -> ImageTexture:
	var img := _img(8, 8)
	_px(img, 3, 0, lo)
	_fill(img, 2, 1, 3, 1, base); _px(img, 3, 1, hi)
	_fill(img, 1, 2, 5, 1, base); _px(img, 2, 2, hi); _px(img, 3, 2, Color(0.92, 0.92, 0.96))
	_fill(img, 0, 3, 7, 1, base); _px(img, 2, 3, hi)
	_fill(img, 1, 4, 5, 1, base); _px(img, 2, 4, hi)
	_fill(img, 2, 5, 3, 1, lo)
	_px(img, 3, 6, lo)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_colored_proj(base: Color, hi: Color, dk: Color) -> ImageTexture:
	var img := _img(8, 8)
	_fill(img, 2, 1, 4, 1, dk)
	_fill(img, 1, 2, 6, 4, base)
	_fill(img, 2, 6, 4, 1, dk)
	_fill(img, 3, 2, 2, 2, hi)
	_px(img, 3, 3, Color(0.92, 0.92, 0.96))
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _img(w: int, h: int) -> Image:
	var i := Image.create(w, h, false, Image.FORMAT_RGBA8)
	i.fill(_CLEAR)
	return i

static func _px(img: Image, x: int, y: int, col: Color) -> void:
	if x >= 0 and x < img.get_width() and y >= 0 and y < img.get_height():
		img.set_pixel(x, y, col)

static func _fill(img: Image, x: int, y: int, w: int, h: int, col: Color) -> void:
	var iw := img.get_width()
	var ih := img.get_height()
	for py in range(maxi(y, 0), mini(y + h, ih)):
		for px in range(maxi(x, 0), mini(x + w, iw)):
			img.set_pixel(px, py, col)

static func _ellipse(img: Image, cx: int, cy: int, rx: int, ry: int, col: Color) -> void:
	var w := img.get_width()
	var h := img.get_height()
	for py in range(maxi(0, cy - ry), mini(h, cy + ry + 1)):
		for px in range(maxi(0, cx - rx), mini(w, cx + rx + 1)):
			var dx := (float(px) - float(cx)) / float(rx)
			var dy := (float(py) - float(cy)) / float(ry)
			if dx * dx + dy * dy <= 1.0:
				img.set_pixel(px, py, col)

static func _outline(img: Image) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var pts: Array[Vector2i] = []
	for y in range(h):
		for x in range(w):
			if img.get_pixel(x, y).a < 0.01:
				var found := false
				for dy in range(-1, 2):
					for dx in range(-1, 2):
						if dx == 0 and dy == 0:
							continue
						var nx := x + dx
						var ny := y + dy
						if nx >= 0 and nx < w and ny >= 0 and ny < h:
							if img.get_pixel(nx, ny).a > 0.01:
								found = true
					if found:
						break
				if found:
					pts.append(Vector2i(x, y))
	for p in pts:
		img.set_pixel(p.x, p.y, _OL)


static func export_style(data: Dictionary, base_dir: String) -> int:
	var dir := DirAccess.open("res://")
	if dir:
		dir.make_dir_recursive(base_dir)
	var count := 0
	for key: String in data:
		var value = data[key]
		if value is Array:
			var arr: Array = value
			for i in range(arr.size()):
				var tex: ImageTexture = arr[i]
				var im: Image = tex.get_image()
				var path: String = base_dir + key + "_" + str(i) + ".png"
				im.save_png(path)
				count += 1
		elif value is ImageTexture:
			var tex: ImageTexture = value
			var im: Image = tex.get_image()
			var path: String = base_dir + key + ".png"
			im.save_png(path)
			count += 1
	return count
