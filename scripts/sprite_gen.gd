class_name SpriteGen

const _CLEAR := Color(0, 0, 0, 0)
const _OL := Color(0.04, 0.04, 0.08)

# --- Player palette ---
const _P_BLUE := Color(0.16, 0.27, 0.67)
const _P_BLUE_HI := Color(0.30, 0.45, 0.85)
const _P_BLUE_DK := Color(0.10, 0.17, 0.42)
const _P_GRAY := Color(0.40, 0.40, 0.52)
const _P_BROWN := Color(0.50, 0.35, 0.20)
const _P_BROWN_DK := Color(0.30, 0.22, 0.12)
const _P_BOOT := Color(0.22, 0.22, 0.30)

# --- Bat palette ---
const _BAT := Color(0.78, 0.18, 0.18)
const _BAT_DK := Color(0.55, 0.12, 0.12)

# --- Skeleton palette ---
const _BONE := Color(0.88, 0.88, 0.92)
const _BONE_DK := Color(0.65, 0.65, 0.72)
const _BONE_HI := Color(0.95, 0.95, 0.98)
const _SOCKET := Color(0.15, 0.08, 0.08)

# --- Zombie palette ---
const _ZG := Color(0.22, 0.62, 0.28)
const _ZG_DK := Color(0.12, 0.38, 0.15)
const _ZB := Color(0.30, 0.22, 0.12)
const _ZB_DK := Color(0.20, 0.15, 0.08)

# --- Ghost palette ---
const _GH := Color(0.45, 0.28, 0.72)
const _GH_HI := Color(0.65, 0.45, 0.88)
const _GH_DK := Color(0.28, 0.15, 0.48)

# --- Boss palette (legacy 通用) ---
const _BOSS_R := Color(0.78, 0.18, 0.18)
const _BOSS_DK := Color(0.50, 0.10, 0.10)
const _BOSS_PK := Color(0.90, 0.35, 0.30)

# --- Bone Lord palette（骨白 + 金王冠 + 红宝石）---
const _BL_BONE := Color(0.92, 0.88, 0.72)
const _BL_BONE_DK := Color(0.62, 0.55, 0.40)
const _BL_BONE_HI := Color(1.0, 0.96, 0.85)
const _BL_GOLD := Color(0.98, 0.78, 0.18)
const _BL_GOLD_DK := Color(0.62, 0.45, 0.10)
const _BL_GEM := Color(0.92, 0.18, 0.22)
const _BL_EYE := Color(1.0, 0.32, 0.18)

# --- Shadow Lich palette（紫袍兜帽 + 紫光眼 + 紫法球）---
const _SL_ROBE := Color(0.45, 0.20, 0.65)
const _SL_ROBE_DK := Color(0.26, 0.08, 0.40)
const _SL_ROBE_HI := Color(0.68, 0.42, 0.88)
const _SL_FACE := Color(0.08, 0.02, 0.15)
const _SL_EYE := Color(0.92, 0.62, 1.0)
const _SL_ORB := Color(0.78, 0.40, 0.95)
const _SL_ORB_HI := Color(1.0, 0.85, 1.0)

# --- Blood Moon palette（血月圆 + 暗红恶魔头 + 白光十字眼）---
const _BM_MOON := Color(0.58, 0.06, 0.12)
const _BM_MOON_HI := Color(0.85, 0.14, 0.20)
const _BM_DEMON := Color(0.30, 0.02, 0.05)
const _BM_DEMON_HI := Color(0.55, 0.10, 0.15)
const _BM_HORN := Color(0.12, 0.04, 0.06)
const _BM_EYE := Color(1.0, 0.98, 0.85)
const _BM_FANG := Color(0.95, 0.92, 0.78)
const _BM_CRACK := Color(0.20, 0.02, 0.05)

const _WHITE := Color(0.92, 0.92, 0.96)
const _BLACK := Color(0.04, 0.04, 0.08)
const _YELLOW := Color(0.95, 0.82, 0.22)


static func generate_all() -> Dictionary:
	return {
		"player": [_gen_player(0), _gen_player(1)],
		"bat": [_gen_bat(0), _gen_bat(1)],
		"skeleton": [_gen_skeleton(0), _gen_skeleton(1)],
		"zombie": [_gen_zombie(0), _gen_zombie(1)],
		"ghost": [_gen_ghost(0), _gen_ghost(1)],
		"boss": [_gen_boss(0), _gen_boss(1)],
		"boss_bone_lord": [_gen_bone_lord(0), _gen_bone_lord(1)],
		"boss_shadow_lich": [_gen_shadow_lich(0), _gen_shadow_lich(1)],
		"boss_blood_moon": [_gen_blood_moon(0), _gen_blood_moon(1)],
		"gem_small": _gen_gem(
			Color(0.20, 0.75, 0.30), Color(0.45, 0.95, 0.55), Color(0.10, 0.45, 0.15)),
		"gem_medium": _gen_gem(
			Color(0.20, 0.50, 0.90), Color(0.45, 0.75, 1.0), Color(0.10, 0.30, 0.60)),
		"gem_large": _gen_gem(
			Color(0.90, 0.20, 0.20), Color(1.0, 0.50, 0.45), Color(0.55, 0.10, 0.10)),
		"projectile": _gen_projectile(),
	}


# ============================================================
#  Player - Blue Knight (16x16)
# ============================================================

static func _gen_player(frame: int) -> ImageTexture:
	var img := _img(16, 16)

	# Helmet
	_fill(img, 5, 1, 6, 1, _P_BLUE_DK)
	_fill(img, 4, 2, 8, 3, _P_BLUE)
	_px(img, 5, 2, _P_BLUE_HI); _px(img, 9, 2, _P_BLUE_HI)
	# Eyes
	_px(img, 6, 3, _WHITE); _px(img, 9, 3, _WHITE)
	_px(img, 7, 3, _BLACK); _px(img, 10, 3, _BLACK)

	# Neck
	_fill(img, 5, 5, 6, 1, _P_BLUE_DK)

	# Body armor
	_fill(img, 4, 6, 8, 4, _P_BLUE)
	_px(img, 4, 6, _P_BLUE_DK); _px(img, 11, 6, _P_BLUE_DK)
	_px(img, 4, 7, _P_BLUE_DK); _px(img, 11, 7, _P_BLUE_DK)

	# Arms
	_fill(img, 3, 7, 1, 3, _P_GRAY)
	_fill(img, 12, 7, 1, 3, _P_GRAY)

	# Belt
	_fill(img, 4, 10, 8, 1, _P_BROWN_DK)

	if frame == 0:
		_fill(img, 5, 11, 6, 2, _P_BROWN)
		_fill(img, 5, 13, 2, 1, _P_BOOT)
		_fill(img, 9, 13, 2, 1, _P_BOOT)
	else:
		_fill(img, 3, 11, 3, 2, _P_BROWN)
		_fill(img, 10, 11, 3, 2, _P_BROWN)
		_fill(img, 3, 13, 2, 1, _P_BOOT)
		_fill(img, 11, 13, 2, 1, _P_BOOT)

	_outline(img)
	return ImageTexture.create_from_image(img)


