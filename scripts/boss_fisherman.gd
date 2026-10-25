extends Boss

var _hook: Sprite2D
var _hooking := false
var _grace := 0.0
var _snag_t := 0.0

func _init() -> void:
	boss_name = "The Fisherman"
	max_hp = 30.0
	hp = 30.0
	contact_dmg = 2.0

func build() -> void:
	var sf := Util.frames("res://sprites/bosses/fishermen.png", 320, 320, 16, 6.0, "idle")
	Util.frames("res://sprites/bosses/fishinf_attack.png", 320, 320, 8, 8.0, "attack", sf)
	sprite.sprite_frames = sf
	sprite.scale = Vector2.ONE * 0.8
	sprite.play("idle")
	add_child(Util.rect(Vector2(230, 100), Vector2(-8, 40)))
	_hook = Sprite2D.new()
	_hook.texture = load("res://sprites/bosses/hook-removebg-preview.png")
	_hook.scale = Vector2.ONE * 0.14
	_hook.top_level = true
	_hook.visible = false
	add_child(_hook)

func _hit_shape() -> CollisionShape2D:
	return Util.rect(Vector2(250, 120), Vector2(-8, 40))

func _tick(delta: float) -> void:
	_grace -= delta
	var tx := home.x + sin(_t * 0.7) * 150.0
	velocity = Vector2((tx - global_position.x) * 3.0, (home.y + sin(_t * 1.3) * 8.0 - global_position.y) * 3.0)

func _loop() -> void:
	while not dead:
		await wait(1.2 if hp < max_hp * 0.5 else 2.0)
		if not alive():
			return
		if randf() < 0.55 and _grace <= 0.0:
			await _hook_attack()
		else:
			await _rain()

func _rain() -> void:
	audio.sfx("fisherman")
	for wave in 2:
		audio.sfx("fisherman_hook", global_position)
		var n := 9 if hp < max_hp * 0.5 else 7
		for i in n:
			var ang := PI * 0.5 + (i - (n - 1) * 0.5) * 0.27 + wave * 0.13
			shot(global_position + Vector2(-30, 70), Vector2.from_angle(ang) * 240.0, 2.5, "res://sprites/gen/sinker.png", 12.0, 5.0, 1.0, 4.0)
		await wait(0.8)
		if not alive():
			return

func _hook_attack() -> void:
	sprite.play("attack")
	audio.sfx("fisherman", global_position)
	await wait(0.9)
	if not alive():
		return
	sprite.play("idle")
	var origin := global_position + Vector2(-125, -40)
	var dir := (target.global_position - origin).normalized()
	_hook.global_position = origin
	_hook.visible = true
	audio.sfx("fisherman_hook", global_position)
	var travelled := 0.0
	var hit := false
	while travelled < 760.0 and not hit:
		await get_tree().physics_frame
		if not alive():
			_hook.visible = false
			return
		var step := dir * 560.0 * get_physics_process_delta_time()
		_hook.global_position += step
		_hook.rotation = dir.angle() - PI * 0.5
		travelled += step.length()
		if _hook.global_position.distance_to(target.global_position) < 38.0:
			hit = true
			Util.hurt_player(target, _hook.global_position, 3.0, 260.0, 0.3)
			target.stun = true
			_snag_t = 0.0
	while _hook.global_position.distance_to(origin) > 24.0:
		await get_tree().physics_frame
		if not alive():
			break
		_hook.global_position = _hook.global_position.move_toward(global_position + Vector2(-125, -40), 800.0 * get_physics_process_delta_time())
		if hit and is_instance_valid(target) and target.stun:
			target.global_position = target.global_position.move_toward(_hook.global_position, 120.0 * get_physics_process_delta_time())
			_snag_step(get_physics_process_delta_time())
	_hook.visible = false
	while hit and alive() and _snag_step(get_physics_process_delta_time()):
		await get_tree().physics_frame
	if hit:
		_grace = 4.0

func _snag_step(dt: float) -> bool:
	if not is_instance_valid(target) or not target.stun:
		return false
	_snag_t += dt
	if Input.is_action_just_pressed("escape"):
		target.escape += 1
	if _snag_t > 3.5:
		target.stun = false
		target.escape = 0
		return false
	return true
