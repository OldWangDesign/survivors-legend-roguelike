class_name SpriteGenVariants

const _CLEAR := Color(0, 0, 0, 0)
const _OL := Color(0.04, 0.04, 0.08)
const _WHITE := Color(0.92, 0.92, 0.96)
const _BLACK := Color(0.04, 0.04, 0.08)
const _YELLOW := Color(0.95, 0.82, 0.22)

# ============================================================
#  Style B — 赤焰武士 (Crimson Samurai)
# ============================================================

const _B_RED := Color(0.72, 0.14, 0.10)
const _B_RED_HI := Color(0.88, 0.28, 0.18)
const _B_RED_DK := Color(0.45, 0.08, 0.06)
const _B_GOLD := Color(0.85, 0.68, 0.18)
const _B_GOLD_DK := Color(0.60, 0.45, 0.10)
const _B_GRAY := Color(0.35, 0.32, 0.38)
const _B_SKIN := Color(0.88, 0.72, 0.56)
const _B_HAIR := Color(0.12, 0.10, 0.08)
const _B_BROWN := Color(0.40, 0.25, 0.12)
const _B_BOOT := Color(0.18, 0.15, 0.12)

const _B_IMP_O := Color(0.90, 0.45, 0.10)
const _B_IMP_R := Color(0.85, 0.22, 0.08)
const _B_IMP_Y := Color(0.95, 0.70, 0.15)

const _B_BONE := Color(0.80, 0.72, 0.65)
const _B_BONE_DK := Color(0.55, 0.45, 0.38)
const _B_BONE_HI := Color(0.90, 0.85, 0.80)

const _B_ASH := Color(0.35, 0.32, 0.30)
const _B_ASH_DK := Color(0.22, 0.20, 0.18)
const _B_CHAR := Color(0.15, 0.12, 0.10)

const _B_FIRE := Color(0.95, 0.55, 0.10)
const _B_FIRE_HI := Color(1.0, 0.80, 0.25)
const _B_FIRE_DK := Color(0.75, 0.25, 0.05)

const _B_BOSS_R := Color(0.65, 0.10, 0.08)
const _B_BOSS_DK := Color(0.38, 0.05, 0.05)
const _B_BOSS_HI := Color(0.85, 0.20, 0.12)
const _B_BOSS_HORN := Color(0.25, 0.22, 0.20)


static func generate_style_b() -> Dictionary:
	return {
		"player": [_gen_b_player(0), _gen_b_player(1)],
		"bat": [_gen_b_imp(0), _gen_b_imp(1)],
		"skeleton": [_gen_b_skeleton(0), _gen_b_skeleton(1)],
		"zombie": [_gen_b_ashwalker(0), _gen_b_ashwalker(1)],
		"ghost": [_gen_b_firespirit(0), _gen_b_firespirit(1)],
		"boss": [_gen_b_boss(0), _gen_b_boss(1)],
		"gem_small": _gen_gem(
			Color(0.90, 0.50, 0.08), Color(1.0, 0.75, 0.20), Color(0.60, 0.30, 0.05)),
		"gem_medium": _gen_gem(
			Color(0.85, 0.18, 0.10), Color(1.0, 0.40, 0.25), Color(0.50, 0.08, 0.05)),
		"gem_large": _gen_gem(
			Color(0.85, 0.68, 0.15), Color(1.0, 0.90, 0.40), Color(0.55, 0.40, 0.08)),
		"projectile": _gen_b_projectile(),
	}