# ============================================================
#  Bat (16x16)
# ============================================================

static func _gen_bat(frame: int) -> ImageTexture:
	var img := _img(16, 16)

	if frame == 0:
		# Body
		_fill(img, 6, 5, 4, 4, _BAT)
		_fill(img, 7, 4, 2, 1, _BAT)
		# Eyes
		_px(img, 7, 5, _WHITE); _px(img, 8, 5, _WHITE)
		# Wings up
		_fill(img, 3, 3, 3, 4, _BAT)
		_fill(img, 1, 2, 2, 3, _BAT_DK)
		_px(img, 0, 1, _BAT_DK)
		_fill(img, 10, 3, 3, 4, _BAT)
		_fill(img, 13, 2, 2, 3, _BAT_DK)
		_px(img, 15, 1, _BAT_DK)
		# Ears
		_px(img, 6, 3, _BAT_DK); _px(img, 9, 3, _BAT_DK)
		# Feet
		_px(img, 7, 9, _BAT_DK); _px(img, 8, 9, _BAT_DK)
	else:
		# Body
		_fill(img, 6, 4, 4, 4, _BAT)
		_fill(img, 7, 3, 2, 1, _BAT)
		# Eyes
		_px(img, 7, 4, _WHITE); _px(img, 8, 4, _WHITE)
		# Wings down
		_fill(img, 3, 6, 3, 4, _BAT)
		_fill(img, 1, 9, 2, 3, _BAT_DK)
		_px(img, 0, 12, _BAT_DK)
		_fill(img, 10, 6, 3, 4, _BAT)
		_fill(img, 13, 9, 2, 3, _BAT_DK)
		_px(img, 15, 12, _BAT_DK)
		# Ears
		_px(img, 6, 2, _BAT_DK); _px(img, 9, 2, _BAT_DK)
		# Feet
		_px(img, 7, 8, _BAT_DK); _px(img, 8, 8, _BAT_DK)

	_outline(img)
	return ImageTexture.create_from_image(img)


# ============================================================
#  Skeleton (16x16)
# ============================================================

static func _gen_skeleton(frame: int) -> ImageTexture:
	var img := _img(16, 16)

	# Skull
	_fill(img, 5, 0, 6, 6, _BONE)
	_fill(img, 6, 0, 4, 1, _BONE_DK)
	# Eye sockets
	_fill(img, 6, 2, 2, 2, _SOCKET)
	_fill(img, 9, 2, 2, 2, _SOCKET)
	_px(img, 6, 2, _BONE_HI); _px(img, 9, 2, _BONE_HI)
	# Mouth
	_fill(img, 6, 5, 4, 1, _SOCKET)
	_px(img, 7, 5, _BONE); _px(img, 9, 5, _BONE)

	# Spine
	_fill(img, 7, 6, 2, 5, _BONE)
	# Ribs
	_fill(img, 5, 7, 6, 1, _BONE_DK)
	_fill(img, 5, 9, 6, 1, _BONE_DK)

	# Arms
	if frame == 0:
		_fill(img, 3, 7, 2, 1, _BONE); _fill(img, 2, 8, 1, 2, _BONE)
		_fill(img, 11, 7, 2, 1, _BONE); _fill(img, 13, 8, 1, 2, _BONE)
	else:
		_fill(img, 3, 7, 2, 1, _BONE); _fill(img, 2, 7, 1, 2, _BONE)
		_fill(img, 11, 7, 2, 1, _BONE); _fill(img, 13, 7, 1, 2, _BONE)

	# Pelvis
	_fill(img, 6, 11, 4, 1, _BONE_DK)

	# Legs
	if frame == 0:
		_fill(img, 6, 12, 1, 3, _BONE); _fill(img, 9, 12, 1, 3, _BONE)
	else:
		_fill(img, 5, 12, 1, 3, _BONE); _fill(img, 10, 12, 1, 3, _BONE)

	_outline(img)
	return ImageTexture.create_from_image(img)


# ============================================================
#  Zombie (16x16)
# ============================================================

static func _gen_zombie(frame: int) -> ImageTexture:
	var img := _img(16, 16)

	# Head
	_fill(img, 5, 1, 6, 5, _ZG)
	_fill(img, 5, 1, 6, 1, _ZG_DK)
	# Eyes
	_px(img, 6, 3, _WHITE); _px(img, 10, 3, _WHITE)
	_px(img, 7, 3, _BLACK); _px(img, 10, 4, _BLACK)

	# Body
	_fill(img, 5, 6, 6, 4, _ZB)
	_fill(img, 5, 6, 6, 1, _ZB_DK)

	# Arms stretched forward
	var ay := 7 if frame == 0 else 6
	_fill(img, 2, ay, 3, 1, _ZG); _px(img, 1, ay + 1, _ZG)
	_fill(img, 11, ay, 3, 1, _ZG); _px(img, 14, ay + 1, _ZG)

	# Legs
	if frame == 0:
		_fill(img, 5, 10, 3, 3, _ZB_DK); _fill(img, 8, 10, 3, 3, _ZB_DK)
		_px(img, 6, 13, _ZG_DK); _px(img, 9, 13, _ZG_DK)
	else:
		_fill(img, 4, 10, 3, 3, _ZB_DK); _fill(img, 9, 10, 3, 3, _ZB_DK)
		_px(img, 5, 13, _ZG_DK); _px(img, 10, 13, _ZG_DK)

	_outline(img)
	return ImageTexture.create_from_image(img)


# ============================================================
#  Ghost (16x16)
# ============================================================

