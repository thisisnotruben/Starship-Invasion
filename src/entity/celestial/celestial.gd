extends IToggleable

@onready var anim: AnimationPlayer = $anim

@export_category("Hover")
@export var hover_anim := true
@export_range(0.1, 0.5) var hover_rand_max_time := 0.35


func _ready():
	set_process(false)

func _process(_delta: float):
	look_at(get_viewport().get_camera_3d().global_position)

func toggle(activate: bool):
	super.toggle(activate)
	set_process(activate)
	if activate and hover_anim:
		await get_tree().create_timer( \
			randf_range(0.1, hover_rand_max_time)).timeout
		anim.play("hover")
	else:
		anim.stop()
