extends Node2D
class_name Level

const T := 64
const GAP := 18.0
const MOBS := {"c": "crab", "e": "eel", "v": "viperfish", "s": "snake", "u": "urchin", "h": "seahorse", "t": "starfish", "f": "fish"}
const BOSSES := {
	"fisherman": preload("res://scripts/boss_fisherman.gd"),
	"squid": preload("res://scripts/boss_squid.gd"),
	"kraken": preload("res://scripts/boss_kraken.gd"),
}
const UPGRADE_INFO := {
	"pois": ["Poison Skin", "your hits poison enemies", 0],
	"box": ["Quick Tentacles", "attacks twice as fast", 1],
	"camo": ["Camouflage", "stand still and enemies lose you", 2],
	"ink": ["Ink Dash", "dashing leaves a stunning ink trail", 3],
	"hear": ["Hearing", "", 4],
}

@export var level_id := 1

var data: Dictionary
var rows: Array
var W := 0
var H := 0
var player: CharacterBody2D
var cam: Camera2D
var hud: HUD
var boss: Boss
var arena_rect := Rect2()
var _gates: Array[StaticBody2D] = []
var _portal: Area2D
var _checkpoints: Array = []
var _closer: Closer
var _fight := false
var _dying := false
var _exiting := false
var _shake := 0.0
var _last_pos := Vector2.ZERO
var _door_msg_cd := 0.0
var _ups_i := 0

class WorldDraw extends Node2D:
	var rows: Array
	var tex: Texture2D
	var top: Color
	var bot: Color
	var W := 0
	var H := 0

	func _solid(c: int, r: int) -> bool:
		if c < 0 or r < 0 or r >= rows.size() or c >= rows[0].length():
			return true
		return rows[r][c] == "#"

	func _draw() -> void:
		var wp := float(W * T)
		var hp := float(H * T)
		draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(wp, 0), Vector2(wp, hp), Vector2(0, hp)]), PackedColorArray([top, top, bot, bot]))
		for r in H:
			for c in W:
				var ch: String = rows[r][c]
				var p := Vector2(c * T, r * T)
				var src := Rect2(((c * 7 + r * 13) % 3) * 64, 0, 64, 64)
				if ch == "#":
					draw_texture_rect_region(tex, Rect2(p, Vector2(T, T)), src)
					var e := Color(1, 1, 1, 0.16)
					if not _solid(c, r - 1): draw_line(p + Vector2(0, 1.5), p + Vector2(T, 1.5), e, 3.0)
					if not _solid(c, r + 1): draw_line(p + Vector2(0, T - 1.5), p + Vector2(T, T - 1.5), Color(0, 0, 0, 0.35), 3.0)
					if not _solid(c - 1, r): draw_line(p + Vector2(1.5, 0), p + Vector2(1.5, T), e, 3.0)
					if not _solid(c + 1, r): draw_line(p + Vector2(T - 1.5, 0), p + Vector2(T - 1.5, T), e, 3.0)
				elif ch == "g":
					var h := (T - GAP) * 0.5
					draw_texture_rect_region(tex, Rect2(p, Vector2(T, h)), Rect2(src.position, Vector2(64, h)))
					draw_texture_rect_region(tex, Rect2(p + Vector2(0, T - h), Vector2(T, h)), Rect2(src.position + Vector2(0, 64 - h), Vector2(64, h)))
					draw_rect(Rect2(p + Vector2(0, h), Vector2(T, GAP)), Color(0.5, 1, 1, 0.12))
					draw_line(p + Vector2(0, h), p + Vector2(T, h), Color(0.6, 1, 1, 0.5), 2.0)
					draw_line(p + Vector2(0, T - h), p + Vector2(T, T - h), Color(0.6, 1, 1, 0.5), 2.0)
				elif ch == "G":
					var w := (T - GAP) * 0.5
					draw_texture_rect_region(tex, Rect2(p, Vector2(w, T)), Rect2(src.position, Vector2(w, 64)))
					draw_texture_rect_region(tex, Rect2(p + Vector2(T - w, 0), Vector2(w, T)), Rect2(src.position + Vector2(64 - w, 0), Vector2(w, 64)))
					draw_rect(Rect2(p + Vector2(w, 0), Vector2(GAP, T)), Color(0.5, 1, 1, 0.12))
					draw_line(p + Vector2(w, 0), p + Vector2(w, T), Color(0.6, 1, 1, 0.5), 2.0)
					draw_line(p + Vector2(T - w, 0), p + Vector2(T - w, T), Color(0.6, 1, 1, 0.5), 2.0)

