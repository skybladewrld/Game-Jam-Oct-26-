extends CharacterBody2D

@onready var re_color: Timer = $re_color
@onready var stop_attack: Timer = $stop_attack
@onready var attack_2: Timer = $attack2
@onready var chose_attack: Timer = $chose_attack
@onready var idle: AnimatedSprite2D = $idle
@onready var attack: AnimatedSprite2D = $attack
@onready var player = get_parent().get_node("player")
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var restart_attack = true
var attack_on
func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if chose_attack.is_stopped() and restart_attack:
		restart_attack = false
		chose_attack.start()
	if attack_on:
		pass
	move_and_slide()

func _on_chose_attack_timeout() -> void:
	attack.play("atack")
	restart_attack = false
	var direction = (player.global_position - global_position)
	attack.rotation = direction.angle() + deg_to_rad(-90)
	attack_2.start(1.6)

func _on_attack_2_timeout() -> void:
	attack.play("idle")
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
