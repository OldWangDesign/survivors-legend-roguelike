extends Node

# Polyphonic SFX players (multiple sounds can overlap)
var _sfx_players: Array[AudioStreamPlayer] = []
const SFX_POOL_SIZE := 8

var _bgm_player: AudioStreamPlayer
var _bgm_player_b: AudioStreamPlayer
var _bgm_enabled: bool = true
var _sfx_enabled: bool = true
var _master_volume: float = 0.8
var _sfx_volume: float = 0.7
var _bgm_volume: float = 0.4

var _sounds: Dictionary = {}
var _bgm_tracks: Dictionary = {}
var _current_bgm: String = "classic"
var _saved_bgm: String = ""
var _boss_bgm_active: bool = false

const BGM_STYLES: Dictionary = {
	"classic": "经典战斗",
	"dark": "幽暗地牢",
	"zombie": "僵尸围城",
	"apocalypse": "末日废土",
	"cyber": "赛博霓虹",
	"boss": "Boss 决战",
	"jpop": "日系热血",
	"gothic": "哥特城堡",
	"chiptune": "芯片狂潮",
	"latin": "拉丁律动",
	"chinese": "华风战鼓",
	"indian": "宝莱坞狂奔",
	"princess": "公主婚礼",
}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in range(SFX_POOL_SIZE):
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_sfx_players.append(p)

	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.bus = "Master"
	add_child(_bgm_player)

	_bgm_player_b = AudioStreamPlayer.new()
	_bgm_player_b.bus = "Master"
	add_child(_bgm_player_b)

	_generate_all_sounds()
	_generate_all_bgm()


# --------------- public API ---------------

func play(sound_name: String) -> void:
	if not _sfx_enabled:
		return
	var stream: AudioStream = _sounds.get(sound_name)
	if stream == null:
		return
	var player := _get_free_player()
	if player == null:
		return
	player.stream = stream
	player.volume_db = linear_to_db(_sfx_volume * _master_volume)
	player.pitch_scale = randf_range(0.9, 1.1)
	player.play()


func play_ui(sound_name: String) -> void:
	if not _sfx_enabled:
		return
	var stream: AudioStream = _sounds.get(sound_name)
	if stream == null:
		return
	var player := _get_free_player()
	if player == null:
		return
	player.stream = stream
	player.volume_db = linear_to_db(_sfx_volume * _master_volume * 0.6)
	player.pitch_scale = 1.0
	player.play()


func start_bgm(style: String = "") -> void:
	if not _bgm_enabled:
		return
	if style != "":
		_current_bgm = style
	var stream: AudioStream = _bgm_tracks.get(_current_bgm)
	if stream == null:
		return
	_bgm_player.stream = stream
	_bgm_player.volume_db = linear_to_db(_bgm_volume * _master_volume)
	_bgm_player.play()


func switch_bgm(style: String) -> void:
	if not BGM_STYLES.has(style):
		return
	_current_bgm = style
	if _bgm_enabled:
		start_bgm(style)


func get_current_bgm() -> String:
	return _current_bgm


func stop_bgm() -> void:
	_bgm_player.stop()
	_bgm_player_b.stop()
	_boss_bgm_active = false


func start_boss_bgm() -> void:
	if not _bgm_enabled or _boss_bgm_active:
		return
	_boss_bgm_active = true
	_saved_bgm = _current_bgm

	var boss_stream: AudioStream = _bgm_tracks.get("boss")
	if boss_stream == null:
		return

	_bgm_player_b.stream = boss_stream
	_bgm_player_b.volume_db = linear_to_db(0.001)
	_bgm_player_b.play()

	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_method(_set_bgm_a_volume, _bgm_volume * _master_volume, 0.0, 1.0)
	tw.tween_method(_set_bgm_b_volume, 0.0, _bgm_volume * _master_volume, 1.0)


func stop_boss_bgm() -> void:
	if not _boss_bgm_active:
		return
	_boss_bgm_active = false

	var main_stream: AudioStream = _bgm_tracks.get(_saved_bgm, _bgm_tracks.get(_current_bgm))
	if main_stream and not _bgm_player.playing:
		_bgm_player.stream = main_stream
		_bgm_player.volume_db = linear_to_db(0.001)
		_bgm_player.play()

	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_method(_set_bgm_b_volume, _bgm_volume * _master_volume, 0.0, 1.5)
	tw.tween_method(_set_bgm_a_volume, 0.0, _bgm_volume * _master_volume, 1.5)
	tw.chain().tween_callback(func(): _bgm_player_b.stop())


func _set_bgm_a_volume(v: float) -> void:
	_bgm_player.volume_db = linear_to_db(maxf(v, 0.001))


func _set_bgm_b_volume(v: float) -> void:
	_bgm_player_b.volume_db = linear_to_db(maxf(v, 0.001))


func play_jingle(jingle_name: String) -> void:
	var stream: AudioStream = _sounds.get(jingle_name)
	if stream == null:
		return
	_bgm_player.stop()
	_bgm_player.stream = stream
	_bgm_player.volume_db = linear_to_db(_bgm_volume * _master_volume * 1.2)
	_bgm_player.play()


func set_sfx_enabled(v: bool) -> void:
	_sfx_enabled = v


func set_bgm_enabled(v: bool) -> void:
	_bgm_enabled = v
	if not v:
		stop_bgm()


func set_master_volume(v: float) -> void:
	_master_volume = clampf(v, 0.0, 1.0)
	if _bgm_player.playing:
		_bgm_player.volume_db = linear_to_db(_bgm_volume * _master_volume)


# --------------- internal ---------------

func _get_free_player() -> AudioStreamPlayer:
	for p in _sfx_players:
		if not p.playing:
			return p
	return _sfx_players[randi() % SFX_POOL_SIZE]


func _generate_all_sounds() -> void:
	_sounds["player_hurt"] = _gen_noise_hit(0.12, 300.0, 100.0)
	_sounds["player_die"] = _gen_descending(0.5, 400.0, 80.0)
	_sounds["enemy_hit"] = _gen_square_blip(0.06, 500.0, 350.0)
	_sounds["enemy_die"] = _gen_noise_burst(0.15, 200.0)
	_sounds["xp_pickup"] = _gen_rising_blip(0.08, 800.0, 1200.0)
	_sounds["level_up"] = _gen_level_up_fanfare()
	_sounds["weapon_fire"] = _gen_square_blip(0.07, 250.0, 180.0)
	_sounds["weapon_whip"] = _gen_noise_sweep(0.12, 800.0, 200.0)
	_sounds["weapon_explode"] = _gen_explosion(0.25)
	_sounds["weapon_lightning"] = _gen_zap(0.15)
	_sounds["weapon_freeze"] = _gen_rising_blip(0.1, 1500.0, 2000.0)
	_sounds["weapon_poison"] = _gen_noise_burst(0.08, 120.0)
	_sounds["weapon_shield"] = _gen_shield_up()
	_sounds["weapon_meteor"] = _gen_descending(0.35, 600.0, 100.0)
	_sounds["ui_click"] = _gen_square_blip(0.04, 700.0, 600.0)
	_sounds["ui_hover"] = _gen_square_blip(0.03, 900.0, 850.0)
	_sounds["heal"] = _gen_rising_blip(0.1, 600.0, 1000.0)
	_sounds["chest_spawn"] = _gen_chest_spawn()
	_sounds["chest_open"] = _gen_chest_open()
	_sounds["menu_jingle"] = _gen_menu_jingle()
	_sounds["wave_warning"] = _gen_wave_warning()
	_sounds["elite_warning"] = _gen_elite_warning()


# --------------- waveform generators ---------------

const MIX_RATE := 22050
const FORMAT := AudioStreamWAV.FORMAT_8_BITS

func _make_wav(data: PackedByteArray, looping: bool = false) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = FORMAT
	wav.mix_rate = MIX_RATE
	wav.data = data
	if looping:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = data.size()
	return wav


func _square(phase: float) -> float:
	return 1.0 if fmod(phase, 1.0) < 0.5 else -1.0


func _saw(phase: float) -> float:
	return fmod(phase, 1.0) * 2.0 - 1.0


func _triangle(phase: float) -> float:
	var t := fmod(phase, 1.0)
	return (4.0 * absf(t - 0.5) - 1.0)


func _noise() -> float:
	return randf_range(-1.0, 1.0)


func _to_byte(sample: float, vol: float) -> int:
	return clampi(int(sample * vol * 127.0) + 128, 0, 255)


# Short square wave blip (hit, click)
func _gen_square_blip(duration: float, freq_start: float, freq_end: float) -> AudioStreamWAV:
	var samples := int(duration * MIX_RATE)
	var data := PackedByteArray()
	data.resize(samples)
	var phase := 0.0
	for i in range(samples):
		var t := float(i) / float(samples)
		var freq := lerpf(freq_start, freq_end, t)
		phase += freq / MIX_RATE
		var vol := (1.0 - t) * 0.8
		data[i] = _to_byte(_square(phase), vol)
	return _make_wav(data)


# Rising blip (pickup, heal)
func _gen_rising_blip(duration: float, freq_start: float, freq_end: float) -> AudioStreamWAV:
	var samples := int(duration * MIX_RATE)
	var data := PackedByteArray()
	data.resize(samples)
	var phase := 0.0
	for i in range(samples):
		var t := float(i) / float(samples)
		var freq := lerpf(freq_start, freq_end, t * t)
		phase += freq / MIX_RATE
		var vol := (1.0 - t * 0.5) * 0.6
		data[i] = _to_byte(_triangle(phase), vol)
	return _make_wav(data)


# Descending tone (death, meteor)
func _gen_descending(duration: float, freq_start: float, freq_end: float) -> AudioStreamWAV:
	var samples := int(duration * MIX_RATE)
	var data := PackedByteArray()
	data.resize(samples)
	var phase := 0.0
	for i in range(samples):
		var t := float(i) / float(samples)
		var freq := lerpf(freq_start, freq_end, t)
		phase += freq / MIX_RATE
		var vol := (1.0 - t) * 0.7
		var s := _square(phase) * 0.6 + _noise() * 0.4 * t
		data[i] = _to_byte(s, vol)
	return _make_wav(data)


