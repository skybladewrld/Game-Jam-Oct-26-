extends Node

var player
var _run_t := 0.0
var _was_dash := false

func bind(p) -> void:
	player = p
	player.animation_player.animation_started.connect(_on_anim)

func _on_anim(anim: StringName) -> void:
	match anim:
		&"attack_light": audio.sfx("light")
		&"hevey_attack": audio.sfx("heavy")
		&"ult": audio.sfx("heavy", Vector2.INF, 3.0)
		&"small_size", &"big_size": audio.sfx("dash", Vector2.INF, -9.0)

func _process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	var dashing: bool = not player.dash_cool_down.is_stopped()
	if dashing and not _was_dash:
		audio.sfx("dash")
	_was_dash = dashing
	if player.velocity.length() > 70.0 and not player.stun:
		_run_t -= delta
		if _run_t <= 0.0:
			audio.sfx("run")
			_run_t = 0.4 if global.big_size else 0.27
	else:
		_run_t = 0.08
