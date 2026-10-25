extends MenuBase

func _ready() -> void:
	super()
	audio.play_music("title", 1.0)
	add_text("THE KRAKEN SLEEPS", 120, 70, Color(1.0, 0.9, 0.5))
	add_text("you reached the bottom of the deep.\nnot bad for a little octopus.", 240, 28)
	add_text("deaths this run: %d" % game.deaths, 360, 20, Color(0.8, 0.95, 1.0))
	blink(add_text("ENTER - back to the title", 440, 30))
	add_text("thanks for playing  -  made for the Hack Club Game Jam", 580, 16, Color(0.7, 0.8, 0.9))

func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and (e.keycode == KEY_ENTER or e.keycode == KEY_KP_ENTER or e.keycode == KEY_SPACE):
		game.go_title()