# Noise hit (player hurt)
func _gen_noise_hit(duration: float, freq_start: float, freq_end: float) -> AudioStreamWAV:
	var samples := int(duration * MIX_RATE)
	var data := PackedByteArray()
	data.resize(samples)
	var phase := 0.0
	for i in range(samples):
		var t := float(i) / float(samples)
		var freq := lerpf(freq_start, freq_end, t)
		phase += freq / MIX_RATE
		var vol := (1.0 - t * t) * 0.7
		var s := _square(phase) * 0.3 + _noise() * 0.7
		data[i] = _to_byte(s, vol)
	return _make_wav(data)


# Noise burst (enemy death, poison)
func _gen_noise_burst(duration: float, freq: float) -> AudioStreamWAV:
	var samples := int(duration * MIX_RATE)
	var data := PackedByteArray()
	data.resize(samples)
	var phase := 0.0
	for i in range(samples):
		var t := float(i) / float(samples)
		phase += freq / MIX_RATE
		var env := (1.0 - t) * (1.0 - t)
		var s := _noise() * 0.6 + _square(phase) * 0.4
		data[i] = _to_byte(s, env * 0.8)
	return _make_wav(data)


# Noise sweep (whip)
func _gen_noise_sweep(duration: float, freq_start: float, freq_end: float) -> AudioStreamWAV:
	var samples := int(duration * MIX_RATE)
	var data := PackedByteArray()
	data.resize(samples)
	var phase := 0.0
	for i in range(samples):
		var t := float(i) / float(samples)
		var freq := lerpf(freq_start, freq_end, t)
		phase += freq / MIX_RATE
		var env := sin(t * PI) * 0.8
		var s := _noise() * 0.7 + _saw(phase) * 0.3
		data[i] = _to_byte(s, env)
	return _make_wav(data)


# Explosion (fireball)
func _gen_explosion(duration: float) -> AudioStreamWAV:
	var samples := int(duration * MIX_RATE)
	var data := PackedByteArray()
	data.resize(samples)
	var phase := 0.0
	for i in range(samples):
		var t := float(i) / float(samples)
		var freq := lerpf(150.0, 40.0, t)
		phase += freq / MIX_RATE
		var env := (1.0 - t) * 0.9
		var s := _noise() * (0.5 + 0.5 * (1.0 - t)) + _square(phase) * 0.3 * (1.0 - t)
		data[i] = _to_byte(s, env)
	return _make_wav(data)


# Electric zap (lightning)
func _gen_zap(duration: float) -> AudioStreamWAV:
	var samples := int(duration * MIX_RATE)
	var data := PackedByteArray()
	data.resize(samples)
	var phase := 0.0
	for i in range(samples):
		var t := float(i) / float(samples)
		var freq := 800.0 + sin(t * 60.0) * 400.0
		phase += freq / MIX_RATE
		var env := (1.0 - t) * 0.7
		var s := _square(phase) * 0.5 + _noise() * 0.5
		data[i] = _to_byte(s, env)
	return _make_wav(data)


# Shield activation
func _gen_shield_up() -> AudioStreamWAV:
	var duration := 0.2
	var samples := int(duration * MIX_RATE)
	var data := PackedByteArray()
	data.resize(samples)
	var phase := 0.0
	for i in range(samples):
		var t := float(i) / float(samples)
		var freq := lerpf(300.0, 800.0, t * t)
		phase += freq / MIX_RATE
		var env := sin(t * PI) * 0.6
		data[i] = _to_byte(_triangle(phase), env)
	return _make_wav(data)


# Chest appear (magical shimmer)
func _gen_chest_spawn() -> AudioStreamWAV:
	var duration := 0.3
	var samples := int(duration * MIX_RATE)
	var data := PackedByteArray()
	data.resize(samples)
	var phase := 0.0
	for i in range(samples):
		var t := float(i) / float(samples)
		var freq := lerpf(600.0, 1200.0, t)
		phase += freq / MIX_RATE
		var env := sin(t * PI) * 0.5
		var s := _triangle(phase) * 0.6 + _square(phase * 3.01) * 0.2 + _triangle(phase * 2.0) * 0.2
		data[i] = _to_byte(s, env)
	return _make_wav(data)


# Chest open (rewarding arpeggio burst)
func _gen_chest_open() -> AudioStreamWAV:
	var duration := 0.4
	var samples := int(duration * MIX_RATE)
	var data := PackedByteArray()
	data.resize(samples)
	var phase := 0.0
	var notes := [392.0, 523.3, 659.3, 784.0, 1047.0]
	for i in range(samples):
		var t := float(i) / float(samples)
		var note_idx := mini(int(t * notes.size()), notes.size() - 1)
		var freq: float = notes[note_idx]
		phase += freq / MIX_RATE
		var local_t := fmod(t * notes.size(), 1.0)
		var env := (1.0 - local_t * 0.4) * (1.0 - t * 0.3) * 0.65
		var s := _triangle(phase) * 0.5 + _square(phase * 2.0) * 0.3 + _triangle(phase * 0.5) * 0.2
		data[i] = _to_byte(s, env)
	return _make_wav(data)


# Level up fanfare (multi-note arpeggio)
func _gen_level_up_fanfare() -> AudioStreamWAV:
	var duration := 0.45
	var samples := int(duration * MIX_RATE)
	var data := PackedByteArray()
	data.resize(samples)
	var phase := 0.0
	var notes := [523.0, 659.0, 784.0, 1047.0]  # C5 E5 G5 C6
	for i in range(samples):
		var t := float(i) / float(samples)
		var note_idx := mini(int(t * notes.size()), notes.size() - 1)
		var freq: float = notes[note_idx]
		phase += freq / MIX_RATE
		var local_t := fmod(t * notes.size(), 1.0)
		var env := (1.0 - local_t * 0.5) * 0.6
		var s := _triangle(phase) * 0.7 + _square(phase * 2.0) * 0.3
		data[i] = _to_byte(s, env)
	return _make_wav(data)


func _gen_wave_warning() -> AudioStreamWAV:
	var duration := 1.8
	var samples := int(duration * MIX_RATE)
	var data := PackedByteArray()
	data.resize(samples)
	var phase_drum := 0.0
	var phase_horn := 0.0
	for i in range(samples):
		var t := float(i) / float(samples)
		var time := t * duration
		var master := 1.0
		if t > 0.85:
			master = (1.0 - t) / 0.15
		var s := 0.0
		var drum_hits: Array = [0.0, 0.15, 0.3, 0.4, 0.5, 0.57, 0.64, 0.7, 0.75, 0.8, 0.84, 0.88]
		for dh in drum_hits:
			var dt: float = time - dh * duration
			if dt >= 0.0 and dt < 0.08:
				var env: float = (1.0 - dt / 0.08)
				var freq: float = lerpf(200.0, 80.0, dt / 0.08)
				phase_drum += freq / MIX_RATE
				s += _triangle(phase_drum) * env * 0.35
		if time > 0.3:
			var horn_t: float = time - 0.3
			var horn_env: float = minf(horn_t / 0.2, 1.0) * maxf(0.0, 1.0 - (horn_t - 1.0) / 0.5)
			horn_env = maxf(horn_env, 0.0) * 0.25
			var horn_freq := 220.0 + sin(time * 3.0) * 5.0
			phase_horn += horn_freq / MIX_RATE
			s += (_saw(phase_horn) * 0.5 + _triangle(phase_horn * 2.0) * 0.3 + _square(phase_horn * 0.5) * 0.2) * horn_env
		data[i] = _to_byte(clampf(s, -1.0, 1.0), master * 0.85)
	return _make_wav(data)


func _gen_elite_warning() -> AudioStreamWAV:
	var duration := 2.0
	var samples := int(duration * MIX_RATE)
	var data := PackedByteArray()
	data.resize(samples)
	var phase_bell := 0.0
	var phase_chord := 0.0
	for i in range(samples):
		var t := float(i) / float(samples)
		var time := t * duration
		var master := 1.0
		if t > 0.85:
			master = (1.0 - t) / 0.15
		var s := 0.0
		var bell_freq := 440.0
		phase_bell += bell_freq / MIX_RATE
		var bell_env: float = 0.0
		if time < 0.01:
			bell_env = time / 0.01
		else:
			bell_env = exp(-time * 2.5)
		s += sin(phase_bell * TAU) * bell_env * 0.30
		s += sin(phase_bell * TAU * 2.003) * bell_env * 0.12
		s += sin(phase_bell * TAU * 3.01) * bell_env * 0.06
		if time > 0.15:
			var chord_t: float = time - 0.15
			var chord_env: float = minf(chord_t / 0.3, 1.0) * maxf(0.0, 1.0 - (chord_t - 0.8) / 1.0)
			chord_env = maxf(chord_env, 0.0) * 0.18
			phase_chord += 146.8 / MIX_RATE
			s += _triangle(phase_chord) * chord_env
			s += _triangle(phase_chord * 1.2) * chord_env * 0.8
			s += _triangle(phase_chord * 1.5) * chord_env * 0.6
		if time < 0.5:
			s += _noise() * exp(-time * 6.0) * 0.08
		data[i] = _to_byte(clampf(s, -1.0, 1.0), master * 0.85)
	return _make_wav(data)


