extends IToggleable

@export var checkpoint: Checkpoint = null
@export var dialogue_menu: DialogueMenu = null


func toggle(activate: bool):
	super.toggle(activate)
	checkpoint.disabled = true
	dialogue_menu.emit_dialogue_finished_signal = true
	get_tree().call_group("celestial", "toggle", activate)
