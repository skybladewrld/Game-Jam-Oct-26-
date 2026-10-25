extends CharacterBody2D
class_name enemy

@export var re_color:Timer
@export var stun: Timer
@export var posi_damge : Timer
@export var sprite: AnimatedSprite2D
@export var hp: float
@onready var target  = get_parent().get_node("player")
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

func _process(delta: float) -> void:
	velocity =path_finding()

	if knok_back_timer > 0:
		velocity = knok_back
		knok_back_timer -= delta
	else:
		knok_back = Vector2.ZERO

	if hp <= 0:
		queue_free()
	move_and_slide()

func path_finding() -> Vector2:
	var direction = (target.position - position)
	var speed :Vector2
	if direction.length() > acttack_distance:
		return Vector2.ZERO
	if global.invs:
		return Vector2.ZERO
	if !stun.is_stopped():
		return Vector2.ZERO
	look_at(direction)
	speed = direction.normalized() * SPEED
	return speed

func _on_attack_range_body_entered(body: Node2D) -> void:
	body.applay_knok_back( (target.global_position - position) , 250 , duration)
	body.color()
	global.tack_damage(body , damage)

func applay_knok_back(drirction : Vector2 , force: float , duration):
	knok_back = drirction.normalized() * force
	knok_back_timer = duration

func _on_stun_timeout() -> void:
	pass

var pois_damage = 0.5
func _on_pois_damage_timeout() -> void:
	if cool_down_pos != 0 :
		cool_down_pos -= 1
		global.tack_damage(self ,pois_damage)

func _on_re_color_timeout() -> void:
	modulate = Color(1.0, 1.0, 1.0, 1.0)

func color():
	re_color.start()
	modulate = Color(0.0, 0.0, 0.0, 1.0)
