extends Node

const MUSIC := {
	"title": "res://music/Title Screen.mp3",
	"l1": "res://music/level1_peace.ogg",
	"l1_boss": "res://music/level1_boss.ogg",
	"l2": "res://music/level2_peace.ogg",
	"l2_boss": "res://music/level2_boss.ogg",
	"l3": "res://music/level3_peace.ogg",
	"l3_boss1": "res://music/level3_boss_phase1.ogg",
	"l3_boss2": "res://music/level3_boss_phase2.ogg",
}
const SFX := {
	"run": ["01_player/run", -10.0], "dash": ["01_player/dash", -4.0],
	"light": ["01_player/attack_light", -4.0], "heavy": ["01_player/attack_heavy", -2.0],
	"pickup": ["01_player/collect_upgrade", -2.0],
	"fish_school": ["02_peaceful_move/fish_school", -8.0], "sea_urchin": ["02_peaceful_move/sea_urchin", -8.0],
	"seahorse": ["02_peaceful_move/seahorse", -8.0], "starfish": ["02_peaceful_move/starfish", -8.0],
	"electric_eel": ["03_hostile_move/electric_eel", -6.0], "sea_snake": ["03_hostile_move/sea_snake", -6.0],
	"viperfish": ["03_hostile_move/viperfish", -6.0],
	"fisherman": ["04_boss_move/fisherman", -2.0], "giant_squid": ["04_boss_move/giant_squid", -2.0],
	"kraken": ["04_boss_move/kraken", -2.0],
	"eel_zap": ["05_enemy_attack/eel_zap", -3.0], "sea_snake_strike": ["05_enemy_attack/sea_snake_strike", -3.0],
	"viperfish_bite": ["05_enemy_attack/viperfish_bite", -3.0],
	"fisherman_hook": ["06_boss_attack/fisherman_hook", 0.0], "giant_squid_slam": ["06_boss_attack/giant_squid_slam", 0.0],
	"kraken_slam": ["06_boss_attack/kraken_slam", 0.0],
}
const MUSIC_DB := -6.0

var listener: Node2D
var _cache := {}
var _pool: Array[AudioStreamPlayer] = []
var _mus: Array[AudioStreamPlayer] = []
var _cur := ""
var _active := 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in 16:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_pool.append(p)
	for i in 2:
		var m := AudioStreamPlayer.new()
		m.volume_db = -80.0
		add_child(m)
		_mus.append(m)

func play_music(key: String, fade := 1.2) -> void:
	if key == _cur or not MUSIC.has(key):
		return
	_cur = key
	var stream = load(MUSIC[key])
	if stream == null:
		return
	if "loop" in stream:
		stream.loop = true
	var old := _mus[_active]
	_active = 1 - _active
	var nw := _mus[_active]
	nw.stream = stream
	nw.volume_db = -60.0
	nw.play()
	var t := create_tween().set_parallel(true)
	t.tween_property(nw, "volume_db", MUSIC_DB, fade)
	t.tween_property(old, "volume_db", -60.0, fade)
	t.chain().tween_callback(old.stop)

func stop_music(fade := 1.0) -> void:
	_cur = ""
	for m in _mus:
		if m.playing:
			var t := create_tween()
			t.tween_property(m, "volume_db", -60.0, fade)
			t.tween_callback(m.stop)

func sfx(name: String, pos := Vector2.INF, extra_db := 0.0) -> void:
	if not SFX.has(name):
		return
	var db: float = SFX[name][1] + extra_db
	if pos != Vector2.INF and is_instance_valid(listener):
		var d := listener.global_position.distance_to(pos)
		if d > 1100.0:
			return
		db -= clampf(d / 55.0, 0.0, 18.0)
	var s := _stream(name)
	if s == null:
		return
	var p: AudioStreamPlayer = null
	for q in _pool:
		if not q.playing:
			p = q
			break
	if p == null:
		p = _pool[0]
	p.stream = s
	p.volume_db = db
	p.pitch_scale = randf_range(0.94, 1.06)
	p.play()

func _stream(name: String) -> AudioStream:
	var takes: Array = _cache.get(name, [])
	if takes.is_empty():
		for v in ["a", "b", "c"]:
			var path := "res://sfx_real/%s_%s.ogg" % [SFX[name][0], v]
			if ResourceLoader.exists(path):
				takes.append(load(path))
		_cache[name] = takes
	if takes.is_empty():
		return null
	return takes[randi() % takes.size()]
