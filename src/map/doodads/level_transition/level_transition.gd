extends Node3D

@export var next_level: PackedScene = null
@export_range(1, 4, 1) var level := 1

signal query_transiition(entered: bool, scene: PackedScene, level: int)


func _on_area_3d_body_entered(body: Node3D):
	if _is_player(body):
		emit_signal("query_transiition", true, next_level, level)

func _on_area_3d_body_exited(body: Node3D):
	if _is_player(body):
		emit_signal("query_transiition", false, next_level, level)

func _is_player(body: Node3D) -> bool:
	return body is Character and not body.npc
