extends StaticBody2D
@onready var re_color: Timer = $re_color

@onready var chose_attack: Timer = $chose_attack
@onready var hook: Sprite2D = $hook_1/hook

@export var animation_player: AnimationPlayer
@onready var stop_attack: Timer = $stop_attack

@onready var hook_1:StaticBody2D  = $hook_1

@onready var attack: AnimatedSprite2D = $attack
@onready var line_2d: Line2D = $Line2D
 
@onready var attack_2: Timer = $attack2
@onready var player :CharacterBody2D = get_parent().get_node("player")
var speed = 300.0
const trap_speed = 300.0
var attack_on = false
var continue_hook = false
var trap_hook :int = -1
var restart_attack = true
var del
var tween = create_tween()
var hp = 10
@onready var return_org = hook_1.position
@onready var return_rot = hook_1.rotation
func _ready() -> void:
	pass
	#animation_player.play("move")


func _physics_process(delta: float) -> void:
	del = delta
	if attack_on:
		hook_direction(delta , speed)
	else:
		hook_1.position = return_org
		hook_1.rotation = return_rot
	if chose_attack.is_stopped() and restart_attack:
		restart_attack = false
		chose_attack.start()
<<<<<<< HEAD
	queue_redraw()
	#line_2d.points = hook_1.position


	
=======

>>>>>>> 0a8adcf3ebe4186366530aab99ab74c51a27dac7
	if hp <= 0:
		queue_free()


func _on_chose_attack_timeout() -> void:
	attack.play("atack")
	restart_attack = false
	attack_2.start(1.6)

func _on_attack_2_timeout() -> void:
	attack.play("idle")
	attack_on = true
	stop_attack.start()
	speed = trap_speed

func _on_area_2d_body_entered(body: Node2D) -> void:
	attack_on = false
	body.escap_num = 10
	global.tack_damage(body , 1)
	body.applay_knok_back( -(body.global_position - hook_1.position), 250 , 0.5 )
	body.color()
	body.stun = true

func hook_direction(delta , speed):
	var direction = (player.global_position - hook_1.global_position)
<<<<<<< HEAD
	hook_1.rotation = direction.angle() + deg_to_rad(15)
	#tween.tween_property(hook_1 , "global_position" , player.global_position , 5)#direction.length() /speed )
	hook_1.position += Vector2.from_angle(direction.angle())* speed * delta 

=======
	hook_1.rotation = direction.angle() + deg_to_rad(-90)
	hook_1.position += Vector2.from_angle(direction.angle())* speed * delta
>>>>>>> 0a8adcf3ebe4186366530aab99ab74c51a27dac7

func _on_stop_attack_timeout() -> void:
	attack_on = false
	restart_attack = true

func _on_re_color_timeout() -> void:
	modulate = Color(1.0, 1.0, 1.0, 1.0)

func color():
	re_color.start()
	modulate = Color(0.0, 0.0, 0.0, 1.0)


func _draw() -> void:
	draw_line(Vector2(-151 , -64) ,hook_1.position , Color.HOT_PINK , 2)