func _gen_menu_jingle() -> AudioStreamWAV:
	var bpm := 156.0
	var beat := 60.0 / bpm
	var total_beats := 24.0
	var duration := beat * total_beats
	var samples := int(duration * MIX_RATE)
	var data := PackedByteArray()
	data.resize(samples)

	# Phase 1 (beat 0-3): D minor arpeggio sweeping up 3 octaves
	var arp: Array = [
		[0.0,  0.35, 146.8],   # D3
		[0.25, 0.35, 174.6],   # F3
		[0.5,  0.35, 220.0],   # A3
		[0.75, 0.35, 293.7],   # D4
		[1.0,  0.35, 349.2],   # F4
		[1.25, 0.4,  440.0],   # A4
		[1.5,  0.5,  587.3],   # D5
		[1.75, 0.5,  698.5],   # F5
		[2.0,  0.7,  880.0],   # A5
		[2.5,  1.0,  1174.7],  # D6
	]

	# Phase 2 (beat 4-17): heroic dark melody — two phrases + climax
	var melody: Array = [
		# Phrase 1: bold fanfare (D minor, descending then rising)
		[4.0,  0.4,  587.3],   # D5
		[4.5,  0.2,  587.3],   # D5 (repeat for rhythm)
		[4.75, 0.6,  698.5],   # F5
		[5.5,  0.4,  659.3],   # E5
		[6.0,  0.8,  440.0],   # A4
		[7.0,  0.4,  523.3],   # C5
		[7.5,  0.8,  587.3],   # D5
		# Phrase 2: ascending response
		[8.5,  0.4,  587.3],   # D5
		[9.0,  0.4,  698.5],   # F5
		[9.5,  0.4,  784.0],   # G5
		[10.0, 0.8,  880.0],   # A5
		[11.0, 0.35, 784.0],   # G5
		[11.5, 0.35, 698.5],   # F5
		[12.0, 0.8,  784.0],   # G5
		# Climax: triumphant rise
		[13.0, 0.4,  880.0],   # A5
		[13.5, 0.4,  988.0],   # B5
		[14.0, 0.35, 1046.5],  # C6
		[14.5, 0.35, 988.0],   # B5
		[15.0, 0.8,  1046.5],  # C6
		[16.0, 3.5,  1174.7],  # D6 (grand sustain with vibrato)
	]

	# Harmony: sustained chord pads (triangle, gentle)
	var harm: Array = [
		# [beat_start, duration_beats, [freq1, freq2, freq3]]
		[4.0,  4.0,  [293.7, 349.2, 440.0]],  # Dm
		[8.0,  4.0,  [261.6, 329.6, 392.0]],  # C
		[12.0, 2.0,  [233.1, 293.7, 349.2]],  # Bb
		[14.0, 2.0,  [220.0, 277.2, 329.6]],  # A
		[16.0, 5.0,  [293.7, 349.2, 440.0]],  # Dm (resolution)
	]

	# Percussion: kick on downbeat, snare on offbeat, hi-hat 8th notes
	var kicks: Array = [4.0, 6.0, 8.0, 10.0, 12.0, 14.0, 16.0]
	var snares: Array = [5.0, 7.0, 9.0, 11.0, 13.0, 15.0]
	var hats: Array = []
	for b in range(4, 18):
		hats.append(float(b))
		hats.append(float(b) + 0.5)

	for i in range(samples):
		var time := float(i) / float(MIX_RATE)
		var cb := time / beat
		var s := 0.0

		# Arpeggio sweep
		for note in arp:
			var nb: float = note[0]
			var nd: float = note[1]
			var nf: float = note[2]
			var nt := cb - nb
			var nt_s := nt * beat
			if nt_s >= 0.0 and nt < nd + 0.4:
				var env := 0.0
				if nt_s < 0.005:
					env = nt_s / 0.005
				elif nt < nd:
					env = 1.0
				else:
					env = maxf(0.0, 1.0 - (nt - nd) / 0.4)
				s += (_triangle(nt_s * nf) * 0.7 + sin(nt_s * nf * TAU) * 0.3) * env * 0.22

		# Melody
		for note in melody:
			var nb: float = note[0]
			var nd: float = note[1]
			var nf: float = note[2]
			var nt := cb - nb
			var nt_s := nt * beat
			if nt_s >= 0.0 and nt < nd + 0.15:
				var env := 0.0
				if nt_s < 0.006:
					env = nt_s / 0.006
				elif nt < nd * 0.75:
					env = 1.0
				else:
					env = maxf(0.0, 1.0 - (nt - nd * 0.75) / (nd * 0.25 + 0.15))
				var vibrato := 0.0
				if nd > 2.0 and nt_s > 0.3:
					vibrato = sin(nt_s * 5.5) * 3.5
				var ph := nt_s * (nf + vibrato)
				s += (_square(ph) * 0.35 + _triangle(ph) * 0.45) * env * 0.32

		# Harmony chords
		for ch in harm:
			var hb: float = ch[0]
			var hd: float = ch[1]
			var freqs: Array = ch[2]
			var ht := cb - hb
			var ht_s := ht * beat
			if ht_s >= 0.0 and ht < hd + 0.8:
				var env := 0.0
				if ht_s < 0.05:
					env = ht_s / 0.05
				elif ht < hd:
					env = 1.0
				else:
					env = maxf(0.0, 1.0 - (ht - hd) / 0.8)
				for freq in freqs:
					s += _triangle(ht_s * freq) * env * 0.055

		# Kick (pitched sine burst)
		for kb in kicks:
			var kt: float = (cb - float(kb)) * beat
			if kt >= 0.0 and kt < 0.06:
				var env := maxf(0.0, 1.0 - kt / 0.06)
				var kf := 90.0 * (1.0 + env * 2.0)
				s += sin(kt * kf * TAU) * env * 0.2

		# Snare (noise burst)
		for sb in snares:
			var st: float = (cb - float(sb)) * beat
			if st >= 0.0 and st < 0.045:
				s += _noise() * maxf(0.0, 1.0 - st / 0.045) * 0.12

		# Hi-hat (short noise tick)
		for hb in hats:
			var ht: float = (cb - float(hb)) * beat
			if ht >= 0.0 and ht < 0.015:
				s += _noise() * maxf(0.0, 1.0 - ht / 0.015) * 0.05

		# Master envelope: fade in + fade out
		var master := 1.0
		if cb < 0.3:
			master = cb / 0.3
		elif cb > total_beats - 3.0:
			master = maxf(0.0, (total_beats - cb) / 3.0)

		data[i] = _to_byte(clampf(s, -1.0, 1.0), master * 0.85)

	return _make_wav(data)


# --------------- BGM generators ---------------

func _generate_all_bgm() -> void:
	_bgm_tracks["classic"] = _gen_bgm_classic()
	_bgm_tracks["dark"] = _gen_bgm_dark()
	_bgm_tracks["zombie"] = _gen_bgm_zombie()
	_bgm_tracks["apocalypse"] = _gen_bgm_apocalypse()
	_bgm_tracks["cyber"] = _gen_bgm_cyber()
	_bgm_tracks["boss"] = _gen_bgm_boss()
	_bgm_tracks["jpop"] = _gen_bgm_jpop()
	_bgm_tracks["gothic"] = _gen_bgm_gothic()
	_bgm_tracks["chiptune"] = _gen_bgm_chiptune()
	_bgm_tracks["latin"] = _gen_bgm_latin()
	_bgm_tracks["chinese"] = _gen_bgm_chinese()
	_bgm_tracks["indian"] = _gen_bgm_indian()
	_bgm_tracks["princess"] = _gen_bgm_princess()


func _gen_bgm_classic() -> AudioStreamWAV:
	var bpm := 140.0
	var beat := 60.0 / bpm
	var bars := 8
	var bar_len := beat * 4
	var total_dur := bar_len * bars
	var samples := int(total_dur * MIX_RATE)
	var data := PackedByteArray()
	data.resize(samples)

	var chords: Array = [
		[220.0, 261.6, 329.6],
		[174.6, 220.0, 261.6],
		[261.6, 329.6, 392.0],
		[196.0, 246.9, 293.7],
	]
	var bass_notes: Array = [110.0, 87.3, 130.8, 98.0]

	var phase_bass := 0.0
	var phase_lead := 0.0
	var phases_chord: Array = [0.0, 0.0, 0.0]

	for i in range(samples):
		var t := float(i) / float(MIX_RATE)
		var bar := int(t / bar_len) % bars
		var chord_idx := (bar / 2) % chords.size()
		var beat_in_bar := fmod(t, beat)
		var beat_num := int(fmod(t, bar_len) / beat)

		var chord: Array = chords[chord_idx]
		var bass_freq: float = bass_notes[chord_idx]

		var bass_vol := 0.0
		if beat_num == 0 or beat_num == 2:
			var bt := beat_in_bar / beat
			bass_vol = (1.0 - bt) * 0.35
		phase_bass += bass_freq / MIX_RATE
		var bass_s := _square(phase_bass) * bass_vol

		var chord_s := 0.0
		for ci in range(3):
			phases_chord[ci] += (chord[ci] * 2.0) / MIX_RATE
			chord_s += _triangle(phases_chord[ci])
		chord_s = chord_s / 3.0 * 0.15

		var arp_idx := int(fmod(t * 8.0, 3.0))
		var lead_freq: float = chord[arp_idx] * 2.0
		phase_lead += lead_freq / MIX_RATE
		var arp_t := fmod(t * 8.0, 1.0)
		var lead_env := (1.0 - arp_t) * 0.2
		var lead_s := _square(phase_lead) * lead_env

		var hh_vol := 0.0
		var eighth_t := fmod(t * (bpm / 60.0) * 2.0, 1.0)
		if eighth_t < 0.15:
			hh_vol = (1.0 - eighth_t / 0.15) * 0.12

		var mix := bass_s + chord_s + lead_s + _noise() * hh_vol
		data[i] = _to_byte(mix, 0.9)

	return _make_wav(data, true)


