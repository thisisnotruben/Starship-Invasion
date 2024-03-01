extends Node3D


func _on_space_sound_area_body_entered(body: Node3D):
	if _is_player(body):
		$space_sound.fade(true)

func _on_space_sound_area_body_exited(body: Node3D):
	if _is_player(body):
		$space_sound.fade(false)

func _is_player(body: Node3D) -> bool:
	return body is Character and not body.npc
