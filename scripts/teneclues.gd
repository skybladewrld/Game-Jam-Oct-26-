extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var speed = 200
@export var angle :int = 0
var radious = 250
@export var picked :int =0
@onready var target = get_parent().player
var speed_movement
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if global.rand_num != picked:
		angle +=delta * speed
		position =  Vector2.from_angle(deg_to_rad(angle)) * radious
	else:
		pass

		
func path_finding() -> void:
	pass
	var direction = (target.position - position)

	if direction.lenght() <= 90:
		animated_sprite_2d.play("tenclu_attack")
	else:
		velocity = direction.normalized() * speed_movement