static func _gen_ghost(frame: int) -> ImageTexture:
	var img := _img(16, 16)
	var yo := 0 if frame == 0 else 1

	# Body
	_fill(img, 6, 1 + yo, 4, 1, _GH)
	_fill(img, 5, 2 + yo, 6, 1, _GH)
	_fill(img, 4, 3 + yo, 8, 7, _GH)

	# Highlight band
	_fill(img, 5, 2 + yo, 6, 2, _GH_HI)

	# Eyes
	_px(img, 6, 5 + yo, _WHITE); _px(img, 7, 5 + yo, _WHITE)
	_px(img, 9, 5 + yo, _WHITE); _px(img, 10, 5 + yo, _WHITE)
	_px(img, 7, 5 + yo, _BLACK); _px(img, 10, 5 + yo, _BLACK)

	# Mouth
	_fill(img, 7, 7 + yo, 3, 1, _GH_DK)

	# Wavy bottom
	for x in range(4, 12):
		if x >= 0 and (10 + yo) < 16:
			img.set_pixel(x, 10 + yo, _CLEAR)
	for x in [5, 7, 9]:
		_px(img, x, 10 + yo, _GH)
	for x in [4, 6, 8, 10]:
		_px(img, x, 11 + yo, _GH_DK)

	_outline(img)
	return ImageTexture.create_from_image(img)


# ============================================================
#  Boss - Demon Skull (24x24)
# ============================================================

static func gen_boss_for(boss_id: String, frame: int) -> ImageTexture:
	match boss_id:
		"bone_lord": return _gen_bone_lord(frame)
		"shadow_lich": return _gen_shadow_lich(frame)
		"blood_moon": return _gen_blood_moon(frame)
	return _gen_boss(frame)


static func _gen_boss(frame: int) -> ImageTexture:
	var img := _img(24, 24)

	# Main body
	_ellipse(img, 11, 12, 9, 8, _BOSS_R)
	# Darker inner mass
	_ellipse(img, 11, 13, 6, 5, _BOSS_DK)
	# Re-cover with main color but lighter band
	_ellipse(img, 11, 12, 9, 8, _BOSS_R)
	_ellipse(img, 11, 11, 7, 5, _BOSS_PK)
	_ellipse(img, 11, 12, 9, 8, _BOSS_R)

	# Horns
	for i in range(6):
		_px(img, 4 - i, 5 - i, _BOSS_DK)
		_px(img, 5 - i, 5 - i, _BOSS_R)
		_px(img, 5 - i, 4 - i, _BOSS_DK)
		_px(img, 18 + i, 5 - i, _BOSS_DK)
		_px(img, 17 + i, 5 - i, _BOSS_R)
		_px(img, 17 + i, 4 - i, _BOSS_DK)

	# Eye glow
	var ey := 9 if frame == 0 else 10
	_fill(img, 5, ey, 4, 3, _YELLOW)
	_fill(img, 14, ey, 4, 3, _YELLOW)
	_fill(img, 6, ey, 2, 2, _WHITE)
	_fill(img, 15, ey, 2, 2, _WHITE)
	_px(img, 6, ey + 1, _BLACK); _px(img, 15, ey + 1, _BLACK)

	# Mouth
	_fill(img, 7, 16, 9, 2, _BOSS_DK)
	for x in range(8, 15, 2):
		_px(img, x, 16, _WHITE)
		_px(img, x, 17, _BONE_DK)

	_outline(img)
	return ImageTexture.create_from_image(img)


# ============================================================
#  Bone Lord (24x24) — 骷髅头 + 金王冠 + 红宝石眼
# ============================================================

static func _gen_bone_lord(frame: int) -> ImageTexture:
	var img := _img(24, 24)

	# 头骨主体（椭圆）
	_ellipse(img, 11, 12, 10, 7, _BL_BONE)
	# 顶部高光
	_ellipse(img, 11, 9, 8, 4, _BL_BONE_HI)
	# 下颌阴影
	_ellipse(img, 11, 15, 9, 4, _BL_BONE_DK)
	# 重新覆盖主体保持轮廓
	_ellipse(img, 11, 12, 10, 7, _BL_BONE)
	_ellipse(img, 11, 10, 8, 4, _BL_BONE_HI)

	# 王冠基底（横条 + 顶部金亮）
	_fill(img, 4, 3, 16, 2, _BL_GOLD)
	_fill(img, 4, 3, 16, 1, _BL_GOLD_DK)
	# 王冠左尖
	_fill(img, 5, 1, 2, 2, _BL_GOLD)
	_px(img, 5, 1, _BL_GOLD_DK)
	# 王冠中尖（最高 + 红宝石）
	_fill(img, 10, 0, 4, 3, _BL_GOLD)
	_px(img, 10, 0, _BL_GOLD_DK); _px(img, 13, 0, _BL_GOLD_DK)
	_px(img, 11, 1, _BL_GEM); _px(img, 12, 1, _BL_GEM)
	# 王冠右尖
	_fill(img, 17, 1, 2, 2, _BL_GOLD)
	_px(img, 18, 1, _BL_GOLD_DK)
	# 王冠基底两侧小宝石
	_px(img, 7, 3, _BL_GEM)
	_px(img, 16, 3, _BL_GEM)

	# 眼眶（黑色凹陷）
	_fill(img, 4, 8, 5, 4, _BLACK)
	_fill(img, 15, 8, 5, 4, _BLACK)
	# 眼眶红光
	_fill(img, 5, 9, 3, 2, _BL_EYE)
	_fill(img, 16, 9, 3, 2, _BL_EYE)
	# 红光高亮核心
	_px(img, 6, 9, _WHITE); _px(img, 17, 9, _WHITE)

	# 鼻骨（倒三角黑空）
	_px(img, 11, 12, _BLACK); _px(img, 12, 12, _BLACK)
	_fill(img, 11, 13, 2, 2, _BLACK)
	_px(img, 11, 15, _BLACK)

	# 颧骨阴影线
	_px(img, 4, 13, _BL_BONE_DK)
	_px(img, 19, 13, _BL_BONE_DK)

	# 上颚分隔
	_fill(img, 4, 16, 16, 1, _BL_BONE_DK)

	# 上颚牙齿（7 颗，frame 1 张嘴时下移）
	var upper_y: int = 17 if frame == 0 else 16
	for i in range(7):
		var tx: int = 5 + i * 2
		_px(img, tx, upper_y, _BL_BONE_HI)
		_px(img, tx, upper_y + 1, _BL_BONE)

	# 下颚（frame 0 闭合 / frame 1 张开露黑口腔）
	if frame == 0:
		_fill(img, 5, 19, 14, 2, _BL_BONE)
		_fill(img, 6, 21, 12, 1, _BL_BONE_DK)
		# 下颚牙齿
		for i in range(6):
			var tx2: int = 6 + i * 2
			_px(img, tx2, 19, _BL_BONE_HI)
	else:
		# 张开：黑色口腔 + 下颚下移 2px
		_fill(img, 5, 18, 14, 2, _BLACK)
		_fill(img, 6, 20, 12, 2, _BL_BONE)
		_fill(img, 7, 22, 10, 1, _BL_BONE_DK)
		# 下颚牙齿（更长）
		for i in range(5):
			var tx3: int = 7 + i * 2
			_px(img, tx3, 20, _BL_BONE_HI)
			_px(img, tx3, 21, _BL_BONE)

	_outline(img)
	return ImageTexture.create_from_image(img)


