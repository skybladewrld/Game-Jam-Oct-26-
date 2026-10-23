extends StaticBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _process(delta: float) -> void:
	if !global.big_size:
		animation_player.play("size_small")
	else:
		animation_player.play("size_big")
