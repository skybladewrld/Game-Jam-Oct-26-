extends StaticBody2D
@onready var re_color: Timer = $re_color
@onready var stop_attack: Timer = $stop_attack
@onready var attack_2: Timer = $attack2
@onready var chose_attack: Timer = $chose_attack
@onready var idle: AnimatedSprite2D = $idle
@onready var boss_face: AnimatedSprite2D = $boss_face
@onready var player = get_parent().get_node("player")
var hp = 30
const speed = 1500.0
var restart_attack = true
var attack_on
var golb_direction


func _physics_process(delta: float) -> void:
	if hp <= 0:
		queue_free()

	if chose_attack.is_stopped() and restart_attack: 
		restart_attack = false
		chose_attack.start()
	if attack_on:
		pass


func _on_chose_attack_timeout() -> void:
	boss_face.play("attack")
	restart_attack = false

	
	attack_2.start(1.6)

func _on_attack_2_timeout() -> void:
	var direction = (player.global_position - global_position)
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