# ============================================================
#  Shadow Lich (24x24) — 兜帽袍 + 紫光眼 + 浮空法球
# ============================================================

static func _gen_shadow_lich(frame: int) -> ImageTexture:
	var img := _img(24, 24)

	# 兜帽尖（梯形向上收）
	_fill(img, 10, 0, 4, 2, _SL_ROBE)
	_fill(img, 9, 2, 6, 1, _SL_ROBE)
	_fill(img, 8, 3, 8, 2, _SL_ROBE)
	_fill(img, 7, 5, 10, 2, _SL_ROBE)

	# 兜帽边缘高光（顶部）
	_fill(img, 10, 0, 4, 1, _SL_ROBE_HI)
	_px(img, 9, 2, _SL_ROBE_HI)
	_px(img, 14, 2, _SL_ROBE_HI)

	# 兜帽两侧（再向外扩一点）
	_fill(img, 6, 7, 12, 1, _SL_ROBE)

	# 脸阴影（兜帽内黑色凹陷）
	_fill(img, 8, 7, 8, 5, _SL_FACE)

	# 紫光眼（左右两个）
	_fill(img, 9, 9, 2, 2, _SL_EYE)
	_fill(img, 13, 9, 2, 2, _SL_EYE)
	# 内眼瞳更亮
	_px(img, 10, 9, _WHITE)
	_px(img, 13, 9, _WHITE)

	# 袍子主体（向下扩展）
	_fill(img, 6, 12, 12, 2, _SL_ROBE)
	_fill(img, 5, 14, 14, 2, _SL_ROBE)
	_fill(img, 4, 16, 16, 3, _SL_ROBE)
	_fill(img, 3, 19, 18, 2, _SL_ROBE)

	# 袍子中线阴影（正面褶皱）
	_fill(img, 11, 13, 2, 8, _SL_ROBE_DK)

	# 袍子左肩高光
	_fill(img, 5, 15, 1, 4, _SL_ROBE_HI)
	# 袍子右肩阴影
	_fill(img, 18, 15, 1, 4, _SL_ROBE_DK)

	# 袍子下摆（不规则三尖）
	_fill(img, 3, 21, 3, 1, _SL_ROBE)
	_fill(img, 4, 22, 1, 1, _SL_ROBE_DK)
	_fill(img, 8, 21, 4, 1, _SL_ROBE)
	_fill(img, 9, 22, 2, 1, _SL_ROBE_DK)
	_fill(img, 14, 21, 3, 1, _SL_ROBE)
	_fill(img, 18, 21, 3, 1, _SL_ROBE)
	_fill(img, 19, 22, 1, 1, _SL_ROBE_DK)

	# 法球（左右浮空）— frame 0 小 / frame 1 大且亮
	if frame == 0:
		_px(img, 1, 14, _SL_ORB)
		_px(img, 22, 14, _SL_ORB)
	else:
		_fill(img, 1, 13, 2, 3, _SL_ORB)
		_fill(img, 21, 13, 2, 3, _SL_ORB)
		_px(img, 1, 14, _SL_ORB_HI)
		_px(img, 22, 14, _SL_ORB_HI)

	_outline(img)
	return ImageTexture.create_from_image(img)


# ============================================================
#  Blood Moon (24x24) — 血月圆背景 + 恶魔头 + 弯角 + 白光十字眼
# ============================================================

static func _gen_blood_moon(frame: int) -> ImageTexture:
	var img := _img(24, 24)

	# 血月圆（背景）
	_ellipse(img, 11, 11, 11, 11, _BM_MOON)
	# 月内亮带（偏上偏左）
	_ellipse(img, 9, 8, 5, 4, _BM_MOON_HI)
	# 月外圈再压一遍保持外缘统一暗红
	for x in range(24):
		for y in range(24):
			var dx := float(x) - 11.0
			var dy := float(y) - 11.0
			var d := dx * dx + dy * dy
			if d > 80.0 and d <= 121.0:
				img.set_pixel(x, y, _BM_MOON)

	# frame 1 月圆裂纹（3 条暗红裂痕）
	if frame == 1:
		# 裂纹 1（左上）
		_px(img, 4, 5, _BM_CRACK); _px(img, 5, 6, _BM_CRACK)
		_px(img, 5, 7, _BM_CRACK); _px(img, 6, 8, _BM_CRACK)
		# 裂纹 2（右）
		_px(img, 18, 6, _BM_CRACK); _px(img, 18, 7, _BM_CRACK)
		_px(img, 19, 8, _BM_CRACK); _px(img, 19, 9, _BM_CRACK)
		# 裂纹 3（下）
		_px(img, 7, 19, _BM_CRACK); _px(img, 8, 20, _BM_CRACK)
		_px(img, 9, 20, _BM_CRACK); _px(img, 10, 21, _BM_CRACK)

	# 双角（向后翘 = 头顶向左右后侧延伸）
	# 左角
	_px(img, 6, 5, _BM_HORN); _px(img, 5, 5, _BM_HORN)
	_px(img, 4, 5, _BM_HORN); _px(img, 4, 4, _BM_HORN)
	_px(img, 3, 4, _BM_HORN); _px(img, 3, 3, _BM_HORN)
	_px(img, 2, 3, _BM_HORN)
	# 右角
	_px(img, 17, 5, _BM_HORN); _px(img, 18, 5, _BM_HORN)
	_px(img, 19, 5, _BM_HORN); _px(img, 19, 4, _BM_HORN)
	_px(img, 20, 4, _BM_HORN); _px(img, 20, 3, _BM_HORN)
	_px(img, 21, 3, _BM_HORN)

	# 恶魔头（前景）
	_ellipse(img, 11, 13, 6, 5, _BM_DEMON)
	# 恶魔头高光
	_ellipse(img, 11, 11, 4, 2, _BM_DEMON_HI)

	# 眼睛（白色十字光）— frame 0 中央 / frame 1 微微闪烁向上
	var ey: int = 12 if frame == 0 else 11
	# 左眼十字
	_fill(img, 7, ey, 3, 1, _BM_EYE)
	_px(img, 8, ey - 1, _BM_EYE)
	_px(img, 8, ey + 1, _BM_EYE)
	# 右眼十字
	_fill(img, 13, ey, 3, 1, _BM_EYE)
	_px(img, 14, ey - 1, _BM_EYE)
	_px(img, 14, ey + 1, _BM_EYE)

	# 嘴部 + 獠牙
	_fill(img, 8, 15, 7, 2, _BLACK)
	# 4 颗獠牙（左右两组）
	_px(img, 8, 16, _BM_FANG)
	_px(img, 9, 17, _BM_FANG)
	_px(img, 13, 17, _BM_FANG)
	_px(img, 14, 16, _BM_FANG)

	# 下颌阴影
	_px(img, 7, 17, _BM_DEMON)
	_px(img, 15, 17, _BM_DEMON)

	_outline(img)
	return ImageTexture.create_from_image(img)


