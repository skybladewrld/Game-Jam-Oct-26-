extends Node
# tile_map
# https://sporge.itch.io/coral-beach-2d-tileset

var invs = false
var big_size = true
var hearing_unlock : bool = false
#<<<<<<< HEAD
var posion_skin_unlock  = false
var box_unlock  = false
var camo_unlock  = false
var ink_dash_unlock  = false

var rand_num = randi_range(1 , 4)

# Called when the node enters the scene tree for the first time.
#=======
#>>>>>>> 0a8adcf3ebe4186366530aab99ab74c51a27dac7
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func tack_damage(body , damage) -> void:
	body.hp -= damage
	body.self_modulate = Color()
	print(body.hp)
