extends Control
class_name MenuBase

var _bubbles: Array = []
var _t := 0.0

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	for i in 28:
		_bubbles.append([randf() * 1152.0, randf() * 700.0, randf_range(3.0, 11.0), randf_range(18.0, 60.0)])

func _process(delta: float) -> void:
	_t += delta
	for b in _bubbles:
		b[1] -= b[3] * delta
		if b[1] < -20.0:
			b[1] = 670.0
			b[0] = randf() * 1152.0
	queue_redraw()

func _draw() -> void:
	var s := get_viewport_rect().size
	draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(s.x, 0), s, Vector2(0, s.y)]), PackedColorArray([Color("1d6f9a"), Color("1d6f9a"), Color("020a22"), Color("020a22")]))
	for b in _bubbles:
		draw_arc(Vector2(b[0] + sin(_t + b[2]) * 8.0, b[1]), b[2], 0, TAU, 20, Color(0.85, 0.97, 1.0, 0.45), 1.5)

func add_text(text: String, y: float, size: int, color := Color.WHITE) -> Label:
	var l := Label.new()
	l.text = text
	l.set_anchors_preset(Control.PRESET_TOP_WIDE)
	l.position.y = y
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0.02, 0.08))
	l.add_theme_constant_override("outline_size", 6)
	add_child(l)
	return l

func blink(l: Label) -> void:
	var tw := create_tween().set_loops()
	tw.tween_property(l, "modulate:a", 0.25, 0.8)
	tw.tween_property(l, "modulate:a", 1.0, 0.8)
