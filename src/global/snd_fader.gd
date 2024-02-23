extends Node
class_name AudioFader

const min_snd_volume := -80.0

@export var snd: Node
@export_range(0.5, 5.0) var fade_time := 2.0


func fade(play: bool):
	var tween := get_tree().create_tween()

	if play:
		snd.volume_db = min_snd_volume
		snd.play()
		tween.tween_property(snd, "volume_db", \
			AudioServer.get_bus_volume_db( \
				AudioServer.get_bus_index(snd.bus)),
			fade_time)
	else:
		tween.tween_property(snd, "volume_db", min_snd_volume, fade_time)
		await tween.finished
		snd.stop()
