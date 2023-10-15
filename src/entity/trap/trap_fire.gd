extends Trap


func toggle(activate: bool):
	super.toggle(activate)
	$img.play("start", 1.0, not activate)
	if activate:
		$img.show()
	
	await $img.animation_finished
	if activate:
		$img.play("fire")
	else:
		$img.hide()
