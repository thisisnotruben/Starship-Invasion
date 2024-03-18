extends IToggleable

@export var space_celestials: Node3D = null


func _on_body_entered(body: Node3D):
	if body is Character and not body.npc:
		toggle(true)

func _on_body_exited(body: Node3D):
	if body is Character and not body.npc:
		toggle(false)

func toggle(activate: bool):
	super.toggle(activate)
	get_tree().call_group("celestial", "toggle", activate)
	space_celestials.visible = activate
