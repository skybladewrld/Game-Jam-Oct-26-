class_name Util

static func frames(tex_path: String, fw: int, fh: int, n: int, fps: float, anim := "idle", frames_ref: SpriteFrames = null) -> SpriteFrames:
	var sf := frames_ref if frames_ref else SpriteFrames.new()
	if sf.has_animation("default") and anim != "default":
		sf.remove_animation("default")
	sf.add_animation(anim)
	sf.set_animation_speed(anim, fps)
	sf.set_animation_loop(anim, true)
	var tex: Texture2D = load(tex_path)
	for i in n:
		var at := AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2(i * fw, 0, fw, fh)
		sf.add_frame(anim, at)
	return sf

static func circle(radius: float) -> CollisionShape2D:
	var cs := CollisionShape2D.new()
	var sh := CircleShape2D.new()
	sh.radius = radius
	cs.shape = sh
	return cs

static func rect(size: Vector2, pos := Vector2.ZERO) -> CollisionShape2D:
	var cs := CollisionShape2D.new()
	var sh := RectangleShape2D.new()
	sh.size = size
	cs.shape = sh
	cs.position = pos
	return cs

static func hurt_player(player: Node, from: Vector2, dmg: float, knock := 260.0, dur := 0.15) -> void:
	if not is_instance_valid(player):
		return
	global.tack_damage(player, dmg)
	player.applay_knok_back(player.global_position - from, knock, dur)
	player.color()
