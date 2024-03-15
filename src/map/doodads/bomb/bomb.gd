extends IToggleable

@onready var anim: AnimationPlayer = $anim
@onready var snd: AudioStreamPlayer3D = $snd

@onready var collisions: Array[CollisionShape3D] = \
	[$hull/body/StaticBody3D/CollisionShape3D, \
	$hull/antenna/StaticBody3D/CollisionShape3D, \
	$hull/grid/StaticBody3D/CollisionShape3D, \
	$glow/StaticBody3D/CollisionShape3D]


func toggle(activate: bool):
	super.toggle(activate)
	visible = activate
	collisions.map(func(c): \
		c.set_deferred("disabled", not activate))
	if activate:
		anim.play("glow")
		snd.play()
	else:
		anim.stop()
		snd.stop()
