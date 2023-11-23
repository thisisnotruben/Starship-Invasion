extends AudioStreamPlayer

@export var music_list: Array[AudioStream] = []


func _on_finished():
	if music_list.is_empty():
		play()
	else:
		stream = music_list.pick_random()
		play()
