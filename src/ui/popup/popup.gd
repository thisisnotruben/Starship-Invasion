extends VBoxContainer

var play_focus_sfx := false

# value: yes|no
signal popup_return(value)
signal subcontrol_focused


func display(label: String, yes: String, no: String):
	$label.text = label
	$hBox/yes.text = "  %s  " % yes
	$hBox/no.text = "  %s  " % no

func _on_yes_pressed():
	emit_signal("popup_return", "yes")

func _on_no_pressed():
	emit_signal("popup_return","no")

func _on_draw():
	play_focus_sfx = false
	$hBox/no.grab_focus()
	play_focus_sfx = true

func _on_focus_entered():
	if play_focus_sfx:
		emit_signal("subcontrol_focused")
