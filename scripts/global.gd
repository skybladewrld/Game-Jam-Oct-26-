extends Node
var invs = false
var big_size = true
var hearing_unlock : bool = false
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func tack_damage(body , damage) -> void:
	body.hp -= damage
	body.self_modulate = Color()
	print(body.hp)
