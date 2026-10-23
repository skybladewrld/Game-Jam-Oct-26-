extends CharacterBody2D

@onready var dash_cool_down: Timer = $timer/dash_cool_down
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var SPEED = 300
const decelration =  30
var dash_speed = 900
var damage = 1
var hp:float = 5
var cool_down_pos = 0
var strong_atack: bool = false
var damage_mult = 1
var hit_count : int = 0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var knok_back = Vector2(0 , 0)
var knok_back_timer = 0



var posion_skin_unlock : bool = false
var box_unlock : bool = false
var camo_unlock : bool = false
var ink_dash_unlock : bool = false


func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	
	dash()
	movement()
	attack_block()
	power_buff()
	change_size()
	invs()
	ink_dash()
	if knok_back_timer > 0:
		velocity = knok_back
		knok_back_timer -= delta 
	else:
		knok_back = Vector2.ZERO

	move_and_slide()

func dash() -> void:
	var dash_direction = velocity.normalized()
	if Input.is_action_just_pressed("dash") and dash_cool_down.is_stopped():
		dash_cool_down.start()
		velocity += dash_direction * dash_speed

func movement() -> void:
	var direction_x := Input.get_axis("left", "right")
	if direction_x:
		velocity.x= move_toward(velocity.x, SPEED * direction_x, decelration) 
	else:
		velocity.x = move_toward(velocity.x, 0, decelration) 
######################################################
	var direction_y := Input.get_axis("up", "down")
	if direction_y:
		velocity.y= move_toward(velocity.y, SPEED * direction_y, decelration) 
	else:
		velocity.y = move_toward(velocity.y, 0, decelration)
	
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
		
	if Input.is_action_pressed("block"):
		animation_player.play("block")

func _on_dash_cool_down_timeout() -> void:
	pass # Replace with function body.

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
			body.stun.start(1.5) # 1.5 = stun amount

		global.tack_damage(body ,damage * damage_mult)
		body.applay_knok_back( (body.global_position - position), force , duration )

		if posion_skin_unlock:
			body.cool_down_pos = 3
	damage_mult = 1

func applay_knok_back(drirction : Vector2 , force: float , duration):
	knok_back = drirction.normalized() * force
	knok_back_timer = duration

func power_buff():
	if box_unlock:
		animation_player.speed_scale = 2 # doubles speed of attack
		animated_sprite_2d.speed_scale = 2 # doubles speed of animation


func change_size():
	
	if Input.is_action_just_pressed("change_size"):
		if global.big_size:
			animation_player.play("small_size")
			global.big_size = false
			SPEED = 600
			dash_speed = 1100
		else:
			animation_player.play("big_size")
			global.big_size = true
			SPEED = 300
			dash_speed = 900
			
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
		hit_count = 0
		body.stun.start(2)
		global.tack_damage(body ,damage * 2) # ult does 2x damage than a normal attack
		body.applay_knok_back( (body.global_position - position), force * 2 , duration)
