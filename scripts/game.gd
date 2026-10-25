extends Node

const MAX_HP := 50.0
const LEVELS := [
	"res://scene/levels/level_1.tscn",
]
const TITLE := "res://scene/levels/level_1.tscn"
const GAME_OVER := "res://scene/game_over.tscn"
const WIN := "res://scene/win.tscn"

var level_index := 0
var hp := MAX_HP
var upgrades := {"pois": false, "box": false, "camo": false, "ink": false, "hear": false}
var keys := 0
var checkpoint := Vector2.INF
var taken: Array = []
var opened: Array = []
var boss_dead := false
var deaths := 0
var leaving := false

var _fade: ColorRect
var _busy := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	_fade = ColorRect.new()
	_fade.color = Color(0.01, 0.02, 0.06, 1.0)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade.modulate.a = 0.0
	layer.add_child(_fade)

func new_game() -> void:
	upgrades = {"pois": false, "box": false, "camo": false, "ink": false, "hear": false}
	deaths = 0
	load_level(0)

func load_level(i: int) -> void:
	level_index = i
	hp = MAX_HP
	keys = 0
	checkpoint = Vector2.INF
	taken = []
	opened = []
	boss_dead = false
	_goto(LEVELS[i])

func retry() -> void:
	hp = MAX_HP
	_goto(LEVELS[level_index])

func next_level() -> void:
	if level_index + 1 >= LEVELS.size():
		_goto(WIN)
	else:
		load_level(level_index + 1)

func player_died() -> void:
	deaths += 1
	_goto(GAME_OVER)

func go_title() -> void:
	new_game()

func _goto(path: String) -> void:
	if _busy:
		return
	_busy = true
	leaving = true
	get_tree().paused = false
	var t := create_tween()
	t.tween_property(_fade, "modulate:a", 1.0, 0.35)
	await t.finished
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	leaving = false
	var t2 := create_tween()
	t2.tween_property(_fade, "modulate:a", 0.0, 0.5)
	await t2.finished
	_busy = false

func load_level_for_test(i: int) -> void:
	level_index = i - 1
	hp = MAX_HP
	keys = 0
	checkpoint = Vector2.INF
	taken = []
	opened = []
	boss_dead = false