func _gen_bgm_dark() -> AudioStreamWAV:
	var bpm := 80.0
	var beat := 60.0 / bpm
	var bars := 8
	var bar_len := beat * 4
	var total_dur := bar_len * bars
	var samples := int(total_dur * MIX_RATE)
	var data := PackedByteArray()
	data.resize(samples)

	# Dm - Bb - Gm - A (minor key, slow and haunting)
	var chords: Array = [
		[146.8, 174.6, 220.0],  # Dm
		[116.5, 146.8, 174.6],  # Bb
		[98.0, 116.5, 146.8],   # Gm
		[110.0, 138.6, 164.8],  # A
	]
	var bass_notes: Array = [73.4, 58.3, 49.0, 55.0]

	var ph_b := 0.0
	var ph_l := 0.0
	var ph_c: Array = [0.0, 0.0, 0.0]
	var ph_drone := 0.0

	for i in range(samples):
		var t := float(i) / float(MIX_RATE)
		var bar := int(t / bar_len) % bars
		var ci := (bar / 2) % chords.size()
		var beat_in_bar := fmod(t, beat)
		var beat_num := int(fmod(t, bar_len) / beat)

		var chord: Array = chords[ci]
		var bf: float = bass_notes[ci]

		# Deep rumbling bass with slow attack
		var bass_vol := 0.0
		if beat_num == 0:
			var bt := beat_in_bar / (beat * 2.0)
			bass_vol = (1.0 - bt) * 0.3
		ph_b += bf / MIX_RATE
		var bass_s := (_square(ph_b) * 0.6 + _saw(ph_b * 0.5) * 0.4) * bass_vol

		# Eerie sustained chord pads
		var chord_s := 0.0
		for j in range(3):
			ph_c[j] += chord[j] / MIX_RATE
			chord_s += _triangle(ph_c[j]) * 0.7 + _saw(ph_c[j]) * 0.3
		chord_s = chord_s / 3.0 * 0.12

		# Low drone that slowly oscillates
		ph_drone += 36.7 / MIX_RATE
		var drone := _saw(ph_drone) * 0.08 * (0.7 + 0.3 * sin(t * 0.5))

		# Sparse high-pitched melody (every 2 beats, ghostly)
		var lead_s := 0.0
		var sixteenth := fmod(t * (bpm / 60.0) * 4.0, 16.0)
		if sixteenth < 1.0 or (sixteenth > 6.0 and sixteenth < 7.0) or (sixteenth > 12.0 and sixteenth < 13.0):
			var note_idx := int(fmod(t * 2.0, 3.0))
			var lf: float = chord[note_idx] * 4.0
			ph_l += lf / MIX_RATE
			var env := (1.0 - fmod(sixteenth, 1.0)) * 0.15
			lead_s = _triangle(ph_l) * env

		# Occasional noise whisper
		var whisper := 0.0
		if fmod(t * 0.7, 4.0) < 0.3:
			whisper = _noise() * 0.04

		var mix := bass_s + chord_s + drone + lead_s + whisper
		data[i] = _to_byte(mix, 0.9)

	return _make_wav(data, true)


func _gen_bgm_zombie() -> AudioStreamWAV:
	var bpm := 100.0
	var beat := 60.0 / bpm
	var bars := 8
	var bar_len := beat * 4
	var total_dur := bar_len * bars
	var samples := int(total_dur * MIX_RATE)
	var data := PackedByteArray()
	data.resize(samples)

	# Em - C - Am - B (tense, groaning progression)
	var chords: Array = [
		[164.8, 196.0, 246.9],  # Em
		[130.8, 164.8, 196.0],  # C
		[110.0, 130.8, 164.8],  # Am
		[123.5, 155.6, 185.0],  # B
	]
	var bass_notes: Array = [82.4, 65.4, 55.0, 61.7]

	var ph_b := 0.0
	var ph_l := 0.0
	var ph_c: Array = [0.0, 0.0, 0.0]

	for i in range(samples):
		var t := float(i) / float(MIX_RATE)
		var bar := int(t / bar_len) % bars
		var ci := (bar / 2) % chords.size()
		var beat_in_bar := fmod(t, beat)
		var beat_num := int(fmod(t, bar_len) / beat)

		var chord: Array = chords[ci]
		var bf: float = bass_notes[ci]

		# Punchy distorted bass on every beat
		var b_env := 0.0
		var bt := beat_in_bar / beat
		b_env = maxf(0.0, (1.0 - bt * 1.5)) * 0.35
		ph_b += bf / MIX_RATE
		var bass_s := _square(ph_b) * b_env
		# Add subtle detuned layer for "groan" feel
		bass_s += _saw(ph_b * 1.01) * b_env * 0.3

		# Staccato chord stabs on off-beats
		var chord_s := 0.0
		if beat_num == 1 or beat_num == 3:
			var c_env := maxf(0.0, (1.0 - bt * 2.0)) * 0.18
			for j in range(3):
				ph_c[j] += chord[j] * 2.0 / MIX_RATE
				chord_s += _square(ph_c[j]) * c_env
			chord_s /= 3.0
		else:
			for j in range(3):
				ph_c[j] += chord[j] * 2.0 / MIX_RATE

		# Shuffling hi-hat pattern (zombie footsteps feel)
		var hh := 0.0
		var swing := fmod(t * (bpm / 60.0) * 2.0, 1.0)
		if swing < 0.08:
			hh = (1.0 - swing / 0.08) * 0.15
		elif swing > 0.6 and swing < 0.68:
			hh = (1.0 - (swing - 0.6) / 0.08) * 0.08

		# Moaning lead (pitch bends)
		var lead_s := 0.0
		var phrase := fmod(t * (bpm / 60.0) / 2.0, 4.0)
		if phrase < 1.0:
			var note: float = chord[0] * 2.0
			var bend := sin(phrase * TAU) * 8.0
			ph_l += (note + bend) / MIX_RATE
			var env := sin(phrase * PI) * 0.12
			lead_s = _triangle(ph_l) * env
		elif phrase > 2.0 and phrase < 3.0:
			var p2 := phrase - 2.0
			var note: float = chord[2] * 2.0
			var bend := sin(p2 * TAU * 1.5) * 12.0
			ph_l += (note + bend) / MIX_RATE
			var env := sin(p2 * PI) * 0.10
			lead_s = _saw(ph_l) * env

		var mix := bass_s + chord_s + _noise() * hh + lead_s
		data[i] = _to_byte(mix, 0.9)

	return _make_wav(data, true)


func _gen_bgm_apocalypse() -> AudioStreamWAV:
	var bpm := 110.0
	var beat := 60.0 / bpm
	var bars := 8
	var bar_len := beat * 4
	var total_dur := bar_len * bars
	var samples := int(total_dur * MIX_RATE)
	var data := PackedByteArray()
	data.resize(samples)

	# Power chord progression: E5 - C5 - G5 - D5 (heroic/desperate)
	var roots: Array = [82.4, 65.4, 98.0, 73.4]
	var fifths: Array = [123.5, 98.0, 146.8, 110.0]

	var ph_b := 0.0
	var ph_5 := 0.0
	var ph_l := 0.0
	var ph_pad := 0.0

	# Melody notes per chord
	var melodies: Array = [
		[329.6, 392.0, 329.6, 493.9],
		[261.6, 329.6, 392.0, 329.6],
		[392.0, 493.9, 392.0, 329.6],
		[293.7, 349.2, 293.7, 220.0],
	]

	for i in range(samples):
		var t := float(i) / float(MIX_RATE)
		var bar := int(t / bar_len) % bars
		var ci := (bar / 2) % roots.size()
		var beat_in_bar := fmod(t, beat)
		var beat_num := int(fmod(t, bar_len) / beat)
		var bt := beat_in_bar / beat

		# Driving distorted power chord bass
		ph_b += roots[ci] / MIX_RATE
		ph_5 += fifths[ci] / MIX_RATE
		var drive := 0.0
		if beat_num == 0 or beat_num == 2:
			drive = maxf(0.0, 1.0 - bt * 0.8) * 0.25
		elif beat_num == 3:
			drive = maxf(0.0, 1.0 - bt * 1.2) * 0.20
		var power := (_square(ph_b) + _square(ph_5) * 0.8) * drive

		# Noise-heavy snare on beats 1, 3
		var snare := 0.0
		if (beat_num == 1 or beat_num == 3) and bt < 0.2:
			snare = _noise() * (1.0 - bt / 0.2) * 0.2

		# Aggressive 16th note hi-hat
		var hh_t := fmod(t * (bpm / 60.0) * 4.0, 1.0)
		var hh := 0.0
		if hh_t < 0.1:
			hh = (1.0 - hh_t / 0.1) * 0.10

		# Heroic melody over the top
		var mel: Array = melodies[ci]
		var mel_note: float = mel[beat_num % mel.size()]
		ph_l += mel_note / MIX_RATE
		var mel_env := sin(bt * PI) * 0.18
		var lead_s := (_triangle(ph_l) * 0.7 + _square(ph_l * 2.0) * 0.3) * mel_env

		# Low rumble pad
		ph_pad += 41.2 / MIX_RATE
		var pad := _saw(ph_pad) * 0.06 * (0.8 + 0.2 * sin(t * 0.3))

		var mix := power + snare + _noise() * hh + lead_s + pad
		data[i] = _to_byte(mix, 0.85)

	return _make_wav(data, true)