# ============================================================
#  Gem (8x8, diamond shape)
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


# ============================================================
#  Projectile (8x8)
# ============================================================

static func _gen_projectile() -> ImageTexture:
	var img := _img(8, 8)
	var C := Color(0.90, 0.85, 0.40)
	var H := Color(1.0, 1.0, 0.80)
	var D := Color(0.70, 0.55, 0.20)

	_fill(img, 2, 1, 4, 1, D)
	_fill(img, 1, 2, 6, 4, C)
	_fill(img, 2, 6, 4, 1, D)
	_fill(img, 3, 2, 2, 2, H)
	_px(img, 3, 3, _WHITE)

	_outline(img)
	return ImageTexture.create_from_image(img)


# ============================================================
#  Drawing helpers
# ============================================================

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


# ============================================================
#  Weapon Icons (16x16)
# ============================================================

static func generate_weapon_icons() -> Dictionary:
	return {
		0: _gen_icon_whip(),      # WHIP
		1: _gen_icon_magic_wand(), # MAGIC_WAND
		2: _gen_icon_knife(),      # KNIFE
		3: _gen_icon_garlic(),     # GARLIC
		4: _gen_icon_holy_water(), # HOLY_WATER
		5: _gen_icon_fireball(),   # FIREBALL
		6: _gen_icon_lightning(),  # LIGHTNING
		7: _gen_icon_cross(),      # CROSS
		8: _gen_icon_spin_blade(), # SPIN_BLADE
		9: _gen_icon_bible(),      # BIBLE
		10: _gen_icon_freeze_ray(), # FREEZE_RAY
		11: _gen_icon_poison_cloud(), # POISON_CLOUD
		12: _gen_icon_shield(),    # SHIELD
		13: _gen_icon_meteor(),    # METEOR
		14: _gen_icon_lifesteal_aura(), # LIFESTEAL_AURA
		15: _gen_icon_inferno_storm(), # INFERNO_STORM
		16: _gen_icon_absolute_zero(), # ABSOLUTE_ZERO
		17: _gen_icon_death_scythe(), # DEATH_SCYTHE
		18: _gen_icon_thor_hammer(), # THOR_HAMMER
		19: _gen_icon_plague_king(), # PLAGUE_KING
		20: _gen_icon_divine_apocalypse(), # DIVINE_APOCALYPSE
		21: _gen_icon_void_devour(), # VOID_DEVOUR
	}


# --- Basic Weapon Icons ---

