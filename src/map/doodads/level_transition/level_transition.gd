extends Node3D

@export var next_level: PackedScene = null
@export_range(1, 4, 1) var level := 1
@export_range(-1, 10, 1) var dialogue_idx: int = -1

signal query_transiition(scene: PackedScene, level: int)


func _on_area_3d_body_entered(body: Node3D):
	if body is Character and not body.npc:
		emit_signal("query_transiition", next_level, level, dialogue_idx)
