extends StaticBody2D

@onready var marker_rotation: Node2D = $marker_rotation
@onready var marker_2d: Marker2D = $marker_rotation/Marker2D
@onready var re_color: Timer = $re_color
@onready var stop_attack: Timer = $stop_attack
@onready var attack_2: Timer = $attack2
@onready var chose_attack: Timer = $chose_attack
@onready var idle: AnimatedSprite2D = $idle
@onready var attack: AnimatedSprite2D = $attack
@onready var player = get_parent().get_node("player")
var hp = 10
const speed = 1500.0
var restart_attack = true
var attack_on
var golb_direction
@onready var org_pos = marker_2d.position
func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
<<<<<<< HEAD
	if hp <= 0:
		queue_free()
	if chose_attack.is_stopped() and restart_attack: 
=======
	if chose_attack.is_stopped() and restart_attack:
>>>>>>> 0a8adcf3ebe4186366530aab99ab74c51a27dac7
		restart_attack = false
		chose_attack.start()
	if attack_on:
		var instance : Node =  preload("res://scene/boss_ink.tscn").instantiate()
		add_child(instance)
		instance.set_position(marker_2d.position)
		marker_2d.position += golb_direction.normalized() * speed * delta
	else:
		marker_2d.position = org_pos

# allow animation to play (visual que)
func _on_chose_attack_timeout() -> void:
	attack.play("attack")
	restart_attack = false

	

	
	attack_2.start(1.6)

func _on_attack_2_timeout() -> void:
	attack.play("idle")
	var direction = (player.global_position - global_position)
	attack.rotation = direction.angle() + deg_to_rad(-90)
	marker_rotation.rotation =direction.angle()
	golb_direction = direction
	attack_on = true
	stop_attack.start()

func _on_stop_attack_timeout() -> void:
	attack_on = false
	restart_attack = true

func _on_re_color_timeout() -> void:
	modulate = Color(1.0, 1.0, 1.0, 1.0)
func color():
	re_color.start()
	modulate = Color(0.0, 0.0, 0.0, 1.0)
