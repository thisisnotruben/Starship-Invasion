extends Area3D

@export var spawn1: Spawn = null
@export var spawn2: Spawn = null


func _on_body_entered(body: Node3D):
	if _is_player(body):
		spawn1.disabled = false
		spawn2.disabled = false
		spawn1.toggle(true)
		spawn2.toggle(true)

func _on_body_exited(body: Node3D):
	if _is_player(body):
		spawn1.disabled = true
		spawn2.disabled = true

func _is_player(body: Node3D):
	return body is Character and not body.npc