static func _gen_b_player(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	# Samurai kabuto (helmet)
	_fill(img, 5, 0, 6, 1, _B_RED_DK)
	_fill(img, 4, 1, 8, 1, _B_RED)
	_fill(img, 3, 2, 10, 2, _B_RED)
	_px(img, 3, 2, _B_RED_DK); _px(img, 12, 2, _B_RED_DK)
	_fill(img, 6, 1, 4, 1, _B_GOLD)
	# Face
	_fill(img, 5, 4, 6, 2, _B_SKIN)
	_px(img, 6, 4, _BLACK); _px(img, 9, 4, _BLACK)
	# Neck guard
	_fill(img, 4, 6, 8, 1, _B_RED_DK)
	# Body armor
	_fill(img, 4, 7, 8, 3, _B_RED)
	_fill(img, 7, 7, 2, 3, _B_GOLD)
	_px(img, 4, 7, _B_RED_DK); _px(img, 11, 7, _B_RED_DK)
	# Shoulder pads
	_fill(img, 3, 7, 1, 2, _B_GRAY)
	_fill(img, 12, 7, 1, 2, _B_GRAY)
	# Belt / obi
	_fill(img, 4, 10, 8, 1, _B_GOLD_DK)
	# Legs (hakama)
	if frame == 0:
		_fill(img, 5, 11, 6, 2, _B_RED_DK)
		_fill(img, 5, 13, 2, 1, _B_BOOT)
		_fill(img, 9, 13, 2, 1, _B_BOOT)
	else:
		_fill(img, 3, 11, 3, 2, _B_RED_DK)
		_fill(img, 10, 11, 3, 2, _B_RED_DK)
		_fill(img, 3, 13, 2, 1, _B_BOOT)
		_fill(img, 11, 13, 2, 1, _B_BOOT)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_b_imp(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	if frame == 0:
		_fill(img, 6, 4, 4, 4, _B_IMP_R)
		_fill(img, 7, 3, 2, 1, _B_IMP_R)
		_px(img, 7, 4, _YELLOW); _px(img, 8, 4, _YELLOW)
		# Wings (flame-like)
		_fill(img, 3, 3, 3, 3, _B_IMP_O)
		_fill(img, 1, 2, 2, 2, _B_IMP_Y)
		_px(img, 0, 1, _B_IMP_Y)
		_fill(img, 10, 3, 3, 3, _B_IMP_O)
		_fill(img, 13, 2, 2, 2, _B_IMP_Y)
		_px(img, 15, 1, _B_IMP_Y)
		_px(img, 7, 8, _B_IMP_O); _px(img, 8, 8, _B_IMP_O)
		# Horns
		_px(img, 6, 2, _B_BOSS_HORN); _px(img, 9, 2, _B_BOSS_HORN)
	else:
		_fill(img, 6, 3, 4, 4, _B_IMP_R)
		_fill(img, 7, 2, 2, 1, _B_IMP_R)
		_px(img, 7, 3, _YELLOW); _px(img, 8, 3, _YELLOW)
		_fill(img, 3, 5, 3, 3, _B_IMP_O)
		_fill(img, 1, 7, 2, 3, _B_IMP_Y)
		_px(img, 0, 10, _B_IMP_Y)
		_fill(img, 10, 5, 3, 3, _B_IMP_O)
		_fill(img, 13, 7, 2, 3, _B_IMP_Y)
		_px(img, 15, 10, _B_IMP_Y)
		_px(img, 6, 1, _B_BOSS_HORN); _px(img, 9, 1, _B_BOSS_HORN)
		_px(img, 7, 7, _B_IMP_O); _px(img, 8, 7, _B_IMP_O)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_b_skeleton(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	# Skull with red tint
	_fill(img, 5, 0, 6, 6, _B_BONE)
	_fill(img, 6, 0, 4, 1, _B_BONE_DK)
	_fill(img, 6, 2, 2, 2, Color(0.30, 0.05, 0.05))
	_fill(img, 9, 2, 2, 2, Color(0.30, 0.05, 0.05))
	_px(img, 6, 2, _B_BONE_HI); _px(img, 9, 2, _B_BONE_HI)
	_fill(img, 6, 5, 4, 1, _BLACK)
	_px(img, 7, 5, _B_BONE); _px(img, 9, 5, _B_BONE)
	# Spine
	_fill(img, 7, 6, 2, 5, _B_BONE)
	_fill(img, 5, 7, 6, 1, _B_BONE_DK)
	_fill(img, 5, 9, 6, 1, _B_BONE_DK)
	# Arms
	if frame == 0:
		_fill(img, 3, 7, 2, 1, _B_BONE); _fill(img, 2, 8, 1, 2, _B_BONE)
		_fill(img, 11, 7, 2, 1, _B_BONE); _fill(img, 13, 8, 1, 2, _B_BONE)
	else:
		_fill(img, 3, 7, 2, 1, _B_BONE); _fill(img, 2, 7, 1, 2, _B_BONE)
		_fill(img, 11, 7, 2, 1, _B_BONE); _fill(img, 13, 7, 1, 2, _B_BONE)
	_fill(img, 6, 11, 4, 1, _B_BONE_DK)
	if frame == 0:
		_fill(img, 6, 12, 1, 3, _B_BONE); _fill(img, 9, 12, 1, 3, _B_BONE)
	else:
		_fill(img, 5, 12, 1, 3, _B_BONE); _fill(img, 10, 12, 1, 3, _B_BONE)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_b_ashwalker(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	# Head
	_fill(img, 5, 1, 6, 5, _B_ASH)
	_fill(img, 5, 1, 6, 1, _B_CHAR)
	_px(img, 6, 3, _B_FIRE); _px(img, 10, 3, _B_FIRE)
	_px(img, 7, 3, _B_ASH_DK); _px(img, 10, 4, _B_ASH_DK)
	# Body
	_fill(img, 5, 6, 6, 4, _B_ASH_DK)
	_fill(img, 5, 6, 6, 1, _B_CHAR)
	# Embers on body
	_px(img, 6, 7, _B_FIRE_DK); _px(img, 9, 8, _B_FIRE_DK)
	# Arms
	var ay := 7 if frame == 0 else 6
	_fill(img, 2, ay, 3, 1, _B_ASH); _px(img, 1, ay + 1, _B_ASH)
	_fill(img, 11, ay, 3, 1, _B_ASH); _px(img, 14, ay + 1, _B_ASH)
	# Legs
	if frame == 0:
		_fill(img, 5, 10, 3, 3, _B_CHAR); _fill(img, 8, 10, 3, 3, _B_CHAR)
		_px(img, 6, 13, _B_ASH_DK); _px(img, 9, 13, _B_ASH_DK)
	else:
		_fill(img, 4, 10, 3, 3, _B_CHAR); _fill(img, 9, 10, 3, 3, _B_CHAR)
		_px(img, 5, 13, _B_ASH_DK); _px(img, 10, 13, _B_ASH_DK)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_b_firespirit(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	var yo := 0 if frame == 0 else 1
	_fill(img, 6, 1 + yo, 4, 1, _B_FIRE)
	_fill(img, 5, 2 + yo, 6, 1, _B_FIRE)
	_fill(img, 4, 3 + yo, 8, 7, _B_FIRE)
	_fill(img, 5, 2 + yo, 6, 2, _B_FIRE_HI)
	# Eyes
	_px(img, 6, 5 + yo, _WHITE); _px(img, 7, 5 + yo, _WHITE)
	_px(img, 9, 5 + yo, _WHITE); _px(img, 10, 5 + yo, _WHITE)
	_px(img, 7, 5 + yo, _BLACK); _px(img, 10, 5 + yo, _BLACK)
	_fill(img, 7, 7 + yo, 3, 1, _B_FIRE_DK)
	# Flame bottom
	for x in range(4, 12):
		if x >= 0 and (10 + yo) < 16:
			img.set_pixel(x, 10 + yo, _CLEAR)
	for x in [5, 7, 9]:
		_px(img, x, 10 + yo, _B_FIRE)
	for x in [4, 6, 8, 10]:
		_px(img, x, 11 + yo, _B_IMP_Y)
	# Flame tips on top
	_px(img, 6, yo, _B_IMP_Y); _px(img, 9, yo, _B_IMP_Y)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_b_boss(frame: int) -> ImageTexture:
	var img := _img(24, 24)
	# Oni face
	_ellipse(img, 11, 12, 9, 8, _B_BOSS_R)
	_ellipse(img, 11, 11, 7, 5, _B_BOSS_HI)
	_ellipse(img, 11, 12, 9, 8, _B_BOSS_R)
	# Large horns curving up
	for i in range(7):
		_px(img, 3 - i, 6 - i, _B_BOSS_HORN)
		_px(img, 4 - i, 6 - i, _B_BOSS_HORN)
		_px(img, 4 - i, 5 - i, _B_BOSS_R)
		_px(img, 19 + i, 6 - i, _B_BOSS_HORN)
		_px(img, 18 + i, 6 - i, _B_BOSS_HORN)
		_px(img, 18 + i, 5 - i, _B_BOSS_R)
	# Eyes
	var ey := 9 if frame == 0 else 10
	_fill(img, 5, ey, 4, 3, _B_FIRE)
	_fill(img, 14, ey, 4, 3, _B_FIRE)
	_fill(img, 6, ey, 2, 2, _B_FIRE_HI)
	_fill(img, 15, ey, 2, 2, _B_FIRE_HI)
	_px(img, 6, ey + 1, _BLACK); _px(img, 15, ey + 1, _BLACK)
	# Fanged mouth
	_fill(img, 6, 16, 11, 3, _B_BOSS_DK)
	for x in range(7, 16, 2):
		_px(img, x, 16, _WHITE)
	# Lower fangs
	_px(img, 8, 19, _WHITE); _px(img, 14, 19, _WHITE)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_b_projectile() -> ImageTexture:
	var img := _img(8, 8)
	_fill(img, 2, 1, 4, 1, _B_FIRE_DK)
	_fill(img, 1, 2, 6, 4, _B_FIRE)
	_fill(img, 2, 6, 4, 1, _B_FIRE_DK)
	_fill(img, 3, 2, 2, 2, _B_FIRE_HI)
	_px(img, 3, 3, _WHITE)
	_outline(img)
	return ImageTexture.create_from_image(img)


# ============================================================
#  Style C — 翠林游侠 (Forest Ranger)
# ============================================================

const _C_GREEN := Color(0.18, 0.52, 0.22)
const _C_GREEN_HI := Color(0.30, 0.68, 0.32)
const _C_GREEN_DK := Color(0.10, 0.32, 0.12)
const _C_BROWN := Color(0.48, 0.32, 0.16)
const _C_BROWN_DK := Color(0.30, 0.20, 0.10)
const _C_SKIN := Color(0.85, 0.70, 0.55)
const _C_HAIR := Color(0.55, 0.35, 0.15)
const _C_BOOT := Color(0.30, 0.22, 0.12)
const _C_BELT := Color(0.38, 0.28, 0.14)

const _C_FAIRY_G := Color(0.20, 0.80, 0.55)
const _C_FAIRY_HI := Color(0.45, 0.95, 0.70)
const _C_FAIRY_DK := Color(0.10, 0.50, 0.30)

const _C_WOOD := Color(0.50, 0.35, 0.18)
const _C_WOOD_DK := Color(0.32, 0.22, 0.10)
const _C_WOOD_HI := Color(0.65, 0.50, 0.28)
const _C_MOSS := Color(0.22, 0.45, 0.18)

const _C_SWAMP := Color(0.15, 0.38, 0.12)
const _C_SWAMP_DK := Color(0.08, 0.22, 0.06)
const _C_MUD := Color(0.35, 0.28, 0.15)

const _C_WISP := Color(0.15, 0.75, 0.72)
const _C_WISP_HI := Color(0.40, 0.95, 0.90)
const _C_WISP_DK := Color(0.08, 0.45, 0.42)

const _C_TREANT := Color(0.42, 0.30, 0.15)
const _C_TREANT_DK := Color(0.25, 0.18, 0.08)
const _C_LEAF := Color(0.25, 0.58, 0.20)
const _C_LEAF_HI := Color(0.40, 0.75, 0.30)


static func generate_style_c() -> Dictionary:
	return {
		"player": [_gen_c_player(0), _gen_c_player(1)],
		"bat": [_gen_c_fairy(0), _gen_c_fairy(1)],
		"skeleton": [_gen_c_treeskel(0), _gen_c_treeskel(1)],
		"zombie": [_gen_c_swamp(0), _gen_c_swamp(1)],
		"ghost": [_gen_c_wisp(0), _gen_c_wisp(1)],
		"boss": [_gen_c_boss(0), _gen_c_boss(1)],
		"gem_small": _gen_gem(
			Color(0.20, 0.75, 0.30), Color(0.50, 0.95, 0.55), Color(0.10, 0.45, 0.15)),
		"gem_medium": _gen_gem(
			Color(0.45, 0.70, 0.20), Color(0.70, 0.90, 0.40), Color(0.25, 0.42, 0.10)),
		"gem_large": _gen_gem(
			Color(0.85, 0.65, 0.10), Color(1.0, 0.85, 0.30), Color(0.55, 0.38, 0.05)),
		"projectile": _gen_c_projectile(),
	}


static func _gen_c_player(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	# Hood
	_fill(img, 5, 0, 6, 1, _C_GREEN_DK)
	_fill(img, 4, 1, 8, 3, _C_GREEN)
	_px(img, 4, 1, _C_GREEN_DK); _px(img, 11, 1, _C_GREEN_DK)
	_fill(img, 5, 1, 6, 1, _C_GREEN_HI)
	# Hood point
	_px(img, 12, 0, _C_GREEN); _px(img, 13, 1, _C_GREEN_DK)
	# Face visible under hood
	_fill(img, 5, 3, 6, 2, _C_SKIN)
	_px(img, 6, 3, _BLACK); _px(img, 9, 3, _BLACK)
	# Hair peek
	_px(img, 5, 2, _C_HAIR); _px(img, 10, 2, _C_HAIR)
	# Cloak / body
	_fill(img, 4, 5, 8, 5, _C_GREEN)
	_px(img, 3, 6, _C_GREEN); _px(img, 12, 6, _C_GREEN)
	_px(img, 3, 7, _C_GREEN_DK); _px(img, 12, 7, _C_GREEN_DK)
	# Cloak center line
	_fill(img, 7, 5, 2, 5, _C_GREEN_DK)
	# Belt
	_fill(img, 4, 9, 8, 1, _C_BELT)
	_px(img, 7, 9, _C_BROWN)
	# Arms (brown gloves)
	_fill(img, 3, 8, 1, 2, _C_BROWN)
	_fill(img, 12, 8, 1, 2, _C_BROWN)
	# Legs
	if frame == 0:
		_fill(img, 5, 10, 6, 3, _C_BROWN)
		_fill(img, 5, 13, 2, 1, _C_BOOT)
		_fill(img, 9, 13, 2, 1, _C_BOOT)
	else:
		_fill(img, 3, 10, 3, 3, _C_BROWN)
		_fill(img, 10, 10, 3, 3, _C_BROWN)
		_fill(img, 3, 13, 2, 1, _C_BOOT)
		_fill(img, 11, 13, 2, 1, _C_BOOT)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_c_fairy(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	if frame == 0:
		# Tiny body
		_fill(img, 6, 5, 4, 3, _C_FAIRY_G)
		_fill(img, 7, 4, 2, 1, _C_FAIRY_HI)
		_px(img, 7, 5, _WHITE); _px(img, 8, 5, _WHITE)
		# Wings (leaf-shaped)
		_fill(img, 3, 3, 3, 3, _C_FAIRY_HI)
		_px(img, 2, 2, _C_FAIRY_G); _px(img, 1, 1, _C_FAIRY_DK)
		_fill(img, 10, 3, 3, 3, _C_FAIRY_HI)
		_px(img, 13, 2, _C_FAIRY_G); _px(img, 14, 1, _C_FAIRY_DK)
		_px(img, 7, 8, _C_FAIRY_DK); _px(img, 8, 8, _C_FAIRY_DK)
		# Sparkle
		_px(img, 2, 4, _WHITE); _px(img, 13, 4, _WHITE)
	else:
		_fill(img, 6, 4, 4, 3, _C_FAIRY_G)
		_fill(img, 7, 3, 2, 1, _C_FAIRY_HI)
		_px(img, 7, 4, _WHITE); _px(img, 8, 4, _WHITE)
		_fill(img, 3, 6, 3, 3, _C_FAIRY_HI)
		_px(img, 2, 8, _C_FAIRY_G); _px(img, 1, 10, _C_FAIRY_DK)
		_fill(img, 10, 6, 3, 3, _C_FAIRY_HI)
		_px(img, 13, 8, _C_FAIRY_G); _px(img, 14, 10, _C_FAIRY_DK)
		_px(img, 7, 7, _C_FAIRY_DK); _px(img, 8, 7, _C_FAIRY_DK)
		_px(img, 4, 7, _WHITE); _px(img, 11, 7, _WHITE)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_c_treeskel(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	# Wooden skull
	_fill(img, 5, 0, 6, 6, _C_WOOD)
	_fill(img, 6, 0, 4, 1, _C_WOOD_DK)
	_fill(img, 6, 2, 2, 2, _BLACK)
	_fill(img, 9, 2, 2, 2, _BLACK)
	_px(img, 6, 2, _C_MOSS); _px(img, 9, 2, _C_MOSS)
	_fill(img, 6, 5, 4, 1, _BLACK)
	_px(img, 7, 5, _C_WOOD); _px(img, 9, 5, _C_WOOD)
	# Moss on skull
	_px(img, 5, 0, _C_MOSS); _px(img, 10, 0, _C_MOSS)
	# Spine (wood)
	_fill(img, 7, 6, 2, 5, _C_WOOD)
	_fill(img, 5, 7, 6, 1, _C_WOOD_DK)
	_fill(img, 5, 9, 6, 1, _C_WOOD_DK)
	# Branch-arms
	if frame == 0:
		_fill(img, 3, 7, 2, 1, _C_WOOD); _fill(img, 2, 8, 1, 2, _C_WOOD)
		_px(img, 1, 8, _C_MOSS)
		_fill(img, 11, 7, 2, 1, _C_WOOD); _fill(img, 13, 8, 1, 2, _C_WOOD)
		_px(img, 14, 8, _C_MOSS)
	else:
		_fill(img, 3, 7, 2, 1, _C_WOOD); _fill(img, 2, 7, 1, 2, _C_WOOD)
		_px(img, 1, 7, _C_MOSS)
		_fill(img, 11, 7, 2, 1, _C_WOOD); _fill(img, 13, 7, 1, 2, _C_WOOD)
		_px(img, 14, 7, _C_MOSS)
	_fill(img, 6, 11, 4, 1, _C_WOOD_DK)
	if frame == 0:
		_fill(img, 6, 12, 1, 3, _C_WOOD); _fill(img, 9, 12, 1, 3, _C_WOOD)
	else:
		_fill(img, 5, 12, 1, 3, _C_WOOD); _fill(img, 10, 12, 1, 3, _C_WOOD)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_c_swamp(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	_fill(img, 5, 1, 6, 5, _C_SWAMP)
	_fill(img, 5, 1, 6, 1, _C_SWAMP_DK)
	_px(img, 6, 3, _YELLOW); _px(img, 10, 3, _YELLOW)
	_px(img, 7, 3, _BLACK); _px(img, 10, 4, _BLACK)
	# Vines on face
	_px(img, 5, 2, _C_MOSS); _px(img, 10, 2, _C_MOSS)
	# Body
	_fill(img, 5, 6, 6, 4, _C_MUD)
	_fill(img, 5, 6, 6, 1, _C_SWAMP_DK)
	# Moss patches
	_px(img, 6, 7, _C_MOSS); _px(img, 9, 8, _C_MOSS)
	_px(img, 8, 9, _C_MOSS)
	# Arms
	var ay := 7 if frame == 0 else 6
	_fill(img, 2, ay, 3, 1, _C_SWAMP); _px(img, 1, ay + 1, _C_SWAMP)
	_fill(img, 11, ay, 3, 1, _C_SWAMP); _px(img, 14, ay + 1, _C_SWAMP)
	if frame == 0:
		_fill(img, 5, 10, 3, 3, _C_SWAMP_DK); _fill(img, 8, 10, 3, 3, _C_SWAMP_DK)
		_px(img, 6, 13, _C_MUD); _px(img, 9, 13, _C_MUD)
	else:
		_fill(img, 4, 10, 3, 3, _C_SWAMP_DK); _fill(img, 9, 10, 3, 3, _C_SWAMP_DK)
		_px(img, 5, 13, _C_MUD); _px(img, 10, 13, _C_MUD)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_c_wisp(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	var yo := 0 if frame == 0 else 1
	_fill(img, 6, 1 + yo, 4, 1, _C_WISP)
	_fill(img, 5, 2 + yo, 6, 1, _C_WISP)
	_fill(img, 4, 3 + yo, 8, 7, _C_WISP)
	_fill(img, 5, 2 + yo, 6, 2, _C_WISP_HI)
	_px(img, 6, 5 + yo, _WHITE); _px(img, 7, 5 + yo, _WHITE)
	_px(img, 9, 5 + yo, _WHITE); _px(img, 10, 5 + yo, _WHITE)
	_px(img, 7, 5 + yo, _BLACK); _px(img, 10, 5 + yo, _BLACK)
	_fill(img, 7, 7 + yo, 3, 1, _C_WISP_DK)
	for x in range(4, 12):
		if x >= 0 and (10 + yo) < 16:
			img.set_pixel(x, 10 + yo, _CLEAR)
	for x in [5, 7, 9]:
		_px(img, x, 10 + yo, _C_WISP)
	for x in [4, 6, 8, 10]:
		_px(img, x, 11 + yo, _C_WISP_DK)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_c_boss(frame: int) -> ImageTexture:
	var img := _img(24, 24)
	# Treant face - large wooden mass
	_ellipse(img, 11, 13, 9, 8, _C_TREANT)
	_ellipse(img, 11, 12, 7, 6, _C_TREANT_DK)
	_ellipse(img, 11, 13, 9, 8, _C_TREANT)
	# Bark texture
	_px(img, 5, 10, _C_TREANT_DK); _px(img, 17, 10, _C_TREANT_DK)
	_px(img, 8, 15, _C_TREANT_DK); _px(img, 14, 17, _C_TREANT_DK)
	# Branch horns
	for i in range(6):
		_px(img, 4 - i, 6 - i, _C_TREANT_DK)
		_px(img, 5 - i, 5 - i, _C_TREANT)
		_px(img, 5 - i, 4 - i, _C_LEAF)
		_px(img, 18 + i, 6 - i, _C_TREANT_DK)
		_px(img, 17 + i, 5 - i, _C_TREANT)
		_px(img, 17 + i, 4 - i, _C_LEAF)
	# Leaf crown
	_fill(img, 4, 5, 15, 2, _C_LEAF)
	_fill(img, 6, 4, 11, 1, _C_LEAF_HI)
	_px(img, 8, 3, _C_LEAF); _px(img, 14, 3, _C_LEAF)
	# Eyes (glowing green)
	var ey := 10 if frame == 0 else 11
	_fill(img, 5, ey, 4, 3, _C_FAIRY_G)
	_fill(img, 14, ey, 4, 3, _C_FAIRY_G)
	_fill(img, 6, ey, 2, 2, _C_FAIRY_HI)
	_fill(img, 15, ey, 2, 2, _C_FAIRY_HI)
	_px(img, 6, ey + 1, _BLACK); _px(img, 15, ey + 1, _BLACK)
	# Mouth (dark hollow)
	_fill(img, 7, 17, 9, 2, _BLACK)
	_px(img, 8, 17, _C_TREANT_DK); _px(img, 14, 17, _C_TREANT_DK)
	# Moss draping
	_px(img, 3, 14, _C_MOSS); _px(img, 19, 14, _C_MOSS)
	_px(img, 2, 15, _C_MOSS); _px(img, 20, 15, _C_MOSS)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_c_projectile() -> ImageTexture:
	var img := _img(8, 8)
	# Leaf/thorn projectile
	_fill(img, 2, 1, 4, 1, _C_GREEN_DK)
	_fill(img, 1, 2, 6, 4, _C_GREEN)
	_fill(img, 2, 6, 4, 1, _C_GREEN_DK)
	_fill(img, 3, 2, 2, 2, _C_GREEN_HI)
	_px(img, 3, 3, _WHITE)
	_outline(img)
	return ImageTexture.create_from_image(img)


# ============================================================
#  Style D — 暗夜法师 (Arcane Mage)
# ============================================================

const _D_PURPLE := Color(0.38, 0.15, 0.65)
const _D_PURPLE_HI := Color(0.55, 0.30, 0.82)
const _D_PURPLE_DK := Color(0.22, 0.08, 0.40)
const _D_GOLD := Color(0.82, 0.72, 0.20)
const _D_GOLD_DK := Color(0.58, 0.48, 0.12)
const _D_SKIN := Color(0.82, 0.70, 0.60)
const _D_STAFF := Color(0.50, 0.38, 0.20)
const _D_CRYSTAL := Color(0.55, 0.30, 0.90)
const _D_BOOT := Color(0.20, 0.15, 0.28)

const _D_SBAT := Color(0.30, 0.12, 0.45)
const _D_SBAT_DK := Color(0.18, 0.06, 0.28)
const _D_SBAT_HI := Color(0.45, 0.22, 0.60)

const _D_ICE := Color(0.50, 0.75, 0.92)
const _D_ICE_HI := Color(0.75, 0.90, 1.0)
const _D_ICE_DK := Color(0.30, 0.50, 0.70)
const _D_ICE_SOCKET := Color(0.12, 0.18, 0.35)

const _D_VOID := Color(0.12, 0.08, 0.25)
const _D_VOID_DK := Color(0.06, 0.04, 0.15)
const _D_VOID_HI := Color(0.25, 0.15, 0.50)

const _D_PHANTOM := Color(0.75, 0.75, 0.85)
const _D_PHANTOM_HI := Color(0.90, 0.90, 0.98)
const _D_PHANTOM_DK := Color(0.50, 0.50, 0.62)

const _D_LICH := Color(0.45, 0.18, 0.65)
const _D_LICH_DK := Color(0.25, 0.08, 0.38)
const _D_LICH_BONE := Color(0.80, 0.80, 0.88)


static func generate_style_d() -> Dictionary:
	return {
		"player": [_gen_d_player(0), _gen_d_player(1)],
		"bat": [_gen_d_shadowbat(0), _gen_d_shadowbat(1)],
		"skeleton": [_gen_d_iceskel(0), _gen_d_iceskel(1)],
		"zombie": [_gen_d_voidwalker(0), _gen_d_voidwalker(1)],
		"ghost": [_gen_d_phantom(0), _gen_d_phantom(1)],
		"boss": [_gen_d_boss(0), _gen_d_boss(1)],
		"gem_small": _gen_gem(
			Color(0.50, 0.25, 0.85), Color(0.72, 0.50, 1.0), Color(0.30, 0.12, 0.55)),
		"gem_medium": _gen_gem(
			Color(0.25, 0.55, 0.90), Color(0.50, 0.78, 1.0), Color(0.12, 0.32, 0.58)),
		"gem_large": _gen_gem(
			Color(0.82, 0.72, 0.18), Color(1.0, 0.92, 0.40), Color(0.52, 0.42, 0.08)),
		"projectile": _gen_d_projectile(),
	}


static func _gen_d_player(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	# Wizard hat
	_px(img, 7, 0, _D_PURPLE_DK)
	_fill(img, 6, 1, 4, 1, _D_PURPLE)
	_fill(img, 5, 2, 6, 2, _D_PURPLE)
	_px(img, 7, 0, _D_PURPLE_HI)
	# Hat brim
	_fill(img, 3, 4, 10, 1, _D_PURPLE_DK)
	# Star on hat
	_px(img, 7, 2, _D_GOLD)
	# Face
	_fill(img, 5, 5, 6, 2, _D_SKIN)
	_px(img, 6, 5, _D_CRYSTAL); _px(img, 9, 5, _D_CRYSTAL)
	# Beard
	_px(img, 6, 7, _D_PHANTOM); _px(img, 7, 7, _D_PHANTOM)
	_px(img, 8, 7, _D_PHANTOM); _px(img, 9, 7, _D_PHANTOM)
	_px(img, 7, 8, _D_PHANTOM_DK)
	# Robe body
	_fill(img, 4, 7, 8, 4, _D_PURPLE)
	_fill(img, 7, 7, 2, 4, _D_PURPLE_DK)
	_px(img, 4, 7, _D_PURPLE_DK); _px(img, 11, 7, _D_PURPLE_DK)
	# Gold trim
	_fill(img, 4, 10, 8, 1, _D_GOLD_DK)
	# Staff in hand
	_fill(img, 12, 5, 1, 6, _D_STAFF)
	_px(img, 12, 4, _D_CRYSTAL)
	_px(img, 12, 3, _D_GOLD)
	# Other arm
	_px(img, 3, 8, _D_PURPLE_DK); _px(img, 3, 9, _D_PURPLE_DK)
	# Robe bottom
	if frame == 0:
		_fill(img, 4, 11, 8, 3, _D_PURPLE_DK)
		_fill(img, 5, 14, 2, 1, _D_BOOT)
		_fill(img, 9, 14, 2, 1, _D_BOOT)
	else:
		_fill(img, 3, 11, 5, 3, _D_PURPLE_DK)
		_fill(img, 9, 11, 5, 3, _D_PURPLE_DK)
		_fill(img, 3, 14, 2, 1, _D_BOOT)
		_fill(img, 11, 14, 2, 1, _D_BOOT)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_d_shadowbat(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	if frame == 0:
		_fill(img, 6, 5, 4, 4, _D_SBAT)
		_fill(img, 7, 4, 2, 1, _D_SBAT)
		_px(img, 7, 5, _D_CRYSTAL); _px(img, 8, 5, _D_CRYSTAL)
		_fill(img, 3, 3, 3, 4, _D_SBAT)
		_fill(img, 1, 2, 2, 3, _D_SBAT_DK)
		_px(img, 0, 1, _D_SBAT_DK)
		_fill(img, 10, 3, 3, 4, _D_SBAT)
		_fill(img, 13, 2, 2, 3, _D_SBAT_DK)
		_px(img, 15, 1, _D_SBAT_DK)
		_px(img, 6, 3, _D_SBAT_HI); _px(img, 9, 3, _D_SBAT_HI)
		_px(img, 7, 9, _D_SBAT_DK); _px(img, 8, 9, _D_SBAT_DK)
	else:
		_fill(img, 6, 4, 4, 4, _D_SBAT)
		_fill(img, 7, 3, 2, 1, _D_SBAT)
		_px(img, 7, 4, _D_CRYSTAL); _px(img, 8, 4, _D_CRYSTAL)
		_fill(img, 3, 6, 3, 4, _D_SBAT)
		_fill(img, 1, 9, 2, 3, _D_SBAT_DK)
		_px(img, 0, 12, _D_SBAT_DK)
		_fill(img, 10, 6, 3, 4, _D_SBAT)
		_fill(img, 13, 9, 2, 3, _D_SBAT_DK)
		_px(img, 15, 12, _D_SBAT_DK)
		_px(img, 6, 2, _D_SBAT_HI); _px(img, 9, 2, _D_SBAT_HI)
		_px(img, 7, 8, _D_SBAT_DK); _px(img, 8, 8, _D_SBAT_DK)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_d_iceskel(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	_fill(img, 5, 0, 6, 6, _D_ICE)
	_fill(img, 6, 0, 4, 1, _D_ICE_DK)
	_fill(img, 6, 2, 2, 2, _D_ICE_SOCKET)
	_fill(img, 9, 2, 2, 2, _D_ICE_SOCKET)
	_px(img, 6, 2, _D_ICE_HI); _px(img, 9, 2, _D_ICE_HI)
	_fill(img, 6, 5, 4, 1, _D_ICE_SOCKET)
	_px(img, 7, 5, _D_ICE); _px(img, 9, 5, _D_ICE)
	# Crystal glow in eyes
	_px(img, 7, 2, _D_CRYSTAL); _px(img, 10, 2, _D_CRYSTAL)
	_fill(img, 7, 6, 2, 5, _D_ICE)
	_fill(img, 5, 7, 6, 1, _D_ICE_DK)
	_fill(img, 5, 9, 6, 1, _D_ICE_DK)
	if frame == 0:
		_fill(img, 3, 7, 2, 1, _D_ICE); _fill(img, 2, 8, 1, 2, _D_ICE)
		_fill(img, 11, 7, 2, 1, _D_ICE); _fill(img, 13, 8, 1, 2, _D_ICE)
	else:
		_fill(img, 3, 7, 2, 1, _D_ICE); _fill(img, 2, 7, 1, 2, _D_ICE)
		_fill(img, 11, 7, 2, 1, _D_ICE); _fill(img, 13, 7, 1, 2, _D_ICE)
	_fill(img, 6, 11, 4, 1, _D_ICE_DK)
	if frame == 0:
		_fill(img, 6, 12, 1, 3, _D_ICE); _fill(img, 9, 12, 1, 3, _D_ICE)
	else:
		_fill(img, 5, 12, 1, 3, _D_ICE); _fill(img, 10, 12, 1, 3, _D_ICE)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_d_voidwalker(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	_fill(img, 5, 1, 6, 5, _D_VOID)
	_fill(img, 5, 1, 6, 1, _D_VOID_DK)
	# Glowing purple eyes
	_px(img, 6, 3, _D_CRYSTAL); _px(img, 10, 3, _D_CRYSTAL)
	_px(img, 7, 3, _D_PURPLE_HI); _px(img, 10, 4, _D_PURPLE_HI)
	# Void energy
	_px(img, 5, 2, _D_VOID_HI); _px(img, 10, 2, _D_VOID_HI)
	_fill(img, 5, 6, 6, 4, _D_VOID_DK)
	_fill(img, 5, 6, 6, 1, _D_VOID)
	# Arcane runes on body
	_px(img, 7, 7, _D_PURPLE_HI); _px(img, 9, 8, _D_PURPLE_HI)
	var ay := 7 if frame == 0 else 6
	_fill(img, 2, ay, 3, 1, _D_VOID); _px(img, 1, ay + 1, _D_VOID)
	_fill(img, 11, ay, 3, 1, _D_VOID); _px(img, 14, ay + 1, _D_VOID)
	if frame == 0:
		_fill(img, 5, 10, 3, 3, _D_VOID_DK); _fill(img, 8, 10, 3, 3, _D_VOID_DK)
		_px(img, 6, 13, _D_VOID); _px(img, 9, 13, _D_VOID)
	else:
		_fill(img, 4, 10, 3, 3, _D_VOID_DK); _fill(img, 9, 10, 3, 3, _D_VOID_DK)
		_px(img, 5, 13, _D_VOID); _px(img, 10, 13, _D_VOID)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_d_phantom(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	var yo := 0 if frame == 0 else 1
	_fill(img, 6, 1 + yo, 4, 1, _D_PHANTOM)
	_fill(img, 5, 2 + yo, 6, 1, _D_PHANTOM)
	_fill(img, 4, 3 + yo, 8, 7, _D_PHANTOM)
	_fill(img, 5, 2 + yo, 6, 2, _D_PHANTOM_HI)
	# Eyes (deep voids)
	_px(img, 6, 5 + yo, _D_VOID); _px(img, 7, 5 + yo, _D_VOID)
	_px(img, 9, 5 + yo, _D_VOID); _px(img, 10, 5 + yo, _D_VOID)
	_px(img, 6, 6 + yo, _D_CRYSTAL); _px(img, 9, 6 + yo, _D_CRYSTAL)
	_fill(img, 7, 7 + yo, 3, 1, _D_PHANTOM_DK)
	for x in range(4, 12):
		if x >= 0 and (10 + yo) < 16:
			img.set_pixel(x, 10 + yo, _CLEAR)
	for x in [5, 7, 9]:
		_px(img, x, 10 + yo, _D_PHANTOM)
	for x in [4, 6, 8, 10]:
		_px(img, x, 11 + yo, _D_PHANTOM_DK)
	# Arcane glow around edges
	_px(img, 4, 4 + yo, _D_PURPLE_HI); _px(img, 11, 4 + yo, _D_PURPLE_HI)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_d_boss(frame: int) -> ImageTexture:
	var img := _img(24, 24)
	# Lich king skull
	_ellipse(img, 11, 13, 8, 7, _D_LICH_BONE)
	_ellipse(img, 11, 14, 6, 5, _D_LICH_DK)
	_ellipse(img, 11, 13, 8, 7, _D_LICH_BONE)
	# Crown
	_fill(img, 4, 5, 15, 2, _D_GOLD)
	_fill(img, 5, 4, 13, 1, _D_GOLD_DK)
	# Crown spikes
	_px(img, 5, 3, _D_GOLD); _px(img, 8, 2, _D_GOLD)
	_px(img, 11, 3, _D_GOLD); _px(img, 14, 2, _D_GOLD)
	_px(img, 17, 3, _D_GOLD)
	# Crystal in crown
	_px(img, 11, 3, _D_CRYSTAL); _px(img, 11, 4, _D_CRYSTAL)
	# Glowing eyes
	var ey := 9 if frame == 0 else 10
	_fill(img, 5, ey, 4, 3, _D_CRYSTAL)
	_fill(img, 14, ey, 4, 3, _D_CRYSTAL)
	_fill(img, 6, ey, 2, 2, _D_PURPLE_HI)
	_fill(img, 15, ey, 2, 2, _D_PURPLE_HI)
	_px(img, 6, ey + 1, _BLACK); _px(img, 15, ey + 1, _BLACK)
	# Dark mouth
	_fill(img, 7, 16, 9, 2, _D_LICH_DK)
	for x in range(8, 15, 2):
		_px(img, x, 16, _D_LICH_BONE)
	# Purple energy aura
	_px(img, 2, 10, _D_PURPLE_HI); _px(img, 20, 10, _D_PURPLE_HI)
	_px(img, 3, 18, _D_PURPLE_HI); _px(img, 19, 18, _D_PURPLE_HI)
	# Floating jaw crack
	_px(img, 9, 18, _D_LICH_DK); _px(img, 13, 18, _D_LICH_DK)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_d_projectile() -> ImageTexture:
	var img := _img(8, 8)
	_fill(img, 2, 1, 4, 1, _D_PURPLE_DK)
	_fill(img, 1, 2, 6, 4, _D_PURPLE)
	_fill(img, 2, 6, 4, 1, _D_PURPLE_DK)
	_fill(img, 3, 2, 2, 2, _D_PURPLE_HI)
	_px(img, 3, 3, _WHITE)
	_outline(img)
	return ImageTexture.create_from_image(img)


# ============================================================
#  Shared helpers (same as SpriteGen)
# ============================================================

static func _gen_gem(base: Color, hi: Color, lo: Color) -> ImageTexture:
	var img := _img(8, 8)
	_px(img, 3, 0, lo)
	_fill(img, 2, 1, 3, 1, base); _px(img, 3, 1, hi)
	_fill(img, 1, 2, 5, 1, base); _px(img, 2, 2, hi); _px(img, 3, 2, _WHITE)
	_fill(img, 0, 3, 7, 1, base); _px(img, 2, 3, hi)
	_fill(img, 1, 4, 5, 1, base); _px(img, 2, 4, hi)
	_fill(img, 2, 5, 3, 1, lo)
	_px(img, 3, 6, lo)
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


static func export_style(_style_name: String, data: Dictionary, base_dir: String) -> int:
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
				var img: Image = tex.get_image()
				var path: String = base_dir + key + "_" + str(i) + ".png"
				img.save_png(path)
				count += 1
		elif value is ImageTexture:
			var tex: ImageTexture = value
			var img: Image = tex.get_image()
			var path: String = base_dir + key + ".png"
			img.save_png(path)
			count += 1
	return count
