extends CharacterBody2D

@onready var dash_cool_down: Timer = $timer/dash_cool_down
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 300
const decelration =  30
const dash_speed = 900
var damage = 1
var hp:float = 5
var cool_down_pos = 0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var knok_back = Vector2(0 , 0)
var knok_back_timer = 0



var posion_skin_unlock : bool = false
var box_unlock : bool = false
var camo_unlock : bool = true
var ink_dash_unlock : bool = false
var hearing_unlock : bool = false

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	
	dash()
	movement()
	attack()
	power_buff()
	change_size()
	hides()
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
	
func attack()-> void:
	if Input.is_action_pressed("light_attack"):
		animation_player.play("attack_light")

	if Input.is_action_pressed("hevey_attack"):
		animation_player.play("attack_light")


func _on_dash_cool_down_timeout() -> void:
	pass # Replace with function body.

const force = 500
const duration = 0.2
func _on_attack_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		global.tack_damage(body ,damage)
		body.applay_knok_back( (body.global_position - position), force , duration )
		
		if posion_skin_unlock:
			body.cool_down_pos = 3

func applay_knok_back(drirction : Vector2 , force: float , duration):
	knok_back = drirction.normalized() * force
	knok_back_timer = duration

func power_buff():
	if box_unlock:
		damage = 1.5 # 1.5x damage
		animation_player.speed_scale = 1.5 # doubles speed of attack
		animated_sprite_2d.speed_scale = 1.5 # doubles speed of animation


func change_size():
	if Input.is_action_just_pressed("change_size"):
		if global.big_size:
			animation_player.play("small_size")
			global.big_size = false
		else:
			animation_player.play("big_size")
			global.big_size = true
			
func hides():
	if velocity == Vector2.ZERO and camo_unlock:
		global.invs = true
	else:
		global.invs = false