func _gen_bgm_cyber() -> AudioStreamWAV:
	var bpm := 128.0
	var beat := 60.0 / bpm
	var bars := 8
	var bar_len := beat * 4
	var total_dur := bar_len * bars
	var samples := int(total_dur * MIX_RATE)
	var data := PackedByteArray()
	data.resize(samples)

	# Synth-wave chords: Am - F - Dm - E (80s retro-future)
	var chords: Array = [
		[220.0, 261.6, 329.6],
		[174.6, 220.0, 261.6],
		[146.8, 174.6, 220.0],
		[164.8, 207.7, 246.9],
	]
	var bass_notes: Array = [110.0, 87.3, 73.4, 82.4]

	var ph_b := 0.0
	var ph_c: Array = [0.0, 0.0, 0.0]
	var ph_sub := 0.0
	var ph_arp := 0.0

	for i in range(samples):
		var t := float(i) / float(MIX_RATE)
		var bar := int(t / bar_len) % bars
		var ci := (bar / 2) % chords.size()
		var beat_in_bar := fmod(t, beat)
		var beat_num := int(fmod(t, bar_len) / beat)
		var bt := beat_in_bar / beat

		var chord: Array = chords[ci]
		var bf: float = bass_notes[ci]

		# Punchy synth bass (sidechained feel)
		var kick_env := maxf(0.0, 1.0 - bt * 3.0) if (beat_num % 2 == 0) else 0.0
		var sc := 1.0 - kick_env * 0.6  # sidechain compression
		ph_b += bf / MIX_RATE
		var bass_s := _saw(ph_b) * 0.25 * sc

		# Sub bass
		ph_sub += (bf * 0.5) / MIX_RATE
		var sub := _triangle(ph_sub) * 0.15 * sc

		# Kick drum
		var kick := 0.0
		if beat_num % 2 == 0 and bt < 0.12:
			var kp := bt / 0.12
			kick = sin(kp * TAU * lerpf(160.0, 40.0, kp)) * (1.0 - kp) * 0.35

		# Bright chord pads with filter sweep
		var chord_s := 0.0
		var filter_t := 0.5 + 0.5 * sin(t * 0.25 * TAU)
		for j in range(3):
			ph_c[j] += chord[j] * 2.0 / MIX_RATE
			var raw := _saw(ph_c[j])
			chord_s += raw * filter_t
		chord_s = chord_s / 3.0 * 0.10 * sc

		# Fast arpeggio (16th notes cycling through chord + octave)
		var arp_notes: Array = [chord[0], chord[1], chord[2], chord[0] * 2.0, chord[2], chord[1]]
		var arp_idx := int(fmod(t * (bpm / 60.0) * 4.0, arp_notes.size()))
		var arp_freq: float = arp_notes[arp_idx] * 2.0
		ph_arp += arp_freq / MIX_RATE
		var arp_env := fmod(t * (bpm / 60.0) * 4.0, 1.0)
		arp_env = (1.0 - arp_env) * 0.12
		var arp_s := _square(ph_arp) * arp_env * sc

		# Closed hi-hat (every 8th)
		var hh := 0.0
		var hh_t := fmod(t * (bpm / 60.0) * 2.0, 1.0)
		if hh_t < 0.08:
			hh = (1.0 - hh_t / 0.08) * 0.09

		# Open hat on off-beats
		if beat_num % 2 == 1 and bt < 0.25:
			hh += (1.0 - bt / 0.25) * 0.06

		# Snare clap on beat 1, 3
		var clap := 0.0
		if (beat_num == 1 or beat_num == 3) and bt < 0.08:
			clap = _noise() * (1.0 - bt / 0.08) * 0.18

		var mix := bass_s + sub + kick + chord_s + arp_s + _noise() * hh + clap
		data[i] = _to_byte(mix, 0.85)

	return _make_wav(data, true)


func _gen_bgm_boss() -> AudioStreamWAV:
	var bpm := 160.0
	var beat := 60.0 / bpm
	var bars := 8
	var bar_len := beat * 4
	var total_dur := bar_len * bars
	var samples := int(total_dur * MIX_RATE)
	var data := PackedByteArray()
	data.resize(samples)

	# Aggressive minor: Em - C - D - B (epic boss fight)
	var chords: Array = [
		[164.8, 196.0, 246.9],  # Em
		[130.8, 164.8, 196.0],  # C
		[146.8, 174.6, 220.0],  # D
		[123.5, 155.6, 185.0],  # B
	]
	var bass_notes: Array = [82.4, 65.4, 73.4, 61.7]

	var ph_b := 0.0
	var ph_l := 0.0
	var ph_c: Array = [0.0, 0.0, 0.0]
	var ph_oct := 0.0

	for i in range(samples):
		var t := float(i) / float(MIX_RATE)
		var bar := int(t / bar_len) % bars
		var ci := (bar / 2) % chords.size()
		var beat_in_bar := fmod(t, beat)
		var beat_num := int(fmod(t, bar_len) / beat)
		var bt := beat_in_bar / beat

		var chord: Array = chords[ci]
		var bf: float = bass_notes[ci]

		# Relentless 8th note bass
		var eighth_t := fmod(t * (bpm / 60.0) * 2.0, 1.0)
		var b_env := maxf(0.0, 1.0 - eighth_t * 1.5) * 0.30
		ph_b += bf / MIX_RATE
		var bass_s := _square(ph_b) * b_env

		# Octave bass on every other 8th
		var eighth_idx := int(t * (bpm / 60.0) * 2.0) % 4
		if eighth_idx == 1 or eighth_idx == 3:
			ph_oct += (bf * 2.0) / MIX_RATE
			bass_s += _square(ph_oct) * b_env * 0.5

		# Rapid power chord stabs
		var chord_s := 0.0
		var stab_env := maxf(0.0, 1.0 - eighth_t * 2.0) * 0.15
		for j in range(3):
			ph_c[j] += chord[j] * 2.0 / MIX_RATE
			chord_s += _saw(ph_c[j])
		chord_s = chord_s / 3.0 * stab_env

		# Intense double-time kick
		var kick := 0.0
		if bt < 0.08:
			var kp := bt / 0.08
			kick = sin(kp * TAU * lerpf(200.0, 50.0, kp)) * (1.0 - kp) * 0.3

		# Snare blast on 2 and 4 + ghost notes
		var snare := 0.0
		if (beat_num == 1 or beat_num == 3) and bt < 0.1:
			snare = _noise() * (1.0 - bt / 0.1) * 0.22
		elif eighth_idx == 3 and eighth_t < 0.06:
			snare = _noise() * (1.0 - eighth_t / 0.06) * 0.08

		# Frantic hi-hat (16th notes)
		var hh_t := fmod(t * (bpm / 60.0) * 4.0, 1.0)
		var hh := 0.0
		if hh_t < 0.08:
			hh = (1.0 - hh_t / 0.08) * 0.10

		# Screaming lead melody
		var mel_beat := fmod(t * (bpm / 60.0), 4.0)
		var mel_idx := int(mel_beat) % 3
		var lead_freq: float = chord[mel_idx] * 4.0
		var vibrato := sin(t * 30.0) * 6.0
		ph_l += (lead_freq + vibrato) / MIX_RATE
		var lead_env := sin(fmod(mel_beat, 1.0) * PI) * 0.14
		var lead_s := (_square(ph_l) * 0.6 + _saw(ph_l) * 0.4) * lead_env

		var mix := bass_s + chord_s + kick + snare + _noise() * hh + lead_s
		data[i] = _to_byte(mix, 0.80)

	return _make_wav(data, true)


func _gen_bgm_jpop() -> AudioStreamWAV:
	var bpm := 155.0
	var beat := 60.0 / bpm
	var bars := 8
	var bar_len := beat * 4
	var total_dur := bar_len * bars
	var samples := int(total_dur * MIX_RATE)
	var data := PackedByteArray()
	data.resize(samples)

	# Am - F - G - Em (J-rock staple)
	var chords: Array = [
		[220.0, 261.6, 329.6],
		[174.6, 220.0, 261.6],
		[196.0, 246.9, 293.7],
		[164.8, 196.0, 246.9],
	]
	var bass_notes: Array = [110.0, 87.3, 98.0, 82.4]

	# A minor pentatonic melody
	var melody: Array = [440.0, 523.3, 587.3, 659.3, 784.0, 880.0, 659.3, 523.3,
						  784.0, 880.0, 1047.0, 880.0, 784.0, 659.3, 587.3, 440.0]

	var ph_b := 0.0
	var ph_l := 0.0
	var ph_c: Array = [0.0, 0.0, 0.0]

	for i in range(samples):
		var t := float(i) / float(MIX_RATE)
		var bar := int(t / bar_len) % bars
		var ci := (bar / 2) % chords.size()
		var beat_in_bar := fmod(t, beat)
		var beat_num := int(fmod(t, bar_len) / beat)
		var bt := beat_in_bar / beat

		var chord: Array = chords[ci]
		var bf: float = bass_notes[ci]

		# Driving 8th note bass
		var eighth_t := fmod(t * (bpm / 60.0) * 2.0, 1.0)
		var b_env := maxf(0.0, 1.0 - eighth_t * 1.2) * 0.28
		ph_b += bf / MIX_RATE
		var bass_s := (_square(ph_b) * 0.7 + _saw(ph_b) * 0.3) * b_env

		# Bright power chord stabs
		var chord_s := 0.0
		var c_env := maxf(0.0, 1.0 - bt * 1.0) * 0.14
		for j in range(3):
			ph_c[j] += chord[j] * 2.0 / MIX_RATE
			chord_s += _saw(ph_c[j])
		chord_s = chord_s / 3.0 * c_env

		# Energetic kick
		var kick := 0.0
		if bt < 0.1:
			var kp := bt / 0.1
			kick = sin(kp * TAU * lerpf(180.0, 50.0, kp)) * (1.0 - kp) * 0.28

		# Snare on 1, 3
		var snare := 0.0
		if (beat_num == 1 or beat_num == 3) and bt < 0.08:
			snare = _noise() * (1.0 - bt / 0.08) * 0.20

		# Fast hi-hat 16th
		var hh_t := fmod(t * (bpm / 60.0) * 4.0, 1.0)
		var hh_idx := int(t * (bpm / 60.0) * 4.0) % 4
		var hh := 0.0
		if hh_t < 0.07:
			var accent := 0.12 if hh_idx == 0 else 0.06
			hh = (1.0 - hh_t / 0.07) * accent

		# Catchy pentatonic melody
		var mel_idx := int(fmod(t * (bpm / 60.0) * 2.0, melody.size()))
		var mel_freq: float = melody[mel_idx]
		ph_l += mel_freq / MIX_RATE
		var mel_env := (1.0 - eighth_t) * 0.16
		var lead_s := (_triangle(ph_l) * 0.6 + _square(ph_l * 2.0) * 0.4) * mel_env

		var mix := bass_s + chord_s + kick + snare + _noise() * hh + lead_s
		data[i] = _to_byte(mix, 0.85)

	return _make_wav(data, true)