class Closer extends Node2D:
	var rect := Rect2()
	var inset := 0.0
	var bodies: Array[StaticBody2D] = []

	func rects() -> Array:
		var m := 400.0
		return [
			Rect2(rect.position + Vector2(-m, -m), Vector2(rect.size.x + 2 * m, m + inset)),
			Rect2(rect.position + Vector2(-m, rect.size.y - inset), Vector2(rect.size.x + 2 * m, m + inset)),
			Rect2(rect.position + Vector2(-m, -m), Vector2(m + inset, rect.size.y + 2 * m)),
			Rect2(rect.position + Vector2(rect.size.x - inset, -m), Vector2(m + inset, rect.size.y + 2 * m)),
		]

	func apply(v: float) -> void:
		inset = v
		var rs := rects()
		for i in 4:
			bodies[i].position = rs[i].position + rs[i].size * 0.5
			(bodies[i].get_child(0) as CollisionShape2D).shape.size = rs[i].size
		queue_redraw()

	func _draw() -> void:
		var rs := rects()
		for r in rs:
			draw_rect(r, Color(0.08, 0.05, 0.12, 1.0))
		for i in 4:
			var r: Rect2 = rs[i]
			var edge := Color(0.9, 0.2, 0.3, 0.8)
			match i:
				0: draw_line(Vector2(r.position.x, r.end.y), r.end, edge, 4.0)
				1: draw_line(r.position, Vector2(r.end.x, r.position.y), edge, 4.0)
				2: draw_line(Vector2(r.end.x, r.position.y), r.end, edge, 4.0)
				3: draw_line(r.position, Vector2(r.position.x, r.end.y), edge, 4.0)

func _ready() -> void:
	data = LevelData.DATA[level_id]
	rows = data["map"]
	H = rows.size()
	W = rows[0].length()
	_build_world()
	_spawn_player()
	_scan()
	_setup_camera()
	hud = HUD.new()
	hud.level = self
	add_child(hud)
	var pa := Node.new()
	pa.set_script(load("res://scripts/player_audio.gd"))
	add_child(pa)
	pa.bind(player)
	audio.listener = player
	audio.play_music(data["music"])
	hud.popup("Level %d  -  %s" % [level_id, data["name"]], 3.2)
	if level_id == 1:
		get_tree().create_timer(3.4).timeout.connect(func(): hud.popup("WASD swim  |  C dash  |  LMB light  RMB heavy  |  Z shrink  X block", 6.0))
	var tints := {1: Color.WHITE, 2: Color(0.86, 0.9, 1.0), 3: Color(0.72, 0.78, 0.95)}
	var cm := CanvasModulate.new()
	cm.color = tints[level_id]
	add_child(cm)

func _cell(c: int, r: int) -> Vector2:
	return Vector2((c + 0.5) * T, (r + 0.5) * T)

func _ch(c: int, r: int) -> String:
	if c < 0 or r < 0 or r >= H or c >= W:
		return "#"
	return rows[r][c]

