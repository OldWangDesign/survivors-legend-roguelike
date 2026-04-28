class_name SpriteLoader

const BASE_DIR := "res://assets/sprites/"

const STYLES := {
	"style_a_knight": "A - 蓝甲骑士",
	"style_b_samurai": "B - 赤焰武士",
	"style_c_ranger": "C - 翠林游侠",
	"style_d_mage": "D - 暗夜法师",
	"style_e_pico8": "E - PICO-8 复古",
	"style_f_sweetie": "F - Sweetie 柔和",
	"style_g_gothic": "G - 暗黑哥特",
	"style_h_cyber": "H - 赛博朋克",
	"style_i_mystery": "I - 神秘幸存者",
	"style_j_princess": "J - 公主婚礼",
}

const _ANIMATED := ["player", "bat", "skeleton", "zombie", "ghost", "boss"]
const _SINGLE := ["gem_small", "gem_medium", "gem_large", "projectile"]


static func load_all(style: String = "style_a_knight") -> Dictionary:
	var dir: String = BASE_DIR + style + "/"
	var result := {}

	for key in _ANIMATED:
		var frames: Array[ImageTexture] = []
		for i in range(2):
			var tex := _load_png(dir + key + "_" + str(i) + ".png")
			if tex:
				frames.append(tex)
		if frames.size() > 0:
			result[key] = frames

	for key in _SINGLE:
		var tex := _load_png(dir + key + ".png")
		if tex:
			result[key] = tex

	return result


static func _load_png(res_path: String) -> ImageTexture:
	if not FileAccess.file_exists(res_path):
		return null
	var abs_path: String = ProjectSettings.globalize_path(res_path)
	var img := Image.load_from_file(abs_path)
	if img == null:
		return null
	return ImageTexture.create_from_image(img)
