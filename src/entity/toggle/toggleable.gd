extends Node3D
class_name IToggleable

var activated := false

signal toggled(_toggled)


func toggle(activate: bool):
	activated = activate
	emit_signal("toggled", activate)
