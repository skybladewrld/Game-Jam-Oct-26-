extends Boss

var _jet := Vector2.ZERO
var _jetting := false

func _init() -> void:
	boss_name = "Giant Squid"
	max_hp = 40.0
	hp = 40.0
	contact_dmg = 2.5

func build() -> void:
	var sf := Util.frames("res://sprites/bosses/squid_idle.png", 320, 320, 6, 5.0, "idle")
	Util.frames("res://sprites/bosses/sqiud_move.png", 320, 320, 11, 11.0, "attack", sf)
	sprite.sprite_frames = sf
	sprite.play("idle")
	add_child(Util.rect(Vector2(180, 230), Vector2(10, 0)))

func _hit_shape() -> CollisionShape2D:
	return Util.rect(Vector2(200, 250), Vector2(10, 0))

func _tick(_delta: float) -> void:
	if _jetting:
		velocity = _jet
		return
	var to := target.global_position - global_position
	velocity = to.normalized() * 55.0 if to.length() > 240.0 else Vector2.ZERO

func _loop() -> void:
	while not dead:
		await wait(1.5 if hp < max_hp * 0.5 else 2.3)
		if not alive():
			return
		match randi() % 3:
			0: await _ink()
			1: await _slam()
			2: await _dash()

func _ink() -> void:
	sprite.play("attack")
	audio.sfx("giant_squid", global_position)
	await wait(0.6)
	if not alive():
		return
	var n := 7 if hp < max_hp * 0.5 else 5
	var base := (target.global_position - global_position).angle()
	for i in n:
		shot(global_position, Vector2.from_angle(base + (i - (n - 1) * 0.5) * 0.24) * 290.0, 3.0)
	audio.sfx("giant_squid_slam", global_position, -8.0)
	await wait(0.5)
	sprite.play("idle")

func _slam() -> void:
	sprite.play("attack")
	audio.sfx("giant_squid", global_position)
	var n := 2 if hp < max_hp * 0.5 else 1
	for i in n:
		telegraph(target.global_position + Vector2(randf_range(-60, 60), randf_range(-60, 60)) * i, 120.0, 1.1, 6.0, "giant_squid_slam")
		await wait(0.45)
		if not alive():
			return
	await wait(0.9)
	sprite.play("idle")

func _dash() -> void:
	sprite.play("attack")
	audio.sfx("giant_squid", global_position)
	sprite.modulate = Color(1.0, 0.7, 0.7)
	await wait(0.7)
	sprite.modulate = Color.WHITE
	if not alive():
		return
	_jet = (target.global_position - global_position).normalized() * 560.0
	_jetting = true
	contact_dmg = 5.0
	audio.sfx("giant_squid_slam", global_position)
	await wait(0.7)
	_jetting = false
	contact_dmg = 2.5
	sprite.play("idle")
