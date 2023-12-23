extends IToggleable

@export var door_int: IToggleable = null
@export var door_ext: IToggleable = null


func toggle(activate: bool):
	super.toggle(activate)
	door_ext.toggle(not door_ext.activated)
	door_int.toggle(not door_int.activated)
