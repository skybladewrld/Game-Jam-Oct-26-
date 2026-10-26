extends StaticBody2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var target = get_parent().player
var damage = 0.25
var duration = 0.1
func _ready() -> void:
	animation_player.play("fade_out")
	


func _on_area_2d_body_entered(body: Node2D) -> void:
		#if body.is_in_group("player"):
		
	body.applay_knok_back( -(target.global_position - position).rotated(PI / 2) , 250 , duration)
	body.color()
	global.tack_damage(body , damage)

	
