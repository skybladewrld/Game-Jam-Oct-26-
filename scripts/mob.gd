extends CharacterBody2D
class_name Mob

signal died(mob)

const KINDS := {
	"crab": {"tex": "res://sprites/crab_idel_move.png", "n": 2, "fps": 4, "hp": 4.0, "speed": 70.0, "dmg": 2.0, "r": 20.0, "sense": 380.0, "ai": "chase", "move": "sea_urchin", "atk": "viperfish_bite"},
	"eel": {"tex": "res://sprites/ell_move.png", "n": 9, "fps": 12, "hp": 3.0, "speed": 135.0, "dmg": 3.0, "r": 14.0, "sense": 440.0, "ai": "zig", "move": "electric_eel", "atk": "eel_zap", "scale": 1.2},
	"viperfish": {"tex": "res://sprites/gen/viperfish.png", "n": 2, "fps": 5, "hp": 6.0, "speed": 75.0, "dmg": 4.0, "r": 20.0, "sense": 460.0, "ai": "lunge", "move": "viperfish", "atk": "viperfish_bite", "scale": 1.15},
	"snake": {"tex": "res://sprites/gen/seasnake.png", "n": 4, "fps": 8, "hp": 5.0, "speed": 100.0, "dmg": 3.0, "r": 16.0, "sense": 460.0, "ai": "wave", "move": "sea_snake", "atk": "sea_snake_strike", "scale": 1.15},
	"urchin": {"tex": "res://sprites/gen/urchin.png", "n": 2, "fps": 2, "hp": 9999.0, "speed": 0.0, "dmg": 2.0, "r": 24.0, "sense": 0.0, "ai": "static", "move": "", "atk": "viperfish_bite", "scale": 1.0},
	"seahorse": {"tex": "res://sprites/gen/seahorse.png", "n": 2, "fps": 3, "hp": 2.0, "speed": 30.0, "dmg": 0.0, "r": 14.0, "sense": 0.0, "ai": "peace", "move": "seahorse"},
	"starfish": {"tex": "res://sprites/gen/starfish.png", "n": 2, "fps": 2, "hp": 2.0, "speed": 18.0, "dmg": 0.0, "r": 18.0, "sense": 0.0, "ai": "peace", "move": "starfish"},
	"fish": {"tex": "res://sprites/gen/fishschool.png", "n": 2, "fps": 4, "hp": 2.0, "speed": 45.0, "dmg": 0.0, "r": 22.0, "sense": 0.0, "ai": "peace", "move": "fish_school"},
}

var kind := "crab"
var cfg: Dictionary
var hp := 3.0
var stun: Timer
var cool_down_pos := 0
var target: Node2D
var sprite: AnimatedSprite2D
var hitbox: Area2D
var home := Vector2.ZERO
var hostile := true

var _knock := Vector2.ZERO
var _knock_t := 0.0
var _atk_cd := 0.0
var _t := randf() * 10.0
var _wander := Vector2.ZERO
var _wander_t := 0.0
var _lunge_t := 0.0
var _lunge_cd := 0.0
var _lunge_dir := Vector2.ZERO
var _move_sfx_t := randf_range(1.0, 5.0)
var _pois_t := 1.5

func setup(k: String, tgt: Node2D) -> Mob:
	kind = k
	cfg = KINDS[k]
	target = tgt
	hp = cfg["hp"]
	hostile = cfg["dmg"] > 0.0
	return self

func _ready() -> void:
	home = global_position
	add_to_group("enemy" if hostile else "peaceful")
	collision_layer = 4
	collision_mask = 1 | 1024
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	add_child(Util.circle(cfg["r"]))
	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = Util.frames(cfg["tex"], 64, 64, cfg["n"], cfg["fps"])
	sprite.scale = Vector2.ONE * float(cfg.get("scale", 1.0))
	sprite.play("idle")
	sprite.frame = randi() % cfg["n"]
	add_child(sprite)
	stun = Timer.new()
	stun.one_shot = true
	stun.wait_time = 0.5
	add_child(stun)
	hitbox = Area2D.new()
	hitbox.collision_layer = 0
	hitbox.collision_mask = 1
	hitbox.add_child(Util.circle(cfg["r"] + 8.0))
	add_child(hitbox)

func _physics_process(delta: float) -> void:
	_t += delta
	_atk_cd -= delta
	if hp <= 0.0:
		died.emit(self)
		queue_free()
		return
	if cool_down_pos > 0:
		_pois_t -= delta
		if _pois_t <= 0.0:
			_pois_t = 1.5
			cool_down_pos -= 1
			hp -= 0.5
	if _knock_t > 0.0:
		velocity = _knock
		_knock_t -= delta
	elif not stun.is_stopped():
		velocity = Vector2.ZERO
	else:
		velocity = _ai(delta)
	move_and_slide()
	if absf(velocity.x) > 4.0:
		sprite.flip_h = velocity.x > 0.0
	_contact()
	_sound(delta)

func _alive_target() -> bool:
	return is_instance_valid(target)

func _ai(delta: float) -> Vector2:
	var ai: String = cfg["ai"]
	if ai == "static":
		return Vector2.ZERO
	if ai == "peace" or not _alive_target():
		return _wandering(delta)
	var to: Vector2 = target.global_position - global_position
	var d := to.length()
	if global.invs or d > cfg["sense"]:
		return _wandering(delta) * 0.6
	var dir := to / maxf(d, 0.001)
	var sp: float = cfg["speed"]
	match ai:
		"chase":
			return dir * sp
		"zig":
			var side := Vector2(-dir.y, dir.x)
			return (dir + side * sin(_t * 6.0) * 0.8).normalized() * sp
		"wave":
			var side2 := Vector2(-dir.y, dir.x)
			return (dir + side2 * sin(_t * 3.5) * 0.7).normalized() * sp
		"lunge":
			_lunge_cd -= delta
			if _lunge_t > 0.0:
				_lunge_t -= delta
				return _lunge_dir * 390.0
			if d < 230.0 and _lunge_cd <= 0.0:
				_lunge_t = 0.35
				_lunge_cd = 1.8
				_lunge_dir = dir
				audio.sfx(cfg["atk"], global_position)
				return Vector2.ZERO
			return dir * sp * (0.4 if d < 230.0 else 1.0)
	return Vector2.ZERO

func _wandering(delta: float) -> Vector2:
	_wander_t -= delta
	if _wander_t <= 0.0:
		_wander_t = randf_range(1.5, 3.5)
		_wander = Vector2.from_angle(randf() * TAU) * cfg["speed"] * randf_range(0.3, 1.0)
		if global_position.distance_to(home) > 160.0:
			_wander = (home - global_position).normalized() * cfg["speed"]
	return _wander

func _contact() -> void:
	if not hostile or _atk_cd > 0.0 or not _alive_target():
		return
	for b in hitbox.get_overlapping_bodies():
		if b == target:
			_atk_cd = 1.0
			Util.hurt_player(target, global_position, cfg["dmg"])
			if cfg["atk"] != "":
				audio.sfx(cfg["atk"], global_position)
			break

func _sound(delta: float) -> void:
	_move_sfx_t -= delta
	if _move_sfx_t <= 0.0:
		_move_sfx_t = randf_range(4.0, 8.0)
		if cfg["move"] != "":
			audio.sfx(cfg["move"], global_position)

func applay_knok_back(direction: Vector2, force: float, duration: float) -> void:
	_knock = direction.normalized() * force
	_knock_t = duration

func color() -> void:
	sprite.modulate = Color(0.1, 0.1, 0.1, 1.0)
	create_tween().tween_property(sprite, "modulate", Color.WHITE, 0.2)
