extends SceneTree

func _init() -> void:
	var BgGen = preload("res://scripts/bg_tile_gen.gd")
	var base := "res://assets/bg/"
	var total := 0

	for style_key: String in BgGen.BG_STYLES:
		var label: String = BgGen.BG_STYLES[style_key]
		var count: int = BgGen.export_style(style_key, base + style_key + "/")
		print("[BG Export] %s (%s): %d tiles" % [style_key, label, count])
		total += count

	print("[BG Export] Done! Total: %d tile PNGs." % total)
	quit()
