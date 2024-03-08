extends IToggleable


func toggle(activate: bool):
	super.toggle(activate)

	for node in $explode.get_children():
		if node is IToggleable:
			node.toggle(activate)

	if activate:
		await get_tree().create_timer(1.5).timeout
		$explode/GPUParticles3D.emitting = true
		$snd.play()
		await get_tree().create_timer(1.25).timeout
		hide()
	else:
		show()