func _build_world() -> void:
	var wd := WorldDraw.new()
	wd.rows = rows
	wd.W = W
	wd.H = H
	wd.tex = load(data["tiles"])
	wd.top = data["top"]
	wd.bot = data["bot"]
	wd.z_index = -10
	add_child(wd)
	var body := StaticBody2D.new()
	body.collision_layer = 1024
	body.collision_mask = 0
	add_child(body)
	for r in H:
		var c := 0
		while c < W:
			if _ch(c, r) == "#" and _near_open(c, r):
				var c0 := c
				while c < W and _ch(c, r) == "#" and _near_open(c, r):
					c += 1
				body.add_child(Util.rect(Vector2((c - c0) * T, T), Vector2((c0 + (c - c0) * 0.5) * T, (r + 0.5) * T)))
			else:
				c += 1
	for r in H:
		for c in W:
			var ch := _ch(c, r)
			var p := Vector2(c * T, r * T)
			var h := (T - GAP) * 0.5
			if ch == "g":
				body.add_child(Util.rect(Vector2(T, h), p + Vector2(T * 0.5, h * 0.5)))
				body.add_child(Util.rect(Vector2(T, h), p + Vector2(T * 0.5, T - h * 0.5)))
			elif ch == "G":
				body.add_child(Util.rect(Vector2(h, T), p + Vector2(h * 0.5, T * 0.5)))
				body.add_child(Util.rect(Vector2(h, T), p + Vector2(T - h * 0.5, T * 0.5)))

func _near_open(c: int, r: int) -> bool:
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			if _ch(c + dx, r + dy) != "#":
				return true
	return false

func _find(ch: String) -> Array:
	var out := []
	for r in H:
		for c in W:
			if rows[r][c] == ch:
				out.append(Vector2i(c, r))
	return out

func _spawn_player() -> void:
	var start := _find("P")[0] as Vector2i
	player = load("res://scene/player.tscn").instantiate()
	player.name = "player"
	player.position = game.checkpoint if game.checkpoint != Vector2.INF else _cell(start.x, start.y)
	player.hp = game.hp
	add_child(player)
	_apply_upgrades()
	_last_pos = player.position
	player.tree_exited.connect(_on_player_gone)

func _apply_upgrades() -> void:
	player.posion_skin_unlock = game.upgrades["pois"]
	player.box_unlock = game.upgrades["box"]
	player.camo_unlock = game.upgrades["camo"]
	player.ink_dash_unlock = game.upgrades["ink"]
	global.hearing_unlock = game.upgrades["hear"]

func _on_player_gone() -> void:
	if game.leaving or _dying or _exiting or not is_inside_tree():
		return
	_dying = true
	audio.stop_music(1.5)
	if hud:
		hud.popup("you got swallowed by the deep...", 3.0)
	var burst := CPUParticles2D.new()
	burst.position = _last_pos
	burst.texture = load("res://sprites/gen/bubble.png")
	burst.one_shot = true
	burst.amount = 28
	burst.explosiveness = 1.0
	burst.lifetime = 1.6
	burst.direction = Vector2(0, -1)
	burst.spread = 180.0
	burst.initial_velocity_min = 40.0
	burst.initial_velocity_max = 160.0
	burst.gravity = Vector2(0, -60)
	burst.emitting = true
	add_child(burst)
	get_tree().create_timer(1.5).timeout.connect(func(): game.player_died())

func _scan() -> void:
	var seen := {}
	for cell in _find("D"):
		if seen.has(cell):
			continue
		var grp := []
		var q := [cell]
		seen[cell] = true
		while not q.is_empty():
			var x: Vector2i = q.pop_back()
			grp.append(x)
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var n: Vector2i = x + d
				if _ch(n.x, n.y) == "D" and not seen.has(n):
					seen[n] = true
					q.append(n)
		_make_door(grp)
	for cell in _find("k"):
		_make_key(cell)
	for cell in _find("U"):
		_make_upgrade(cell)
	for cell in _find("C"):
		_make_checkpoint(cell)
	for cell in _find("b"):
		_make_gate(cell)
	for ch in MOBS:
		for cell in _find(ch):
			spawn_mob(MOBS[ch], _cell(cell.x, cell.y))
	_make_exit()
	_make_boss()

