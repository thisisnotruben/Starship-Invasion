extends IToggleable

@onready var particles: GPUParticles3D = $particles
@onready var snd: AudioStreamPlayer = $snd
@export var snd_library: Array[AudioStream] = []


func toggle(activate: bool):
	super.toggle(activate)
	particles.emitting = activate
	if activate:
		snd.stream = snd_library.pick_random()
		snd.play()
	else:
		snd.stop()