func _gen_bgm_gothic() -> AudioStreamWAV:
	# Castlevania-inspired gothic rock: driving minor key riffs, punchy rhythm
	var bpm := 155.0
	var beat := 60.0 / bpm
	var bars := 8
	var bar_len := beat * 4
	var total_dur := bar_len * bars
	var samples := int(total_dur * MIX_RATE)
	var data := PackedByteArray()
	data.resize(samples)

	# D minor power chord progression
	var chords: Array = [
		[146.8, 220.0, 293.7],  # D3-A3-D4
		[130.8, 196.0, 261.6],  # C3-G3-C4
		[123.5, 185.0, 246.9],  # B2-F#3-B3
		[110.0, 164.8, 220.0],  # A2-E3-A3
	]
	var bass_notes: Array = [73.4, 65.4, 61.7, 55.0]

	# Aggressive lead melody: minor scale riff
	var melody: Array = [587.3, 523.3, 587.3, 698.5, 659.3, 587.3, 523.3, 440.0,
						  587.3, 659.3, 698.5, 784.0, 698.5, 659.3, 587.3, 523.3]

	var ph_b := 0.0
	var ph_l := 0.0
	var ph_c: Array = [0.0, 0.0, 0.0]

	for i in range(samples):
		var t := float(i) / float(MIX_RATE)
		var bar := int(t / bar_len) % bars
		var ci := (bar / 2) % chords.size()
		var beat_in_bar := fmod(t, beat)
		var beat_num := int(fmod(t, bar_len) / beat)
		var bt := beat_in_bar / beat

		var chord: Array = chords[ci]
		var bf: float = bass_notes[ci]

		# Pumping eighth-note bass (square wave, punchy)
		var eighth_t := fmod(t * (bpm / 60.0) * 2.0, 1.0)
		ph_b += bf / MIX_RATE
		var bass_env := maxf(0.0, 1.0 - eighth_t * 2.5) * 0.30
		var bass_s := _square(ph_b) * bass_env

		# Distorted power chords (square + saw mix, rhythmic stabs)
		var chord_s := 0.0
		if beat_num == 0 or beat_num == 1 or beat_num == 3:
			var stab_env := maxf(0.0, 1.0 - bt * 1.8) * 0.14
			for j in range(3):
				ph_c[j] += chord[j] / MIX_RATE
				chord_s += (_square(ph_c[j]) * 0.6 + _saw(ph_c[j]) * 0.4)
			chord_s = chord_s / 3.0 * stab_env
		else:
			for j in range(3):
				ph_c[j] += chord[j] / MIX_RATE

		# Fast lead melody (square wave, sharp attack)
		var mel_beat := t * (bpm / 60.0)
		var mel_idx := int(fmod(mel_beat, melody.size()))
		var mel_frac := fmod(mel_beat, 1.0)
		var mel_freq: float = melody[mel_idx]
		ph_l += mel_freq / MIX_RATE
		var mel_env := maxf(0.0, 1.0 - mel_frac * 1.2) * 0.22
		var lead_s := _square(ph_l) * mel_env

		# Kick on 1 and 3
		var kick := 0.0
		if (beat_num == 0 or beat_num == 2) and bt < 0.08:
			var kt := bt / 0.08
			kick = _square(t * lerpf(180.0, 60.0, kt)) * (1.0 - kt) * 0.25

		# Snare on 2 and 4
		var snare := 0.0
		if (beat_num == 1 or beat_num == 3) and bt < 0.06:
			snare = _noise() * (1.0 - bt / 0.06) * 0.18

		# Fast hi-hat (sixteenth notes)
		var hh := 0.0
		var sixteenth_t := fmod(t * (bpm / 60.0) * 4.0, 1.0)
		if sixteenth_t < 0.04:
			hh = _noise() * (1.0 - sixteenth_t / 0.04) * 0.08

		var mix := bass_s + chord_s + lead_s + kick + snare + hh
		data[i] = _to_byte(mix, 0.85)

	return _make_wav(data, true)


func _gen_bgm_chiptune() -> AudioStreamWAV:
	# 16-bit FM-style chiptune rush: rapid arpeggios, bright and energetic
	var bpm := 165.0
	var beat := 60.0 / bpm
	var bars := 8
	var bar_len := beat * 4
	var total_dur := bar_len * bars
	var samples := int(total_dur * MIX_RATE)
	var data := PackedByteArray()
	data.resize(samples)

	# Bright major/power chord progression (E-B-C#m-A)
	var chords: Array = [
		[329.6, 415.3, 493.9],  # E4-G#4-B4
		[246.9, 311.1, 370.0],  # B3-D#4-F#4
		[277.2, 329.6, 415.3],  # C#4-E4-G#4
		[220.0, 277.2, 329.6],  # A3-C#4-E4
	]
	var bass_notes: Array = [82.4, 123.5, 138.6, 110.0]

	# Catchy chiptune melody
	var melody: Array = [659.3, 740.0, 830.6, 659.3, 554.4, 659.3, 740.0, 830.6,
						  987.8, 830.6, 740.0, 659.3, 554.4, 493.9, 554.4, 659.3]

	var ph_b := 0.0
	var ph_l := 0.0
	var ph_arp := 0.0
	var ph_c: Array = [0.0, 0.0, 0.0]

	for i in range(samples):
		var t := float(i) / float(MIX_RATE)
		var bar := int(t / bar_len) % bars
		var ci := (bar / 2) % chords.size()
		var beat_in_bar := fmod(t, beat)
		var beat_num := int(fmod(t, bar_len) / beat)
		var bt := beat_in_bar / beat

		var chord: Array = chords[ci]
		var bf: float = bass_notes[ci]

		# Punchy square bass (eighth notes, tight)
		var eighth_pos := int(fmod(t * (bpm / 60.0) * 2.0, 2.0))
		var eighth_t := fmod(t * (bpm / 60.0) * 2.0, 1.0)
		var bass_freq: float = bf
		if eighth_pos == 1:
			bass_freq = bf * 1.5
		ph_b += bass_freq / MIX_RATE
		var bass_env := maxf(0.0, 1.0 - eighth_t * 3.0) * 0.28
		var bass_s := _square(ph_b) * bass_env

		# Ultra-fast arpeggio (32nd notes cycling through chord tones)
		var arp_speed := 12.0
		var arp_idx := int(fmod(t * arp_speed, 3.0))
		var arp_freq: float = chord[arp_idx] * 2.0
		ph_arp += arp_freq / MIX_RATE
		var arp_t := fmod(t * arp_speed, 1.0)
		var arp_env := maxf(0.0, 1.0 - arp_t * 2.0) * 0.13
		var arp_s := _square(ph_arp) * arp_env

		# Bright pad (triangle, subtle)
		var pad_s := 0.0
		for j in range(3):
			ph_c[j] += chord[j] / MIX_RATE
			pad_s += _triangle(ph_c[j])
		pad_s = pad_s / 3.0 * 0.06

		# Lead melody (square with slight duty cycle feel)
		var mel_beat := t * (bpm / 60.0) * 0.5
		var mel_idx := int(fmod(mel_beat, melody.size()))
		var mel_next := (mel_idx + 1) % melody.size()
		var mel_frac := fmod(mel_beat, 1.0)
		var mel_freq := lerpf(melody[mel_idx], melody[mel_next], smoothstep(0.0, 1.0, mel_frac))
		ph_l += mel_freq / MIX_RATE
		var mel_env := (0.6 + 0.4 * sin(mel_frac * PI)) * 0.20
		var lead_s := _square(ph_l) * mel_env

		# Tight kick (beat 1 & 3)
		var kick := 0.0
		if (beat_num == 0 or beat_num == 2) and bt < 0.06:
			var kt := bt / 0.06
			kick = _square(t * lerpf(200.0, 70.0, kt)) * (1.0 - kt) * 0.22

		# Snappy snare (beat 2 & 4)
		var snare := 0.0
		if (beat_num == 1 or beat_num == 3) and bt < 0.04:
			snare = _noise() * (1.0 - bt / 0.04) * 0.16

		# Hi-hat pattern (eighth notes with accents)
		var hh := 0.0
		var hh_t := fmod(t * (bpm / 60.0) * 2.0, 1.0)
		var hh_accent := 1.0 if int(fmod(t * (bpm / 60.0) * 2.0, 4.0)) == 0 else 0.6
		if hh_t < 0.03:
			hh = _noise() * (1.0 - hh_t / 0.03) * 0.09 * hh_accent

		var mix := bass_s + arp_s + pad_s + lead_s + kick + snare + hh
		data[i] = _to_byte(mix, 0.85)

	return _make_wav(data, true)


