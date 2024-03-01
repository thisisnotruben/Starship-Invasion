extends StaticBody3D

@onready var snd: AudioStreamPlayer3D = $snd
@onready var visibility: VisibleOnScreenEnabler3D = $visibility

@export_category("Audio")
@export var snd_library: Array[AudioStream] = []
@export var rand := false
@export_category("Light")
@export var lights: Array[Light3D] = []
@export var look_at_node: Node3D = null

var play_snd := false


func _ready():
	set_process(false)
	play_snd = not rand or (rand and randi_range(0, 1) == 1)
	if snd.stream == null and not snd_library.is_empty():
		snd.stream = snd_library.pick_random()

func _on_snd_finished():
	if not snd_library.is_empty():
		snd.stream = snd_library.pick_random()
	if play_snd and visibility.is_on_screen():
		snd.play()

func _on_visibility_screen_entered():
	if play_snd:
		snd.play()
	if _is_valid():
		set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
		set_process(true)

func _on_visibility_screen_exited():
	snd.stop()
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