static func _gen_icon_whip() -> ImageTexture:
	var img := _img(16, 16)
	var col := Color.YELLOW
	var hi := col.lightened(0.3)
	var dk := col.darkened(0.3)
	var handle := Color(0.55, 0.35, 0.15)
	_fill(img, 1, 11, 3, 4, handle)
	_fill(img, 2, 12, 1, 2, handle.lightened(0.15))
	_px(img, 3, 10, dk)
	_px(img, 4, 9, col); _px(img, 5, 8, col)
	_px(img, 6, 7, hi); _px(img, 7, 7, col)
	_px(img, 8, 8, col); _px(img, 9, 8, dk)
	_px(img, 10, 7, col); _px(img, 11, 6, hi)
	_px(img, 12, 5, col); _px(img, 13, 4, hi)
	_px(img, 13, 3, col); _px(img, 14, 2, hi)
	_px(img, 14, 1, Color(1, 1, 1))
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_icon_magic_wand() -> ImageTexture:
	var img := _img(16, 16)
	var col := Color.CYAN
	var hi := col.lightened(0.3)
	var dk := col.darkened(0.3)
	_px(img, 7, 0, hi)
	_fill(img, 6, 1, 3, 1, col); _px(img, 7, 1, Color(1, 1, 1))
	_fill(img, 5, 2, 5, 1, hi)
	_fill(img, 6, 3, 3, 1, col)
	_px(img, 7, 4, dk)
	_fill(img, 7, 5, 2, 8, col)
	_fill(img, 7, 5, 1, 4, hi)
	_fill(img, 6, 13, 4, 2, dk)
	_fill(img, 7, 13, 2, 2, col)
	_px(img, 4, 1, Color(1, 1, 1)); _px(img, 10, 1, Color(1, 1, 1))
	_px(img, 3, 3, hi); _px(img, 11, 3, hi)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_icon_knife() -> ImageTexture:
	var img := _img(16, 16)
	var col := Color.SILVER
	var hi := col.lightened(0.3)
	var dk := col.darkened(0.3)
	var handle := Color(0.55, 0.35, 0.15)
	_fill(img, 1, 12, 3, 3, handle)
	_fill(img, 2, 12, 1, 2, handle.lightened(0.15))
	_fill(img, 3, 10, 2, 2, handle.darkened(0.15))
	_fill(img, 4, 9, 3, 1, Color(0.8, 0.7, 0.2))
	_px(img, 5, 8, dk); _px(img, 6, 8, col)
	_px(img, 6, 7, dk); _px(img, 7, 7, hi)
	_px(img, 7, 6, col); _px(img, 8, 6, hi)
	_px(img, 8, 5, col); _px(img, 9, 5, hi)
	_px(img, 9, 4, col); _px(img, 10, 4, hi)
	_px(img, 10, 3, hi); _px(img, 11, 3, hi)
	_px(img, 11, 2, hi); _px(img, 12, 2, Color(1, 1, 1))
	_px(img, 12, 1, Color(1, 1, 1))
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_icon_garlic() -> ImageTexture:
	var img := _img(16, 16)
	var col := Color.GREEN_YELLOW
	var hi := col.lightened(0.3)
	var dk := col.darkened(0.3)
	var bulb := Color(0.92, 0.92, 0.82)
	var bulb_hi := Color(0.98, 0.98, 0.92)
	var bulb_dk := Color(0.78, 0.78, 0.68)
	_fill(img, 7, 1, 2, 3, col)
	_px(img, 7, 1, hi)
	_fill(img, 6, 4, 4, 1, dk)
	_ellipse(img, 7, 9, 5, 5, bulb)
	_ellipse(img, 6, 8, 3, 3, bulb_hi)
	for i in range(5, 14):
		_px(img, 7, i, bulb_dk)
	_px(img, 5, 7, bulb_dk); _px(img, 9, 7, bulb_dk)
	_px(img, 4, 9, bulb_dk); _px(img, 10, 9, bulb_dk)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_icon_holy_water() -> ImageTexture:
	var img := _img(16, 16)
	var col := Color.DODGER_BLUE
	var hi := col.lightened(0.3)
	var dk := col.darkened(0.3)
	_fill(img, 7, 0, 2, 2, Color(0.6, 0.45, 0.2))
	_fill(img, 6, 2, 4, 2, dk)
	_fill(img, 4, 4, 8, 10, col)
	_fill(img, 4, 4, 8, 2, hi)
	_fill(img, 4, 12, 8, 2, dk)
	_fill(img, 4, 5, 1, 7, hi)
	_fill(img, 7, 6, 2, 6, Color(1, 1, 1))
	_fill(img, 5, 8, 6, 2, Color(1, 1, 1))
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_icon_fireball() -> ImageTexture:
	var img := _img(16, 16)
	var col := Color.ORANGE_RED
	var hi := col.lightened(0.3)
	var dk := col.darkened(0.3)
	var core := Color(1.0, 0.9, 0.3)
	_ellipse(img, 7, 9, 5, 5, col)
	_ellipse(img, 7, 9, 3, 3, hi)
	_ellipse(img, 7, 8, 2, 1, core)
	_fill(img, 6, 3, 2, 2, col); _fill(img, 8, 3, 2, 2, col)
	_px(img, 7, 2, hi); _px(img, 9, 2, col)
	_px(img, 6, 1, col); _px(img, 8, 1, hi)
	_px(img, 7, 0, core)
	_px(img, 4, 5, dk); _px(img, 11, 6, dk)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_icon_lightning() -> ImageTexture:
	var img := _img(16, 16)
	var col := Color.LIGHT_YELLOW
	var hi := Color(1.0, 1.0, 0.6)
	var dk := col.darkened(0.3)
	_fill(img, 5, 1, 6, 2, col); _px(img, 5, 1, hi)
	_fill(img, 8, 3, 3, 1, col)
	_fill(img, 7, 4, 3, 1, dk)
	_fill(img, 6, 5, 3, 1, col)
	_fill(img, 4, 6, 7, 2, hi); _px(img, 4, 6, col)
	_fill(img, 5, 8, 3, 1, col)
	_fill(img, 4, 9, 3, 1, dk)
	_fill(img, 3, 10, 3, 1, col)
	_fill(img, 3, 11, 6, 2, col); _px(img, 8, 12, hi)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_icon_cross() -> ImageTexture:
	var img := _img(16, 16)
	var col := Color.GOLD
	var hi := col.lightened(0.3)
	var dk := col.darkened(0.3)
	_fill(img, 6, 1, 4, 14, col)
	_fill(img, 2, 4, 12, 4, col)
	_fill(img, 6, 1, 2, 14, hi)
	_fill(img, 2, 4, 12, 2, hi)
	_px(img, 9, 1, dk); _px(img, 9, 14, dk)
	_px(img, 2, 7, dk); _px(img, 13, 7, dk)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_icon_spin_blade() -> ImageTexture:
	var img := _img(16, 16)
	var col := Color.LIGHT_STEEL_BLUE
	var hi := col.lightened(0.3)
	var dk := col.darkened(0.3)
	_fill(img, 6, 6, 4, 4, col)
	_fill(img, 7, 7, 2, 2, Color(1, 1, 1))
	_fill(img, 7, 1, 2, 5, col); _px(img, 7, 1, hi)
	_px(img, 6, 2, dk); _px(img, 9, 3, dk)
	_fill(img, 10, 7, 5, 2, col); _px(img, 14, 7, hi)
	_px(img, 12, 6, dk); _px(img, 11, 9, dk)
	_fill(img, 7, 10, 2, 5, col); _px(img, 8, 14, hi)
	_px(img, 9, 13, dk); _px(img, 6, 12, dk)
	_fill(img, 1, 7, 5, 2, col); _px(img, 1, 8, hi)
	_px(img, 3, 9, dk); _px(img, 4, 6, dk)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_icon_bible() -> ImageTexture:
	var img := _img(16, 16)
	var col := Color.WHEAT
	var hi := col.lightened(0.2)
	var dk := col.darkened(0.3)
	_fill(img, 3, 2, 10, 12, col)
	_fill(img, 3, 2, 10, 1, dk)
	_fill(img, 3, 13, 10, 1, dk)
	_fill(img, 3, 2, 2, 12, dk)
	_fill(img, 5, 3, 7, 10, Color(0.95, 0.93, 0.88))
	_fill(img, 12, 3, 1, 10, hi)
	var gold := Color(0.85, 0.7, 0.2)
	_fill(img, 8, 5, 1, 5, gold)
	_fill(img, 6, 7, 5, 1, gold)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_icon_freeze_ray() -> ImageTexture:
	var img := _img(16, 16)
	var col := Color.LIGHT_CYAN
	var hi := Color(0.7, 0.95, 1.0)
	var dk := col.darkened(0.3)
	_fill(img, 7, 7, 2, 2, Color(1, 1, 1))
	_fill(img, 7, 1, 2, 14, col)
	_fill(img, 1, 7, 14, 2, col)
	for i in range(1, 6):
		_px(img, 7 + i, 7 - i, hi)
		_px(img, 7 - i, 7 + i, hi)
		_px(img, 7 - i, 7 - i, dk)
		_px(img, 8 + i, 8 + i, dk)
	_px(img, 5, 3, hi); _px(img, 10, 3, hi)
	_px(img, 5, 12, hi); _px(img, 10, 12, hi)
	_px(img, 3, 5, hi); _px(img, 12, 5, hi)
	_px(img, 3, 10, hi); _px(img, 12, 10, hi)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_icon_poison_cloud() -> ImageTexture:
	var img := _img(16, 16)
	var col := Color.DARK_GREEN
	var hi := col.lightened(0.3)
	var dk := col.darkened(0.3)
	_ellipse(img, 5, 9, 4, 4, col)
	_ellipse(img, 10, 9, 4, 4, dk)
	_ellipse(img, 7, 6, 4, 3, hi)
	_ellipse(img, 11, 6, 3, 2, col)
	_ellipse(img, 3, 7, 2, 2, dk)
	_px(img, 6, 7, Color(0.6, 0.9, 0.3))
	_px(img, 9, 7, Color(0.6, 0.9, 0.3))
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_icon_shield() -> ImageTexture:
	var img := _img(16, 16)
	var col := Color.CORNFLOWER_BLUE
	var hi := col.lightened(0.3)
	var dk := col.darkened(0.3)
	_fill(img, 2, 1, 12, 2, col)
	_fill(img, 2, 3, 12, 3, col)
	_fill(img, 3, 6, 10, 2, col)
	_fill(img, 4, 8, 8, 2, col)
	_fill(img, 5, 10, 6, 2, dk)
	_fill(img, 6, 12, 4, 1, dk)
	_fill(img, 7, 13, 2, 1, dk)
	_fill(img, 3, 2, 3, 4, hi)
	_fill(img, 7, 4, 2, 5, Color(1, 1, 1))
	_fill(img, 5, 6, 6, 1, Color(1, 1, 1))
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_icon_meteor() -> ImageTexture:
	var img := _img(16, 16)
	var col := Color.FIREBRICK
	var hi := col.lightened(0.3)
	var dk := col.darkened(0.3)
	var trail := Color(1.0, 0.6, 0.2)
	_ellipse(img, 9, 9, 4, 4, col)
	_ellipse(img, 8, 8, 2, 2, hi)
	_px(img, 8, 8, Color(1.0, 0.8, 0.3))
	_px(img, 6, 6, trail); _px(img, 5, 5, trail)
	_px(img, 4, 4, trail); _px(img, 5, 4, dk)
	_px(img, 3, 3, hi); _px(img, 4, 3, trail)
	_px(img, 2, 2, trail); _px(img, 3, 2, dk)
	_px(img, 1, 1, hi)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_icon_lifesteal_aura() -> ImageTexture:
	var img := _img(16, 16)
	var col := Color.DARK_ORCHID
	var hi := col.lightened(0.3)
	var dk := col.darkened(0.3)
	_fill(img, 3, 3, 4, 1, col); _fill(img, 9, 3, 4, 1, col)
	_fill(img, 2, 4, 5, 2, col); _fill(img, 9, 4, 5, 2, col)
	_fill(img, 7, 4, 2, 2, col)
	_fill(img, 2, 6, 12, 1, col)
	_fill(img, 3, 7, 10, 1, col)
	_fill(img, 4, 8, 8, 1, dk)
	_fill(img, 5, 9, 6, 1, dk)
	_fill(img, 6, 10, 4, 1, dk)
	_fill(img, 7, 11, 2, 1, dk)
	_fill(img, 3, 3, 2, 1, hi); _fill(img, 10, 3, 2, 1, hi)
	_fill(img, 2, 4, 2, 1, hi); _fill(img, 10, 4, 2, 1, hi)
	_px(img, 7, 6, Color(1, 1, 1))
	_outline(img)
	return ImageTexture.create_from_image(img)


