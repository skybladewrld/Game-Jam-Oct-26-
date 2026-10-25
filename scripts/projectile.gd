extends Area2D
class_name Projectile

var vel := Vector2.ZERO
var dmg := 2.0
var life := 4.0
var radius := 10.0
var tex_path := "res://sprites/gen/ink_shot.png"
var tex_scale := 1.0
var spin := 0.0
var knock := 220.0
var target: Node2D

func setup(pos: Vector2, v: Vector2, d: float, tex := "res://sprites/gen/ink_shot.png", r := 10.0, lifetime := 4.0, scl := 1.0) -> Projectile:
	position = pos
	vel = v
	dmg = d
	tex_path = tex
	radius = r
	life = lifetime
	tex_scale = scl
	return self

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1 | 1024
	add_child(Util.circle(radius))
	var s := Sprite2D.new()
	s.texture = load(tex_path)
	s.scale = Vector2.ONE * tex_scale
	add_child(s)
	body_entered.connect(_on_body)
	rotation = vel.angle()

func _physics_process(delta: float) -> void:
	position += vel * delta
	if spin != 0.0:
		rotation += spin * delta
	life -= delta
	if life <= 0.0:
		queue_free()

func _on_body(b: Node2D) -> void:
	if b == target:
		Util.hurt_player(b, global_position - vel.normalized() * 10.0, dmg, knock)
		queue_free()
	elif b is StaticBody2D:
		queue_free()
