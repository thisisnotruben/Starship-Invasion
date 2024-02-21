extends Trap


func toggle(activate: bool):
	super.toggle(activate)
	img.visible = activate
	img.play()