# --- Super Weapon Icons ---

static func _gen_icon_inferno_storm() -> ImageTexture:
	var img := _img(16, 16)
	var col := Color(1.0, 0.4, 0.0)
	var hi := col.lightened(0.3)
	var dk := col.darkened(0.3)
	var core := Color(1.0, 0.9, 0.3)
	_ellipse(img, 7, 7, 7, 7, dk)
	_ellipse(img, 7, 7, 6, 6, col)
	_ellipse(img, 7, 7, 4, 4, hi)
	_ellipse(img, 7, 7, 2, 2, core)
	_px(img, 8, 3, core); _px(img, 9, 4, core); _px(img, 10, 5, hi)
	_px(img, 11, 7, col); _px(img, 10, 9, col)
	_px(img, 6, 11, core); _px(img, 5, 10, core); _px(img, 4, 9, hi)
	_px(img, 3, 7, col); _px(img, 4, 5, col)
	_px(img, 7, 0, hi); _px(img, 8, 0, col)
	_px(img, 0, 7, dk); _px(img, 14, 8, dk)
	_px(img, 3, 2, col); _px(img, 12, 2, col)
	_px(img, 2, 12, dk); _px(img, 13, 12, dk)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_icon_absolute_zero() -> ImageTexture:
	var img := _img(16, 16)
	var col := Color(0.5, 0.9, 1.0)
	var hi := col.lightened(0.3)
	var dk := col.darkened(0.3)
	_fill(img, 7, 0, 2, 16, col)
	_fill(img, 0, 7, 16, 2, col)
	_fill(img, 6, 6, 4, 4, hi)
	_fill(img, 7, 7, 2, 2, Color(1, 1, 1))
	for i in range(1, 7):
		_px(img, 7 - i, 7 - i, dk); _px(img, 8 + i, 8 + i, dk)
		_px(img, 8 + i, 7 - i, hi); _px(img, 7 - i, 8 + i, hi)
	_px(img, 5, 2, hi); _px(img, 10, 2, hi)
	_px(img, 5, 13, hi); _px(img, 10, 13, hi)
	_px(img, 2, 5, hi); _px(img, 13, 5, hi)
	_px(img, 2, 10, hi); _px(img, 13, 10, hi)
	_px(img, 4, 3, dk); _px(img, 11, 3, dk)
	_px(img, 4, 12, dk); _px(img, 11, 12, dk)
	_px(img, 3, 4, dk); _px(img, 12, 4, dk)
	_px(img, 3, 11, dk); _px(img, 12, 11, dk)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_icon_death_scythe() -> ImageTexture:
	var img := _img(16, 16)
	var col := Color(0.3, 0.0, 0.3)
	var hi := Color(0.6, 0.3, 0.7)
	var dk := col.darkened(0.3)
	var blade := Color(0.75, 0.75, 0.85)
	var blade_hi := Color(0.9, 0.9, 0.95)
	_fill(img, 7, 5, 2, 10, col)
	_fill(img, 7, 5, 1, 10, hi)
	_fill(img, 3, 1, 8, 2, blade)
	_fill(img, 4, 1, 6, 1, blade_hi)
	_fill(img, 2, 2, 3, 2, blade)
	_px(img, 1, 3, blade); _px(img, 1, 4, blade)
	_px(img, 2, 4, blade_hi)
	_fill(img, 10, 2, 2, 2, blade)
	_px(img, 11, 3, blade_hi)
	_fill(img, 3, 3, 7, 1, blade_hi)
	_px(img, 2, 3, blade)
	_px(img, 3, 0, hi); _px(img, 10, 0, hi)
	_fill(img, 6, 14, 4, 1, dk)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_icon_thor_hammer() -> ImageTexture:
	var img := _img(16, 16)
	var col := Color(0.6, 0.8, 1.0)
	var hi := col.lightened(0.3)
	var dk := col.darkened(0.3)
	var handle := Color(0.5, 0.35, 0.2)
	_fill(img, 2, 1, 12, 5, col)
	_fill(img, 2, 1, 12, 2, hi)
	_fill(img, 2, 5, 12, 1, dk)
	_fill(img, 2, 1, 2, 5, dk)
	_fill(img, 12, 1, 2, 5, hi)
	_fill(img, 6, 6, 4, 9, handle)
	_fill(img, 7, 6, 2, 9, handle.lightened(0.15))
	_fill(img, 6, 10, 4, 1, handle.darkened(0.2))
	_fill(img, 6, 12, 4, 1, handle.darkened(0.2))
	_px(img, 7, 2, Color(1.0, 1.0, 0.5))
	_px(img, 8, 3, Color(1.0, 1.0, 0.5))
	_px(img, 7, 4, Color(1.0, 1.0, 0.5))
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_icon_plague_king() -> ImageTexture:
	var img := _img(16, 16)
	var col := Color(0.4, 0.8, 0.0)
	var hi := col.lightened(0.3)
	var dk := col.darkened(0.3)
	var bone := Color(0.88, 0.88, 0.82)
	_ellipse(img, 7, 12, 7, 3, dk)
	_ellipse(img, 5, 11, 4, 2, col)
	_ellipse(img, 10, 11, 3, 2, col)
	_fill(img, 4, 1, 8, 7, bone)
	_fill(img, 5, 0, 6, 1, bone)
	_fill(img, 5, 8, 6, 1, bone.darkened(0.15))
	_fill(img, 5, 3, 2, 2, Color(0, 0, 0))
	_fill(img, 9, 3, 2, 2, Color(0, 0, 0))
	_px(img, 5, 3, col); _px(img, 9, 3, col)
	_px(img, 7, 5, Color(0, 0, 0)); _px(img, 8, 5, Color(0, 0, 0))
	_fill(img, 5, 7, 6, 1, Color(0, 0, 0))
	_px(img, 6, 7, bone); _px(img, 8, 7, bone); _px(img, 10, 7, bone)
	_px(img, 5, 0, hi); _px(img, 7, 0, hi); _px(img, 10, 0, hi)
	_px(img, 4, 0, col); _px(img, 11, 0, col)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_icon_divine_apocalypse() -> ImageTexture:
	var img := _img(16, 16)
	var col := Color(1.0, 0.9, 0.5)
	var hi := col.lightened(0.3)
	var dk := col.darkened(0.3)
	_fill(img, 0, 5, 4, 3, dk)
	_fill(img, 1, 4, 3, 1, col)
	_px(img, 0, 4, dk)
	_fill(img, 12, 5, 4, 3, dk)
	_fill(img, 12, 4, 3, 1, col)
	_px(img, 15, 4, dk)
	_fill(img, 1, 6, 3, 1, hi); _fill(img, 12, 6, 3, 1, hi)
	_px(img, 0, 8, dk); _px(img, 15, 8, dk)
	_px(img, 1, 8, col); _px(img, 14, 8, col)
	_fill(img, 7, 1, 2, 13, col)
	_fill(img, 4, 4, 8, 2, col)
	_fill(img, 7, 1, 1, 13, hi)
	_fill(img, 4, 4, 8, 1, hi)
	_fill(img, 7, 4, 2, 2, Color(1, 1, 1))
	_px(img, 5, 2, hi); _px(img, 10, 2, hi)
	_px(img, 5, 8, hi); _px(img, 10, 8, hi)
	_px(img, 7, 0, Color(1, 1, 1)); _px(img, 8, 0, Color(1, 1, 1))
	_outline(img)
	return ImageTexture.create_from_image(img)


