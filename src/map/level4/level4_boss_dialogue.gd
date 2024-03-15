extends ITriggerable

@export var dialogue_menu: DialogueMenu = null
@export_range(-1, 10, 1) var dialogue_idx = -1

var passed_by := false


func trigger(_node: Node3D):
	if not passed_by and dialogue_menu != null and dialogue_idx != -1:
		dialogue_menu.start_dialogue(dialogue_idx)
		passed_by = true

func _on_body_entered(body: Node3D):
	if body is Character and not body.npc:
		trigger(body)