func _gen_bgm_latin() -> AudioStreamWAV:
	# Salsa/Latin: syncopated tumbao bass, montuno piano, son clave, congas
	var bpm := 135.0
	var beat := 60.0 / bpm
	var bars := 8
	var bar_len := beat * 4
	var total_dur := bar_len * bars
	var samples := int(total_dur * MIX_RATE)
	var data := PackedByteArray()
	data.resize(samples)

	var chords: Array = [
		[220.0, 261.6, 329.6],  # Am
		[146.8, 174.6, 220.0],  # Dm
		[196.0, 246.9, 293.7],  # G
		[261.6, 329.6, 392.0],  # C
	]
	var bass_notes: Array = [110.0, 73.4, 98.0, 130.8]

	var melody: Array = [440.0, 523.3, 587.3, 523.3, 659.3, 587.3, 523.3, 440.0,
						  349.2, 392.0, 440.0, 523.3, 587.3, 659.3, 587.3, 523.3]

	var ph_b := 0.0
	var ph_l := 0.0
	var ph_c: Array = [0.0, 0.0, 0.0]
	var ph_conga := 0.0

	for i in range(samples):
		var t := float(i) / float(MIX_RATE)
		var bar := int(t / bar_len) % bars
		var ci := (bar / 2) % chords.size()
		var beat_in_bar := fmod(t, beat)
		var _beat_num := int(fmod(t, bar_len) / beat)
		var _bt := beat_in_bar / beat

		var chord: Array = chords[ci]
		var bf: float = bass_notes[ci]

		# Tumbao bass (syncopated)
		var bass_s := 0.0
		var eighth_idx := int(fmod(t * (bpm / 60.0) * 2.0, 8.0))
		var eighth_t := fmod(t * (bpm / 60.0) * 2.0, 1.0)
		if eighth_idx == 3 or eighth_idx == 6 or eighth_idx == 0:
			var b_env := maxf(0.0, 1.0 - eighth_t * 1.5) * 0.30
			ph_b += bf / MIX_RATE
			bass_s = (_saw(ph_b) * 0.6 + _square(ph_b) * 0.4) * b_env
		else:
			ph_b += bf / MIX_RATE

		# Montuno piano (syncopated chord stabs)
		var montuno := 0.0
		var sixteenth_idx := int(fmod(t * (bpm / 60.0) * 4.0, 16.0))
		var sixteenth_t := fmod(t * (bpm / 60.0) * 4.0, 1.0)
		if sixteenth_idx == 0 or sixteenth_idx == 3 or sixteenth_idx == 4 or sixteenth_idx == 6 or sixteenth_idx == 10 or sixteenth_idx == 12 or sixteenth_idx == 15:
			var m_env := maxf(0.0, 1.0 - sixteenth_t * 3.0) * 0.12
			for j in range(3):
				ph_c[j] += chord[j] * 4.0 / MIX_RATE
				montuno += _triangle(ph_c[j])
			montuno = montuno / 3.0 * m_env
		else:
			for j in range(3):
				ph_c[j] += chord[j] * 4.0 / MIX_RATE

		# Son clave
		var clave := 0.0
		if (sixteenth_idx == 0 or sixteenth_idx == 3 or sixteenth_idx == 6 or sixteenth_idx == 8 or sixteenth_idx == 12) and sixteenth_t < 0.04:
			clave = (1.0 - sixteenth_t / 0.04) * 0.14

		# Congas
		var conga := 0.0
		if (sixteenth_idx == 2 or sixteenth_idx == 5 or sixteenth_idx == 8 or sixteenth_idx == 11 or sixteenth_idx == 14) and sixteenth_t < 0.06:
			var c_env := (1.0 - sixteenth_t / 0.06)
			ph_conga += lerpf(300.0, 150.0, sixteenth_t / 0.06) / MIX_RATE
			conga = _triangle(ph_conga) * c_env * 0.10

		# Shaker
		var shaker := 0.0
		if sixteenth_t < 0.05:
			shaker = _noise() * (1.0 - sixteenth_t / 0.05) * 0.06

		# Brass-like melody
		var mel_beat := t * (bpm / 60.0)
		var mel_idx := int(fmod(mel_beat, melody.size()))
		var mel_frac := fmod(mel_beat, 1.0)
		var mel_freq: float = melody[mel_idx]
		ph_l += mel_freq / MIX_RATE
		var mel_env := sin(mel_frac * PI) * 0.16
		var lead_s := (_square(ph_l) * 0.5 + _saw(ph_l) * 0.5) * mel_env

		var mix := bass_s + montuno + _square(t * 2500.0) * clave + conga + _noise() * shaker + lead_s
		data[i] = _to_byte(mix, 0.85)

	return _make_wav(data, true)


func _gen_bgm_chinese() -> AudioStreamWAV:
	# Chinese warrior: 3+3+2 compound rhythm, staccato triangle melody, descending arpeggios, gong
	var bpm := 120.0
	var beat := 60.0 / bpm
	# 3+3+2 = 8 eighth notes per bar
	var bar_eighth := 8
	var eighth_dur := beat * 0.5
	var bar_len := eighth_dur * bar_eighth
	var bars := 12
	var total_dur := bar_len * bars
	var samples := int(total_dur * MIX_RATE)
	var data := PackedByteArray()
	data.resize(samples)

	# Pentatonic notes: C D E G A (gong shang jue zhi yu)
	var penta: Array = [261.6, 293.7, 329.6, 392.0, 440.0]
	# Descending melody pattern (high to low, heroic, with repeats)
	var melody: Array = [880.0, 784.0, 659.3, 523.3, 440.0, 523.3, 659.3, 392.0,
						  784.0, 659.3, 523.3, 440.0, 392.0, 523.3, 440.0, 392.0]
	# Bass follows chord root
	var bass_pattern: Array = [130.8, 130.8, 146.8, 146.8, 110.0, 110.0, 98.0, 98.0,
							   130.8, 130.8, 110.0, 110.0]

	var ph_l := 0.0
	var ph_b := 0.0
	var ph_arp := 0.0
	var ph_gong := 0.0

	for i in range(samples):
		var t := float(i) / float(MIX_RATE)
		var bar := int(t / bar_len) % bars
		var pos_in_bar := fmod(t, bar_len)
		var eighth_idx := int(pos_in_bar / eighth_dur)
		var eighth_frac := fmod(pos_in_bar, eighth_dur) / eighth_dur

		# 3+3+2 accent pattern: strong on 0, 3, 6
		var is_accent := (eighth_idx == 0 or eighth_idx == 3 or eighth_idx == 6)

		var bf: float = bass_pattern[bar % bass_pattern.size()]

		# === War drum (triangle wave, freq sweep down, only on accents) ===
		var drum := 0.0
		if is_accent and eighth_frac < 0.3:
			var df := eighth_frac / 0.3
			ph_b += lerpf(bf * 1.5, bf * 0.5, df) / MIX_RATE
			drum = _triangle(ph_b) * (1.0 - df) * 0.32
		else:
			ph_b += bf * 0.5 / MIX_RATE

		# === Staccato melody (triangle wave, short notes with gaps) ===
		var mel_step := t * (bpm / 60.0) * 0.5
		var mel_idx := int(fmod(mel_step, melody.size()))
		var mel_frac := fmod(mel_step, 1.0)
		var mel_freq: float = melody[mel_idx]
		ph_l += mel_freq / MIX_RATE
		# Sharp staccato: note only sounds for first 40% of duration, then silence
		var mel_env := 0.0
		if mel_frac < 0.4:
			mel_env = maxf(0.0, 1.0 - mel_frac / 0.4) * 0.24
		var lead_s := _triangle(ph_l) * mel_env

		# === Descending pentatonic arpeggio (high to low, on accents) ===
		var arp_s := 0.0
		if is_accent:
			# Cycle through penta notes descending: A G E D C
			var arp_idx := (4 - eighth_idx / 3) % 5
			var arp_freq: float = penta[arp_idx] * 4.0
			ph_arp += arp_freq / MIX_RATE
			var arp_env := maxf(0.0, 1.0 - eighth_frac * 5.0) * 0.12
			arp_s = _triangle(ph_arp) * arp_env
		else:
			ph_arp += penta[0] * 4.0 / MIX_RATE

		# === Gong (noise burst + freq sweep, every 2 bars on beat 1) ===
		var gong := 0.0
		if bar % 2 == 0 and eighth_idx == 0 and eighth_frac < 0.5:
			var gf := eighth_frac / 0.5
			ph_gong += lerpf(60.0, 20.0, gf) / MIX_RATE
			var gong_body := _triangle(ph_gong) * 0.15 * (1.0 - gf * 0.7)
			var gong_noise := _noise() * 0.10 * maxf(0.0, 1.0 - gf * 3.0)
			gong = gong_body + gong_noise
		else:
			ph_gong += 20.0 / MIX_RATE

		# === Light woodblock on non-accent eighths ===
		var click := 0.0
		if not is_accent and eighth_frac < 0.02:
			click = _square(t * 4000.0) * (1.0 - eighth_frac / 0.02) * 0.06

		var mix := drum + lead_s + arp_s + gong + click
		data[i] = _to_byte(mix, 0.85)

	return _make_wav(data, true)


