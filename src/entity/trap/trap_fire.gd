extends Trap


func toggle(activate: bool):
	super.toggle(activate)
	if activate:
		$img.play("start")
	else:
		$img.play_backwards("start")

	await $img.animation_finished
	if activate:
		$img.play("fire")
