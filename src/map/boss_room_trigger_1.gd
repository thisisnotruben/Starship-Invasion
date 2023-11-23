extends Area3D

@export var marker: Marker3D = null
var target: Character = null


func _on_body_entered(body: Node3D):
	if body is Character and not body.npc:
		target = body
		set_process(true)
		get_tree().call_group("boss_room_2", "toggle", true)
		get_tree().call_group("boss_room_2", "aggro", body)

func _on_body_exited(body: Node3D):
	if body == target:
		target = null

func _process(_delta: float):
	if target != null:
		marker.global_position = target.global_position
	else:
		set_process(false)
