extends VBoxContainer

signal back_pressed


func _on_back_pressed():
	emit_signal("back_pressed")

func _on_draw():
	$back.grab_focus()