func _area(pos: Vector2, shape: CollisionShape2D) -> Area2D:
	var a := Area2D.new()
	a.position = pos
	a.collision_layer = 0
	a.collision_mask = 1
	a.add_child(shape)
	add_child(a)
	return a

func _is_player(b: Node) -> bool:
	return b == player

func spawn_mob(kind: String, pos: Vector2) -> Mob:
	var m := Mob.new().setup(kind, player)
	m.position = pos
	m.died.connect(_on_mob_died)
	add_child(m)
	return m

func _on_mob_died(m: Mob) -> void:
	if m.kind == "urchin" or not m.hostile:
		return
	if randf() < 0.3:
		_make_heal(m.global_position)

func _make_heal(pos: Vector2) -> void:
	var a := _area(pos, Util.circle(22))
	var s := Sprite2D.new()
	s.texture = load("res://sprites/gen/bubble.png")
	s.scale = Vector2.ONE * 2.0
	s.modulate = Color(0.5, 1.0, 0.6)
	a.add_child(s)
	a.body_entered.connect(func(b):
		if _is_player(b):
			player.hp = minf(player.hp + 5.0, game.MAX_HP)
			audio.sfx("pickup", Vector2.INF, -8.0)
			a.queue_free())
	get_tree().create_timer(14.0).timeout.connect(func(): if is_instance_valid(a): a.queue_free())

func _make_door(grp: Array) -> void:
	var id := "d%d_%d" % [grp[0].x, grp[0].y]
	if game.opened.has(id):
		return
	var body := StaticBody2D.new()
	body.collision_layer = 1024
	body.collision_mask = 0
	add_child(body)
	var touch := Area2D.new()
	touch.collision_layer = 0
	touch.collision_mask = 1
	add_child(touch)
	for cell in grp:
		var c := _cell(cell.x, cell.y)
		body.add_child(Util.rect(Vector2(T, T), c))
		touch.add_child(Util.rect(Vector2(T + 60, T + 60), c))
		var s := Sprite2D.new()
		s.texture = load("res://sprites/gen/coral_door.png")
		s.position = c
		body.add_child(s)
	touch.body_entered.connect(func(b):
		if not _is_player(b) or not is_instance_valid(body):
			return
		if game.keys > 0:
			game.keys -= 1
			game.opened.append(id)
			audio.sfx("pickup")
			hud.popup("the coral door crumbles open")
			body.collision_layer = 0
			touch.queue_free()
			var t := create_tween()
			t.tween_property(body, "modulate:a", 0.0, 0.6)
			t.tween_callback(body.queue_free)
		elif _door_msg_cd <= 0.0:
			_door_msg_cd = 2.5
			hud.popup("sealed by coral... find a coral key"))

func _make_key(cell: Vector2i) -> void:
	var id := "k%d_%d" % [cell.x, cell.y]
	if game.taken.has(id):
		return
	var a := _area(_cell(cell.x, cell.y), Util.circle(24))
	var s := AnimatedSprite2D.new()
	s.sprite_frames = Util.frames("res://sprites/gen/coral_key.png", 40, 40, 4, 5.0)
	s.scale = Vector2.ONE * 1.4
	s.play("idle")
	a.add_child(s)
	a.body_entered.connect(func(b):
		if _is_player(b):
			game.keys += 1
			game.taken.append(id)
			audio.sfx("pickup")
			hud.popup("coral key! (%d)" % game.keys)
			a.queue_free())

