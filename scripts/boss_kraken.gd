extends Boss

var _shrinks := 0
var _next_shrink := 6.0

func _init() -> void:
	boss_name = "The Kraken"
	max_hp = 45.0
	hp = 45.0
	contact_dmg = 4.0

func build() -> void:
	sprite.sprite_frames = Util.frames("res://sprites/gen/kraken.png", 320, 320, 4, 5.0, "idle")
	sprite.scale = Vector2.ONE * 1.0
	sprite.play("idle")
	add_child(Util.circle(112.0))

func _hit_shape() -> CollisionShape2D:
	return Util.circle(124.0)

func _tick(_delta: float) -> void:
	velocity = Vector2(0, (home.y + sin(_t * 1.1) * 14.0 - global_position.y) * 3.0)
	if phase == 1 and hp <= max_hp * 0.5:
		_enter_phase2()
	if phase == 2 and _shrinks < 3 and _t > _next_shrink and level and level.has_method("shrink_arena"):
		_shrinks += 1
		_next_shrink = _t + 12.0
		level.shrink_arena(_shrinks)

func _enter_phase2() -> void:
	phase = 2
	contact_dmg = 5.0
	sprite.sprite_frames = Util.frames("res://sprites/gen/kraken_rage.png", 320, 320, 4, 8.0, "idle")
	sprite.play("idle")
	audio.sfx("kraken")
	if level and level.has_method("shake"):
		level.shake(14.0, 0.9)
	_next_shrink = _t + 1.5
	phase_changed.emit(2)

func _loop() -> void:
	while not dead:
		await wait(1.1 if phase == 2 else 2.0)
		if not alive():
			return
		var r := randi() % (3 if phase == 2 else 2)
		match r:
			0: await _slams()
			1: await _ring()
			2: await _summon()

func _slams() -> void:
	audio.sfx("kraken", global_position)
	var n := 5 if phase == 2 else 3
	for i in n:
		if not alive():
			return
		telegraph(target.global_position, 95.0, 0.9 if phase == 2 else 1.1, 6.0, "kraken_slam")
		await wait(0.35 if phase == 2 else 0.55)
	await wait(0.8)

func _ring() -> void:
	audio.sfx("kraken", global_position)
	var n := 16 if phase == 2 else 12
	for wave in (2 if phase == 2 else 1):
		if not alive():
			return
		for i in n:
			shot(global_position + Vector2(0, 40), Vector2.from_angle(i * TAU / n + wave * TAU / n * 0.5) * (250.0 if phase == 2 else 210.0), 3.0, "res://sprites/gen/ink_shot.png", 11.0, 5.0, 1.2)
		audio.sfx("kraken_slam", global_position, -6.0)
		await wait(0.7)
	await wait(0.5)

func _summon() -> void:
	audio.sfx("kraken", global_position)
	await wait(0.6)
	if not alive() or not level or not level.has_method("spawn_mob"):
		return
	for i in 2:
		level.spawn_mob("eel", global_position + Vector2((i * 2 - 1) * 170.0, 200.0))
	await wait(1.0)
