extends AudioStreamPlayer

@export var music_list: Array[AudioStream] = []


func _ready():
	if stream == null and not music_list.is_empty():
		stream = music_list.pick_random()
	play()

func _on_finished():
	if not music_list.is_empty():
		stream = music_list.pick_random()
	play()
