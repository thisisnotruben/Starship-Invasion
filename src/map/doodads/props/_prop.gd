extends StaticBody3D

@onready var snd: AudioStreamPlayer3D = $snd

@export_category("Audio")
@export var snd_library: Array[AudioStream] = []
@export var rand := false
@export_category("Light")
@export var lights: Array[Light3D] = []
@export var look_at_node: Node3D = null


func _ready():
	if snd.stream == null and not snd_library.is_empty():
		snd.stream = snd_library.pick_random()
	if not rand or (rand and randi_range(0, 1) == 1):
		snd.play()
	set_process($visibility.is_on_screen() and _is_valid())

func _on_snd_finished():
	if not snd_library.is_empty():
		snd.stream = snd_library.pick_random()
	snd.play()

func _on_visibility_screen_entered():
	if _is_valid():
		set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
		set_process(true)

func _on_visibility_screen_exited():
	if _is_valid():
		set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
		set_process(false)

func _process(_delta: float):
	if _is_valid():
		for light in lights:
			light.look_at(look_at_node.global_position)
	else:
		set_process(false)

func _is_valid() -> bool:
	return look_at_node != null and not lights.is_empty()
