extends IToggleable

@export var checkpoint: Checkpoint = null


func toggle(activate: bool):
	super.toggle(activate)
	checkpoint.disabled = true
	get_tree().call_group("celestial", "toggle", activate)