static func _gen_icon_void_devour() -> ImageTexture:
	var img := _img(16, 16)
	var col := Color(0.5, 0.0, 0.7)
	var hi := col.lightened(0.3)
	var dk := col.darkened(0.3)
	var void_c := Color(0.08, 0.0, 0.12)
	_ellipse(img, 7, 7, 7, 7, dk)
	_ellipse(img, 7, 7, 6, 6, col)
	_ellipse(img, 7, 7, 4, 4, void_c)
	_ellipse(img, 7, 7, 3, 3, hi)
	_ellipse(img, 7, 7, 2, 2, void_c)
	_px(img, 7, 7, Color(0, 0, 0)); _px(img, 8, 7, Color(0, 0, 0))
	_px(img, 7, 8, Color(0, 0, 0)); _px(img, 8, 8, Color(0, 0, 0))
	_px(img, 5, 3, hi); _px(img, 10, 11, hi)
	_px(img, 3, 9, col); _px(img, 11, 5, col)
	_px(img, 2, 2, hi); _px(img, 13, 12, hi)
	_px(img, 12, 2, col); _px(img, 2, 12, col)
	_outline(img)
	return ImageTexture.create_from_image(img)


static func export_all_png(base_dir: String) -> int:
	var dir := DirAccess.open("res://")
	if dir:
		dir.make_dir_recursive(base_dir)

	var data: Dictionary = generate_all()
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
