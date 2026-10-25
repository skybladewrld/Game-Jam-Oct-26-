extends StaticBody2D
class_name colect
enum buff_add{pois , box , camo , ink , hear}
@export var animation_player : AnimationPlayer
@export var buff: buff_add

func _on_area_2d_body_entered(body: Node2D) -> void:

		match buff:
			buff_add.pois:
				body.posion_skin_unlock  = true
			buff_add.box:
				body.box_unlock  = true
			buff_add.camo:
				body.camo_unlock  = true
			buff_add.ink:
				body.ink_dash_unlock  = true
			buff_add.hear:
				global.hearing_unlock  = true
		animation_player.play("pick_up")
