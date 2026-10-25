extends Node2D
class_name Telegraph

signal boom(pos: Vector2)
var radius := 100.0
var delay := 1.0
var dmg := 5.0
var target: Node2D
var sfx_name := ""
var _t := 0.0

func _process(delta: float) -> void:
	_t += delta
	queue_redraw()
	if _t >= delay:
		if is_instance_valid(target) and target.global_position.distance_to(global_position) <= radius:
			Util.hurt_player(target, global_position, dmg, 420.0, 0.2)
		if sfx_name != "":
			audio.sfx(sfx_name, global_position)
		boom.emit(global_position)
		queue_free()

func _draw() -> void:
	var k := clampf(_t / delay, 0.0, 1.0)
	draw_circle(Vector2.ZERO, radius, Color(0.9, 0.1, 0.15, 0.10 + 0.25 * k))
	draw_arc(Vector2.ZERO, radius, 0, TAU, 48, Color(1, 0.3, 0.3, 0.9), 3.0)
	draw_circle(Vector2.ZERO, radius * k, Color(1, 0.25, 0.2, 0.35))
