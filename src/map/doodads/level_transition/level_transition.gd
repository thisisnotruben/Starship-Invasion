extends Node3D

@export var next_level: PackedScene = null

signal query_transiition(entered: bool, scene: PackedScene)


func _on_area_3d_body_entered(body: Node3D):
	if _is_player(body):
		emit_signal("query_transiition", true, next_level)

func _on_area_3d_body_exited(body: Node3D):
	if _is_player(body):
		emit_signal("query_transiition", false, next_level)

func _is_player(body: Node3D) -> bool:
	return body is Character and not body.npc
