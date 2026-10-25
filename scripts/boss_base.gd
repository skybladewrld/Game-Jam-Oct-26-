extends CharacterBody2D
class_name Boss

signal died
signal phase_changed(phase: int)

var boss_name := "Boss"
var hp := 30.0
var max_hp := 30.0
var phase := 1
var active := false
var dead := false
var contact_dmg := 3.0
var target: Node2D
var level: Node
var sprite: AnimatedSprite2D
var hitbox: Area2D
var home := Vector2.ZERO
var _t := 0.0
var _contact_cd := 0.0

func _ready() -> void:
	home = global_position
	collision_layer = 4
	collision_mask = 1 | 1024
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	sprite = AnimatedSprite2D.new()
	add_child(sprite)
	build()
	hitbox = Area2D.new()
	hitbox.collision_layer = 0
	hitbox.collision_mask = 1
	hitbox.add_child(_hit_shape())
	add_child(hitbox)

func build() -> void:
	pass

func _hit_shape() -> CollisionShape2D:
	return Util.circle(60.0)

func activate() -> void:
	if active or dead:
		return
	active = true
	_loop()

func _loop() -> void:
	pass

func _tick(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if dead:
		return
	if not active:
		hp = max_hp
		return
	if hp <= 0.0:
		_die()
		return
	_t += delta
	_contact_cd -= delta
	_tick(delta)
	move_and_slide()
	if _contact_cd <= 0.0 and is_instance_valid(target):
		for b in hitbox.get_overlapping_bodies():
			if b == target:
				_contact_cd = 1.0
				Util.hurt_player(target, global_position, contact_dmg, 340.0, 0.2)
				break

func alive() -> bool:
	return active and not dead and is_instance_valid(target) and is_inside_tree()

func wait(t: float) -> void:
	await get_tree().create_timer(t).timeout

func _die() -> void:
	dead = true
	collision_layer = 0
	velocity = Vector2.ZERO
	if level and level.has_method("shake"):
		level.shake(16.0, 1.0)
	var t := create_tween()
	t.tween_property(sprite, "modulate", Color(1, 1, 1, 0), 1.4)
	t.tween_callback(func(): visible = false)
	died.emit()

func color() -> void:
	if dead:
		return
	sprite.modulate = Color(0.15, 0.1, 0.1, 1.0)
	create_tween().tween_property(sprite, "modulate", Color.WHITE, 0.15)

func shot(pos: Vector2, vel: Vector2, dmg: float, tex := "res://sprites/gen/ink_shot.png", r := 11.0, life := 4.0, scl := 1.0, spin := 0.0) -> void:
	var p := Projectile.new().setup(pos, vel, dmg, tex, r, life, scl)
	p.target = target
	p.spin = spin
	get_parent().add_child(p)

func telegraph(pos: Vector2, radius: float, delay: float, dmg: float, sfx := "") -> void:
	var tg := Telegraph.new()
	tg.position = pos
	tg.radius = radius
	tg.delay = delay
	tg.dmg = dmg
	tg.target = target
	tg.sfx_name = sfx
	tg.boom.connect(func(_p): if level and level.has_method("shake"): level.shake(7.0, 0.25))
	get_parent().add_child(tg)
