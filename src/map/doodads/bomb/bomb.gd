extends IToggleable

@onready var anim: AnimationPlayer = $anim
@onready var snd: AudioStreamPlayer3D = $snd

@export var csg_shapes: Array[CSGShape3D] = []


func toggle(activate: bool):
	super.toggle(activate)
	visible = activate
	for shape in csg_shapes:
		shape.use_collision = activate
	if activate:
		anim.play()
		snd.play()
	else:
		anim.stop()
		snd.stop()