func _make_upgrade(cell: Vector2i) -> void:
	var id := "u%d_%d" % [cell.x, cell.y]
	var ups: Array = data["ups"]
	var type: String = ups[_ups_i % ups.size()]
	_ups_i += 1
	if game.taken.has(id):
		return
	var info: Array = UPGRADE_INFO[type]
	var a := _area(_cell(cell.x, cell.y), Util.circle(28))
	var s := Sprite2D.new()
	s.texture = load("res://sprites/gen/upgrade_orbs.png")
	s.hframes = 5
	s.frame = info[2]
	s.scale = Vector2.ONE * 1.3
	a.add_child(s)
	var tw := a.create_tween().set_loops()
	tw.tween_property(s, "position:y", -6.0, 0.9).set_trans(Tween.TRANS_SINE)
	tw.tween_property(s, "position:y", 6.0, 0.9).set_trans(Tween.TRANS_SINE)
	a.body_entered.connect(func(b):
		if _is_player(b):
			game.upgrades[type] = true
			game.taken.append(id)
			_apply_upgrades()
			audio.sfx("pickup", Vector2.INF, 2.0)
			hud.popup("%s - %s" % [info[0], info[1]], 4.0)
			a.queue_free())

func _make_checkpoint(cell: Vector2i) -> void:
	var pos := _cell(cell.x, cell.y)
	var a := _area(pos, Util.circle(40))
	var s := Sprite2D.new()
	s.texture = load("res://sprites/gen/checkpoint.png")
	s.hframes = 2
	s.frame = 1 if game.checkpoint == pos else 0
	a.add_child(s)
	_checkpoints.append([pos, s])
	a.body_entered.connect(func(b):
		if _is_player(b) and game.checkpoint != pos:
			game.checkpoint = pos
			game.hp = game.MAX_HP
			player.hp = game.MAX_HP
			for cp in _checkpoints:
				cp[1].frame = 1 if cp[0] == pos else 0
			audio.sfx("pickup", Vector2.INF, -4.0)
			hud.popup("checkpoint - healed"))

func _make_gate(cell: Vector2i) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 1024
	body.collision_mask = 0
	body.position = _cell(cell.x, cell.y)
	var cs := Util.rect(Vector2(T, T))
	cs.disabled = true
	body.add_child(cs)
	var s := Sprite2D.new()
	s.texture = load("res://sprites/gen/coral_door.png")
	s.modulate = Color(0.8, 0.4, 0.9)
	body.add_child(s)
	body.visible = false
	add_child(body)
	_gates.append(body)

func _make_exit() -> void:
	var cells := _find("E")
	if cells.is_empty():
		return
	var cell: Vector2i = cells[0]
	_portal = _area(_cell(cell.x, cell.y), Util.circle(34))
	var s := AnimatedSprite2D.new()
	s.sprite_frames = Util.frames("res://sprites/gen/portal.png", 64, 64, 4, 8.0)
	s.scale = Vector2.ONE * 1.6
	s.play("idle")
	_portal.add_child(s)
	_portal.body_entered.connect(func(b):
		if _is_player(b) and _portal.visible and not _exiting:
			_exiting = true
			game.hp = player.hp
			audio.sfx("pickup", Vector2.INF, 3.0)
			game.next_level())
	_portal.visible = false
	_portal.monitoring = false

func _open_exit() -> void:
	if _portal:
		_portal.visible = true
		_portal.set_deferred("monitoring", true)

func _make_boss() -> void:
	var bc := _find("B")
	if bc.is_empty():
		_open_exit()
		return
	var seen := {bc[0]: true}
	var q := [bc[0]]
	var mn := Vector2i(999, 999)
	var mx := Vector2i(-1, -1)
	while not q.is_empty():
		var x: Vector2i = q.pop_back()
		mn = Vector2i(mini(mn.x, x.x), mini(mn.y, x.y))
		mx = Vector2i(maxi(mx.x, x.x), maxi(mx.y, x.y))
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = x + d
			if not seen.has(n) and not ["#", "b", "D", "g", "G"].has(_ch(n.x, n.y)):
				seen[n] = true
				q.append(n)
	arena_rect = Rect2(Vector2(mn) * T, Vector2(mx - mn + Vector2i.ONE) * T)
	if game.boss_dead:
		_open_exit()
		return
	boss = BOSSES[data["boss"]].new()
	boss.position = _cell(bc[0].x, bc[0].y)
	boss.target = player
	boss.level = self
	boss.died.connect(_on_boss_died)
	boss.phase_changed.connect(_on_phase)
	add_child(boss)
	var trig := Area2D.new()
	trig.collision_layer = 0
	trig.collision_mask = 1
	for cell in _find("x"):
		var cs := Util.rect(Vector2(T, T), _cell(cell.x, cell.y))
		trig.add_child(cs)
	add_child(trig)
	trig.body_entered.connect(func(b):
		if _is_player(b) and not _fight:
			_start_fight())

