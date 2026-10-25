extends MenuBase

func _ready() -> void:
	super()
	audio.stop_music(1.0)
	add_text("YOU SANK", 150, 80, Color(1.0, 0.45, 0.5))
	add_text("the deep keeps another octopus...", 260, 26)
	blink(add_text("ENTER - try again from your last checkpoint", 380, 28))
	add_text("ESC - back to the title", 440, 22, Color(0.8, 0.95, 1.0))
	add_text("deaths this run: %d" % game.deaths, 520, 18, Color(0.7, 0.8, 0.9))

func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed:
		if e.keycode == KEY_ENTER or e.keycode == KEY_KP_ENTER or e.keycode == KEY_SPACE:
			game.retry()
		elif e.keycode == KEY_ESCAPE:
			game.go_title()
