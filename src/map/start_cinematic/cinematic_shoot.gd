extends Node3D

@export var target: Node3D = null
@export var bullet_scene: PackedScene = null


func shoot():
	bullet_scene.instantiate().spawn_shot({"parent": self, \
		"origin": global_position, "target": target.global_position})
