extends CharacterBody2D
class_name enemy


@export var stun: Timer
@export var posi_damge : Timer
@export var sprite: AnimatedSprite2D
@export var hp: float
@export var target : CharacterBody2D 
@export var SPEED :int
@export var acttack_distance:int
@export var froce :int = 250
@export var duration :float = 0.1
@export var damage :int =1
var knok_back = Vector2(0 , 0)
var knok_back_timer = 0
var displacement : Vector2
var cool_down_pos = 0

func _ready() -> void:
	posi_damge.start()
	print(hp)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if stun.is_stopped():
		path_finding() 
	
	if knok_back_timer > 0:
		velocity = knok_back
		knok_back_timer -= delta 
	else:
		knok_back = Vector2.ZERO
	move_and_slide()

func path_finding() -> void:
	var direction = (target.position - position)
	if direction.length()  <= acttack_distance and !global.invs:
		velocity = direction.normalized() * SPEED
	else:
		velocity = Vector2.ZERO 


func _on_attack_range_body_entered(body: Node2D) -> void:
	#if body.is_in_group("player"):
		body.applay_knok_back( (target.global_position - position) , 250 , duration)
		 # why can't I use  varible force 
		global.tack_damage(body , damage)

func applay_knok_back(drirction : Vector2 , force: float , duration):
	#stun.start()
	knok_back = drirction.normalized() * force
	knok_back_timer = duration


func _on_stun_timeout() -> void:
	pass # Replace with function body.

var pois_damage = 0.5
func _on_pois_damage_timeout() -> void:
	if cool_down_pos != 0 :
		cool_down_pos -= 1
		global.tack_damage(self ,pois_damage)