func _start_fight() -> void:
	_fight = true
	for g in _gates:
		g.visible = true
		(g.get_child(0) as CollisionShape2D).set_deferred("disabled", false)
	audio.play_music(data["boss_music"][0], 0.8)
	boss.activate()
	hud.show_boss(boss)
	hud.popup(boss.boss_name, 2.5)
	shake(8.0, 0.5)

func _on_phase(p: int) -> void:
	if p == 2 and data["boss_music"].size() > 1:
		audio.play_music(data["boss_music"][1], 0.4)
	hud.popup("the Kraken is enraged! the water is closing in...", 3.5)

func _on_boss_died() -> void:
	game.boss_dead = true
	for g in _gates:
		g.visible = false
		(g.get_child(0) as CollisionShape2D).set_deferred("disabled", true)
	if is_instance_valid(player):
		player.hp = minf(player.hp + 20.0, game.MAX_HP)
	hud.popup("%s defeated!" % boss.boss_name, 3.5)
	audio.play_music(data["music"], 2.5)
	get_tree().create_timer(1.6).timeout.connect(func():
		hud.hide_boss()
		_open_exit()
		if _closer:
			create_tween().tween_method(_closer.apply, _closer.inset, 0.0, 1.0)
		hud.popup("a whirlpool opens - swim in", 4.0))

func shrink_arena(step: int) -> void:
	if _closer == null:
		_closer = Closer.new()
		_closer.rect = arena_rect
		_closer.z_index = 5
		for i in 4:
			var b := StaticBody2D.new()
			b.collision_layer = 1024
			b.collision_mask = 0
			b.add_child(Util.rect(Vector2(10, 10)))
			_closer.bodies.append(b)
			_closer.add_child(b)
		add_child(_closer)
		_closer.apply(0.0)
	shake(6.0, 1.0)
	create_tween().tween_method(_closer.apply, _closer.inset, 36.0 * step, 1.4)

func _setup_camera() -> void:
	cam = Camera2D.new()
	cam.zoom = Vector2(1.2, 1.2)
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = W * T
	cam.limit_bottom = H * T
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 7.0
	cam.position = player.position
	add_child(cam)
	cam.make_current()
	var bubbles := CPUParticles2D.new()
	bubbles.texture = load("res://sprites/gen/bubble.png")
	bubbles.amount = 26
	bubbles.lifetime = 7.0
	bubbles.preprocess = 7.0
	bubbles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	bubbles.emission_rect_extents = Vector2(700, 10)
	bubbles.position = Vector2(0, 380)
	bubbles.direction = Vector2(0, -1)
	bubbles.spread = 14.0
	bubbles.gravity = Vector2.ZERO
	bubbles.initial_velocity_min = 30.0
	bubbles.initial_velocity_max = 60.0
	bubbles.scale_amount_min = 0.5
	bubbles.scale_amount_max = 1.3
	bubbles.modulate = Color(1, 1, 1, 0.55)
	cam.add_child(bubbles)

func shake(amount: float, secs: float) -> void:
	_shake = maxf(_shake, amount)
	create_tween().tween_property(self, "_shake", 0.0, secs)

func _process(delta: float) -> void:
	_door_msg_cd -= delta
	if is_instance_valid(player):
		_last_pos = player.global_position
		cam.global_position = _last_pos
		game.hp = player.hp
	cam.offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * _shake
