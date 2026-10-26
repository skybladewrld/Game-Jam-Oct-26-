extends StaticBody2D
class_name colect
enum buff_add{pois , box , camo , ink , hear}
@export var animation_player : AnimationPlayer
@export var buff: buff_add



func _on_area_2d_body_entered(body: Node2D) -> void:
	
	#if body.is_in_group("player"):
	
		match buff:
			buff_add.pois:
				global.posion_skin_unlock  = true
			buff_add.box:
				global.box_unlock  = true
			buff_add.camo:
				global.camo_unlock  = true
			buff_add.ink:
				global.ink_dash_unlock  = true
			buff_add.hear:
				global.hearing_unlock  = true
		animation_player.play("pick_up")
