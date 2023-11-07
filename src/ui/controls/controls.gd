extends VBoxContainer

signal back_pressed
signal subcontrol_focused


func _on_back_pressed():
	emit_signal("back_pressed")

func _on_draw():
	$back.grab_focus()

func _on_focus_entered():
	emit_signal("subcontrol_focused")
