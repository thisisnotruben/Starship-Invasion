extends VBoxContainer

signal back_pressed
signal subcontrol_focused


func _on_back_pressed():
	emit_signal("back_pressed")

func _on_draw():
	$back.grab_focus()

func _on_redirect_pressed():
	$snd.play()
	await $snd.finished
	OS.shell_open("https://github.com/thisisnotruben/Overmind/blob/main/LICENSE.md")

func _on_focus_entered():
	emit_signal("subcontrol_focused")
