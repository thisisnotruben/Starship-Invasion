extends Trap

# TODO: 
#	- add particles and light for electricity visuals
#	- toggle those values to show here

func toggle(activate: bool):
	super.toggle(activate)
	$gPUParticles3D.emitting = activate