func _gen_bgm_indian() -> AudioStreamWAV:
	# Bollywood Keherwa Taal (8 beats: Dha Ge Na Ti | Na Ka Dhi Na)
	# The #1 most popular rhythm in Indian film music + Dhol-style drums
	var bpm := 145.0
	var beat := 60.0 / bpm
	var bar_len := beat * 8  # 8 beats per Keherwa cycle
	var bars := 8
	var total_dur := bar_len * bars
	var samples := int(total_dur * MIX_RATE)
	var data := PackedByteArray()
	data.resize(samples)

	# Raag Kafi scale (Bollywood favorite, Dorian-like: Sa Re Ga(k) Ma Pa Dha Ni(k))
	var sa := 293.7    # D4
	var re := 329.6    # E4
	var ga_k := 349.2  # F4 (komal Ga)
	var ma := 392.0    # G4
	var pa := 440.0    # A4
	var dha := 493.9   # B4
	var ni_k := 523.3  # C5 (komal Ni)

	# Catchy Bollywood melody (singable, danceable)
	var melody: Array = [sa * 2, pa, ma, pa, sa * 2, ni_k, dha, pa,
						  ma, pa, dha, sa * 2, ni_k, dha, pa, ma,
						  ga_k, ma, pa, ma, ga_k, re, sa, re,
						  ma, ga_k, re, sa, pa * 0.5, sa, re, ma]

	var ph_l := 0.0
	var ph_drone1 := 0.0
	var ph_drone2 := 0.0
	var ph_dhol_lo := 0.0
	var ph_dhol_hi := 0.0
	var ph_bass := 0.0

	for i in range(samples):
		var t := float(i) / float(MIX_RATE)
		var pos_in_bar := fmod(t, bar_len)
		var beat_idx := int(pos_in_bar / beat)
		var beat_frac := fmod(pos_in_bar, beat) / beat

		# Keherwa pattern: Dha Ge Na Ti | Na Ka Dhi Na
		# Beat:             0   1  2  3    4  5   6   7
		# Bhari(strong):    X         X              X
		# Khali(light):                    X

		# === Tanpura drone (warm bed, always present) ===
		ph_drone1 += (sa * 0.5) / MIX_RATE
		ph_drone2 += (pa * 0.5) / MIX_RATE
		var shim := 1.0 + 0.005 * sin(t * 4.5)
		var drone := _triangle(ph_drone1 * shim) * 0.07
		drone += _triangle(ph_drone2 * shim * 1.003) * 0.05
		drone += _triangle(ph_drone1 * 2.0 * shim) * 0.02

		# === Dhol / Tabla Keherwa pattern ===
		var perc := 0.0

		# "Dha" (beat 0) - deep bass boom + open resonance (Sam, strongest)
		if beat_idx == 0 and beat_frac < 0.18:
			var tf := beat_frac / 0.18
			ph_dhol_lo += lerpf(180.0, 55.0, tf) / MIX_RATE
			perc = _triangle(ph_dhol_lo) * (1.0 - tf * 0.5) * 0.30
		# "Ge" (beat 1) - light finger tap
		elif beat_idx == 1 and beat_frac < 0.03:
			perc = _square(t * 2800.0) * (1.0 - beat_frac / 0.03) * 0.06
		# "Na" (beat 2) - sharp rim hit
		elif beat_idx == 2 and beat_frac < 0.04:
			var tf := beat_frac / 0.04
			ph_dhol_hi += lerpf(1800.0, 1200.0, tf) / MIX_RATE
			perc = _saw(ph_dhol_hi) * (1.0 - tf) * 0.12
		# "Ti" (beat 3) - crisp high tap
		elif beat_idx == 3 and beat_frac < 0.035:
			perc = _square(t * 3200.0) * (1.0 - beat_frac / 0.035) * 0.08
		# "Na" (beat 4, Khali) - softer rim hit
		elif beat_idx == 4 and beat_frac < 0.04:
			var tf := beat_frac / 0.04
			ph_dhol_hi += lerpf(1600.0, 1000.0, tf) / MIX_RATE
			perc = _saw(ph_dhol_hi) * (1.0 - tf) * 0.08
		# "Ka" (beat 5) - ghost note
		elif beat_idx == 5 and beat_frac < 0.025:
			perc = _noise() * (1.0 - beat_frac / 0.025) * 0.05
		# "Dhi" (beat 6) - bass + ring (second strong beat)
		elif beat_idx == 6 and beat_frac < 0.14:
			var tf := beat_frac / 0.14
			ph_dhol_lo += lerpf(160.0, 50.0, tf) / MIX_RATE
			perc = _triangle(ph_dhol_lo) * (1.0 - tf * 0.6) * 0.22
			perc += _square(t * 1500.0) * maxf(0.0, 1.0 - tf * 4.0) * 0.05
		# "Na" (beat 7) - closing tap
		elif beat_idx == 7 and beat_frac < 0.04:
			var tf := beat_frac / 0.04
			ph_dhol_hi += lerpf(2000.0, 1400.0, tf) / MIX_RATE
			perc = _saw(ph_dhol_hi) * (1.0 - tf) * 0.10
		else:
			ph_dhol_lo += 50.0 / MIX_RATE
			ph_dhol_hi += 1000.0 / MIX_RATE

		# === Bass line (follows root, plays on Dha and Dhi beats) ===
		var bass_s := 0.0
		if (beat_idx == 0 or beat_idx == 6) and beat_frac < 0.25:
			ph_bass += (sa * 0.25) / MIX_RATE
			bass_s = _square(ph_bass) * maxf(0.0, 1.0 - beat_frac / 0.25) * 0.18
		else:
			ph_bass += (sa * 0.125) / MIX_RATE

		# === Bollywood melody with meend (slides) and ornaments ===
		var mel_step := t * (bpm / 60.0) * 0.4
		var mel_idx := int(fmod(mel_step, melody.size()))
		var mel_next := (mel_idx + 1) % melody.size()
		var mel_frac := fmod(mel_step, 1.0)
		# Meend: smooth slide in first half, settle in second half
		var slide := smoothstep(0.0, 0.4, mel_frac)
		var mel_freq := lerpf(melody[mel_idx], melody[mel_next], slide)
		# Light vibrato (andolan) in sustain portion
		var andolan := sin(t * 6.0) * mel_freq * 0.015 * smoothstep(0.3, 0.7, mel_frac)
		ph_l += (mel_freq + andolan) / MIX_RATE
		# Note envelope: attack then gradual fade
		var mel_env := 0.0
		if mel_frac < 0.1:
			mel_env = mel_frac / 0.1 * 0.22
		else:
			mel_env = 0.22 * maxf(0.0, 1.0 - (mel_frac - 0.1) * 0.6)
		# Sitar-like timbre: saw dominant + harmonic overtones
		var lead_s := (_saw(ph_l) * 0.50 + _triangle(ph_l * 2.0) * 0.30 + _saw(ph_l * 3.0) * 0.20) * mel_env

		# === Ghungroo shimmer (ankle bells, constant light jingle) ===
		var ghungroo := 0.0
		var eighth_t := fmod(t * (bpm / 60.0) * 2.0, 1.0)
		if eighth_t < 0.015:
			ghungroo = _noise() * (1.0 - eighth_t / 0.015) * 0.04

		var mix := drone + perc + bass_s + lead_s + ghungroo
		data[i] = _to_byte(mix, 0.85)

	return _make_wav(data, true)


func _gen_bgm_princess() -> AudioStreamWAV:
	var bpm := 76.0
	var beat := 60.0 / bpm
	var bars := 8
	var bar_len := beat * 4
	var total_dur := bar_len * bars
	var samples := int(total_dur * MIX_RATE)
	var data := PackedByteArray()
	data.resize(samples)

	# G - Em - C - D (warm, bright wedding waltz feel)
	var chords: Array = [
		[196.0, 246.9, 293.7],  # G3-B3-D4
		[164.8, 196.0, 246.9],  # E3-G3-B3
		[130.8, 164.8, 196.0],  # C3-E3-G3
		[146.8, 185.0, 220.0],  # D3-F#3-A3
	]

	# Arpeggio pattern per chord (ascending then descending, piano-like)
	var arp_patterns: Array = [
		[196.0, 246.9, 293.7, 392.0, 493.9, 587.3, 493.9, 392.0],
		[164.8, 196.0, 246.9, 329.6, 392.0, 493.9, 392.0, 329.6],
		[130.8, 164.8, 196.0, 261.6, 329.6, 392.0, 329.6, 261.6],
		[146.8, 185.0, 220.0, 293.7, 370.0, 440.0, 370.0, 293.7],
	]

	# Singing melody (high register, legato)
	var melody: Array = [
		587.3, 587.3, 493.9, 587.3, 784.0, 698.5, 587.3, 493.9,
		523.3, 493.9, 440.0, 493.9, 587.3, 523.3, 493.9, 440.0,
	]

	var bell_times: Array = [0.0, 1.5, 3.0]

	var ph_arp := 0.0
	var ph_mel := 0.0
	var ph_bell := 0.0

	for i in range(samples):
		var t := float(i) / float(MIX_RATE)
		var bar := int(t / bar_len) % bars
		var ci := (bar / 2) % chords.size()
		var beat_in_bar := fmod(t, beat)
		var beat_num := int(fmod(t, bar_len) / beat)
		var bt := beat_in_bar / beat
		var pos_in_bar := fmod(t, bar_len)

		var arp: Array = arp_patterns[ci]

		# Piano-like arpeggio (triangle with fast attack/decay)
		var arp_speed := bpm / 60.0 * 2.0
		var arp_step := fmod(t * arp_speed, float(arp.size()))
		var arp_idx := int(arp_step) % arp.size()
		var arp_frac := fmod(arp_step, 1.0)
		var arp_freq: float = arp[arp_idx]
		ph_arp += arp_freq / MIX_RATE

		var arp_env := 0.0
		if arp_frac < 0.05:
			arp_env = arp_frac / 0.05
		elif arp_frac < 0.3:
			arp_env = 1.0
		else:
			arp_env = maxf(0.0, 1.0 - (arp_frac - 0.3) / 0.7)
		arp_env *= 0.16
		var arp_s := (_triangle(ph_arp) * 0.7 + sin(ph_arp * TAU) * 0.3) * arp_env

		# Singing melody (sine + triangle, legato with vibrato)
		var mel_beat := t * (bpm / 60.0) * 0.5
		var mel_idx := int(fmod(mel_beat, melody.size()))
		var mel_frac := fmod(mel_beat, 1.0)
		var mel_freq: float = melody[mel_idx]
		var vibrato := sin(t * 5.5) * 3.0
		ph_mel += (mel_freq + vibrato) / MIX_RATE

		var mel_env := 0.0
		if mel_frac < 0.06:
			mel_env = mel_frac / 0.06
		elif mel_frac < 0.7:
			mel_env = 1.0
		else:
			mel_env = maxf(0.0, 1.0 - (mel_frac - 0.7) / 0.3)
		mel_env *= 0.14

		var phrase_bar := bar % 4
		if phrase_bar >= 2:
			mel_env *= 0.7
		var lead_s := (sin(ph_mel * TAU) * 0.6 + _triangle(ph_mel) * 0.4) * mel_env

		# Church bell chimes (high sine with exponential decay)
		var bell := 0.0
		for bb in bell_times:
			var bell_t: float = pos_in_bar - bb * beat
			if bell_t >= 0.0 and bell_t < 0.4:
				var freq := 1568.0 + float(int(bb) % 3) * 220.0
				ph_bell += freq / MIX_RATE
				var env := exp(-bell_t * 8.0) * 0.06
				bell += sin(ph_bell * TAU) * env

		# Gentle waltz pulse (soft noise breath on beat 1)
		var breath := 0.0
		if beat_num == 0 and bt < 0.04:
			breath = _noise() * (1.0 - bt / 0.04) * 0.02

		var mix := arp_s + lead_s + bell + breath
		data[i] = _to_byte(clampf(mix, -1.0, 1.0), 0.85)

	return _make_wav(data, true)
