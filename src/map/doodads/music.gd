extends AudioStreamPlayer
class_name MusicPlayer

@export var music_list: Array[AudioStream] = []
@export var player_in_order := false
var idx: int = 0

func _ready():
	if stream == null and not music_list.is_empty():
		set_music_stream()
	play()

func _on_finished():
	if not music_list.is_empty():
		set_music_stream()
	play()

func set_music_stream():
	if player_in_order:
		stream = music_list[idx]
		idx = (idx + 1) % music_list.size()
	else:
		stream = music_list.pick_random()
