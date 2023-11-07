extends VBoxContainer

# value: yes|no
signal popup_return(value)
signal subcontrol_focused


func display(label: String, yes: String, no: String):
	$label.text = label
	$hBox/yes.text = yes 
	$hBox/no.text = no

func _on_yes_pressed():
	emit_signal("popup_return", "yes")

func _on_no_pressed():
	emit_signal("popup_return","no")

func _on_draw():
	$hBox/no.grab_focus()

func _on_focus_entered():
	emit_signal("subcontrol_focused")
