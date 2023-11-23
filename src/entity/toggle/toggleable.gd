extends Node3D
class_name IToggleable

signal toggled(_toggled)


func toggle(activate: bool):
	emit_signal("toggled", activate)
