extends CanvasLayer
class_name HUD

var level: Node
var _hp_fill: ColorRect
var _hp_label: Label
var _key_label: Label
var _size_label: Label
var _boss_box: Control
var _boss_fill: ColorRect
var _boss_label: Label
var _boss: Boss
var _popup: Label
var _pause: Control
var _popup_tween: Tween

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 50
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.55)
	bg.position = Vector2(16, 14)
	bg.size = Vector2(264, 24)
	add_child(bg)
	_hp_fill = ColorRect.new()
	_hp_fill.color = Color(0.9, 0.25, 0.35)
	_hp_fill.position = Vector2(18, 16)
	_hp_fill.size = Vector2(260, 20)
	add_child(_hp_fill)
	_hp_label = _label("", Vector2(24, 15), 15)
	_key_label = _label("", Vector2(18, 46), 18)
	_size_label = _label("", Vector2(18, 74), 14)
	_boss_box = Control.new()
	add_child(_boss_box)
	_boss_box.visible = false
	var bb := ColorRect.new()
	bb.color = Color(0, 0, 0, 0.6)
	bb.position = Vector2(276, 596)
	bb.size = Vector2(600, 26)
	_boss_box.add_child(bb)
	_boss_fill = ColorRect.new()
	_boss_fill.color = Color(0.7, 0.2, 0.8)
	_boss_fill.position = Vector2(278, 598)
	_boss_fill.size = Vector2(596, 22)
	_boss_box.add_child(_boss_fill)
	_boss_label = _label("", Vector2(276, 566), 20, _boss_box)
	_popup = _label("", Vector2(0, 110), 26)
	_popup.size = Vector2(1152, 40)
	_popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_popup.modulate.a = 0.0
	_pause = ColorRect.new()
	(_pause as ColorRect).color = Color(0, 0, 0, 0.7)
	_pause.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pause.visible = false
	add_child(_pause)
	var pl := Label.new()
	pl.text = "PAUSED\n\nEsc - resume\nQ - back to title"
	pl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pl.add_theme_font_size_override("font_size", 32)
	pl.set_anchors_preset(Control.PRESET_FULL_RECT)
	pl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_pause.add_child(pl)

func _label(text: String, pos: Vector2, size: int, parent: Node = null) -> Label:
	var l := Label.new()
	l.text = text
	l.position = pos
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	l.add_theme_constant_override("outline_size", 5)
	(parent if parent else self).add_child(l)
	return l

func popup(text: String, secs := 2.6) -> void:
	_popup.text = text
	if _popup_tween:
		_popup_tween.kill()
	_popup.modulate.a = 1.0
	_popup_tween = create_tween()
	_popup_tween.tween_interval(secs)
	_popup_tween.tween_property(_popup, "modulate:a", 0.0, 0.8)

func show_boss(b: Boss) -> void:
	_boss = b
	_boss_label.text = b.boss_name
	_boss_box.visible = true

func hide_boss() -> void:
	_boss_box.visible = false
	_boss = null

func _process(_delta: float) -> void:
	if level and is_instance_valid(level.player):
		var hp: float = clampf(level.player.hp, 0.0, game.MAX_HP)
		_hp_fill.size.x = 260.0 * hp / game.MAX_HP
		_hp_label.text = "HP %d" % ceili(hp)
	_key_label.text = "coral keys: %d" % game.keys
	_size_label.text = "BIG  (Z = shrink)" if global.big_size else "SMALL  (Z = grow)  fits tiny gaps"
	if _boss and is_instance_valid(_boss):
		_boss_fill.size.x = 596.0 * clampf(_boss.hp / _boss.max_hp, 0.0, 1.0)

func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_cancel"):
		_pause.visible = not _pause.visible
		get_tree().paused = _pause.visible
	elif _pause.visible and e is InputEventKey and e.pressed and e.keycode == KEY_Q:
		game.go_title()
