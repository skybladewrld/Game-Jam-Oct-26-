extends CharacterBody2D

@onready var dash_cool_down: Timer = $timer/dash_cool_down
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_ani: AnimatedSprite2D = $attack_ani
@onready var block_cool_down: Timer = $timer/block_cool_down
@onready var idle_off: Timer = $timer/idle_off
@onready var re_color: Timer = $timer/re_color
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var attack: Area2D = $attack

var idle_on = true
var SPEED = 150
const decelration =  30
var dash_speed = 700
var damage = 1
var hp:float = 50
var cool_down_pos = 0
var strong_atack: bool = false
var damage_mult = 1
var hit_count : int = 0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var knok_back = Vector2(0 , 0)
var knok_back_timer = 0
var stun = false
var escape = 0

var posion_skin_unlock : bool = false
var box_unlock : bool = false
var camo_unlock : bool = false
var ink_dash_unlock : bool = false
@onready var mach_space: AnimatedSprite2D = $mach_space

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if !stun:
		mach_space.visible = false
		dash()
		movement()
	else:
		mach_space.visible = true
		velocity = Vector2.ZERO
		if Input.is_action_just_pressed("escape"):
			escape += 1

	if escape >= 15 :
		stun = false
		escape = 0
	attack_block()
	power_buff()
	change_size()
	invs()
	ink_dash()
	player_rotate()
	if knok_back_timer > 0:
		velocity = knok_back
		knok_back_timer -= delta
	else:
		knok_back = Vector2.ZERO

	if hp <= 0:
		queue_free()

	move_and_slide()

func dash() -> void:
	var dash_direction = velocity.normalized()
	if Input.is_action_just_pressed("dash") and dash_cool_down.is_stopped():
		dash_cool_down.start()
		idle_on = false
		animated_sprite_2d.play("dash")
		idle_off.start(0.45)
		velocity += dash_direction * dash_speed

func movement() -> void:
	var direction_x := Input.get_axis("left", "right")
	if direction_x:
		velocity.x= move_toward(velocity.x, SPEED * direction_x, decelration)
	else:
		velocity.x = move_toward(velocity.x, 0, decelration)
	var direction_y := Input.get_axis("up", "down")
	if direction_y:
		velocity.y= move_toward(velocity.y, SPEED * direction_y, decelration)
	else:
		velocity.y = move_toward(velocity.y, 0, decelration)

	if idle_on:
		animated_sprite_2d.play("idle")

func attack_block()-> void:
	if Input.is_action_pressed("light_attack"):
		animation_player.play("attack_light")
		strong_atack = false

	if Input.is_action_pressed("hevey_attack"):
		animation_player.play("hevey_attack")
		strong_atack = true

	if Input.is_action_pressed("ult") and hit_count >= 10 :
		animation_player.play("ult")
		strong_atack = true

	if Input.is_action_pressed("block") and block_cool_down.is_stopped():
		animation_player.play("block")
		animated_sprite_2d.play("block")
		idle_on = false
		idle_off.start(1.25)
		block_cool_down.start()

func _on_dash_cool_down_timeout() -> void:
	pass

const force = 500
const duration = 0.2
func _on_attack_body_entered(body: Node2D) -> void:

	if body.is_in_group("enemy"):
		hit_count += 1
		if !body.stun.is_stopped():
			damage_mult += 0.5
		else:
			damage_mult = 1

		if strong_atack:
			body.stun.start(1.5)
		else:
			pass

		global.tack_damage(body ,damage * damage_mult)
		body.applay_knok_back( (body.global_position - position), force , duration )
		body.color()
		if posion_skin_unlock:
			body.cool_down_pos = 3

	if !body.is_in_group("enemy"):
		global.tack_damage(body ,damage * damage_mult)
		body.color()
	damage_mult = 1

func applay_knok_back(drirction : Vector2 , force: float , duration):
	knok_back = drirction.normalized() * force
	knok_back_timer = duration

func power_buff():
	if box_unlock:
		animation_player.speed_scale = 2
		animated_sprite_2d.speed_scale = 2

func change_size():

	if Input.is_action_just_pressed("change_size"):
		if global.big_size:
			animation_player.play("small_size")
			global.big_size = false
			SPEED = 300
			dash_speed = 900
			damage = 0.5
		else:
			animation_player.play("big_size")
			global.big_size = true
			SPEED = 150
			dash_speed = 700
			damage = 1

func invs():
	if velocity == Vector2.ZERO and camo_unlock:
		global.invs = true
	else:
		global.invs = false

func _on_block_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.applay_knok_back( (body.global_position - position), force , duration )

func ink_dash():
	if ink_dash_unlock and !dash_cool_down.is_stopped():
		var cur_postion = position
		var instance : Node =  preload("res://scene/black_ink.tscn").instantiate()
		get_parent().add_child(instance)
		instance.set_position(cur_postion)

func _on_ult_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if !body.stun.is_stopped():
			damage_mult += 0.5
		else:
			damage_mult = 1
		hit_count = 0
		body.stun.start(2)
		global.tack_damage(body ,damage * 2 * damage_mult)
		body.applay_knok_back( (body.global_position - position), force * 2 , duration)
	damage_mult = 1

func player_rotate() -> void:
	var direction_x := Input.get_axis("left", "right")
	var direction_y := Input.get_axis("up", "down")
	if direction_x == 1 and direction_y == -1:
		collision_shape_2d.rotation = deg_to_rad(45)
		animated_sprite_2d.rotation = deg_to_rad(45)
		attack.rotation = deg_to_rad(45)
	elif direction_x == 1 and direction_y == 0:
		collision_shape_2d.rotation = deg_to_rad(90)
		animated_sprite_2d.rotation = deg_to_rad(90)
		attack.rotation = deg_to_rad(90)
	elif direction_x == 1 and direction_y == 1:
		collision_shape_2d.rotation = deg_to_rad(135)
		animated_sprite_2d.rotation = deg_to_rad(135)
		attack.rotation = deg_to_rad(135)
	elif direction_x == 0 and direction_y == 1:
		collision_shape_2d.rotation = deg_to_rad(180)
		animated_sprite_2d.rotation = deg_to_rad(180)
		attack.rotation = deg_to_rad(180)
	elif direction_x == -1 and direction_y == 1:
		collision_shape_2d.rotation = deg_to_rad(225)
		animated_sprite_2d.rotation = deg_to_rad(225)
		attack.rotation = deg_to_rad(225)
	elif direction_x == -1 and direction_y == 0:
		collision_shape_2d.rotation = deg_to_rad(270)
		animated_sprite_2d.rotation = deg_to_rad(270)
		attack.rotation = deg_to_rad(270)
	elif direction_x == -1 and direction_y == -1:
		collision_shape_2d.rotation = deg_to_rad(315)
		animated_sprite_2d.rotation = deg_to_rad(315)
		attack.rotation = deg_to_rad(315)
	elif direction_x == 0 and direction_y == -1:
		collision_shape_2d.rotation = deg_to_rad(0)
		animated_sprite_2d.rotation = deg_to_rad(0)
		attack.rotation = deg_to_rad(0)

func _on_block_cool_down_timeout() -> void:
	pass

func _on_idle_off_timeout() -> void:
	idle_on = true

func _on_re_color_timeout() -> void:
	modulate = Color(1.0, 1.0, 1.0, 1.0)

func color():
	re_color.start()
	modulate = Color(0.0, 0.0, 0.0, 1.0)
