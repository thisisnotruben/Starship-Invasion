extends StaticBody3D

@onready var snd: AudioStreamPlayer3D = $snd

@export_category("Audio")
@export var snd_library: Array[AudioStream] = []
@export var rand := false
@export_category("Light")
@export var lights: Array[Light3D] = []
@export var character: Character = null


func _ready():
	if snd.stream == null and not snd_library.is_empty():
		snd.stream = snd_library.pick_random()
	if not rand or (rand and randi_range(0, 1) == 1):
		snd.play()
	if character == null:
		for unit in get_tree().get_nodes_in_group("character"):
			if not unit.npc:
				character = unit
				break
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
			light.look_at(character.global_position)
	else:
		set_process(false)

func _is_valid() -> bool:
	return character != null or not lights.is_empty()
