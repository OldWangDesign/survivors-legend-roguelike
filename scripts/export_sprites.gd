extends SceneTree

func _init() -> void:
	var base := "res://assets/sprites/"
	var Styles = preload("res://scripts/sprite_gen_styles.gd")
	var Variants = preload("res://scripts/sprite_gen_variants.gd")

	var count_a := SpriteGen.export_all_png(base + "style_a_knight/")
	print("[Export] Style A (蓝甲骑士): %d files" % count_a)

	var data_b: Dictionary = Variants.generate_style_b()
	var count_b: int = Variants.export_style("b", data_b, base + "style_b_samurai/")
	print("[Export] Style B (赤焰武士): %d files" % count_b)

	var data_c: Dictionary = Variants.generate_style_c()
	var count_c: int = Variants.export_style("c", data_c, base + "style_c_ranger/")
	print("[Export] Style C (翠林游侠): %d files" % count_c)

	var data_d: Dictionary = Variants.generate_style_d()
	var count_d: int = Variants.export_style("d", data_d, base + "style_d_mage/")
	print("[Export] Style D (暗夜法师): %d files" % count_d)

	var data_e: Dictionary = Styles.generate_style_e()
	var count_e: int = Styles.export_style(data_e, base + "style_e_pico8/")
	print("[Export] Style E (PICO-8 复古): %d files" % count_e)

	var data_f: Dictionary = Styles.generate_style_f()
	var count_f: int = Styles.export_style(data_f, base + "style_f_sweetie/")
	print("[Export] Style F (Sweetie 柔和): %d files" % count_f)

	var data_g: Dictionary = Styles.generate_style_g()
	var count_g: int = Styles.export_style(data_g, base + "style_g_gothic/")
	print("[Export] Style G (暗黑哥特): %d files" % count_g)

	var data_h: Dictionary = Styles.generate_style_h()
	var count_h: int = Styles.export_style(data_h, base + "style_h_cyber/")
	print("[Export] Style H (赛博朋克): %d files" % count_h)

	var data_i: Dictionary = Styles.generate_style_i()
	var count_i: int = Styles.export_style(data_i, base + "style_i_mystery/")
	print("[Export] Style I (神秘幸存者): %d files" % count_i)

	var data_j: Dictionary = Styles.generate_style_j()
	var count_j: int = Styles.export_style(data_j, base + "style_j_princess/")
	print("[Export] Style J (公主婚礼): %d files" % count_j)

	var total: int = count_a + count_b + count_c + count_d + count_e + count_f + count_g + count_h + count_i + count_j
	print("[Export] Done! Total: %d files across 10 styles." % total)
	quit()
