extends Marker2D

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var arrow: Sprite2D = $arrow

# Called when the node enters the scene tree for the first time.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	if !visible_on_screen_notifier_2d.is_on_screen() and global.hearing_unlock:
		arrow.visible = true
		arrow.look_at(global_position)
		ray_cast_2d.target_position =to_local( get_node("../../player").global_position)
		arrow.global_position = ray_cast_2d.get_collision_point()
	else:
		arrow.visible = false
