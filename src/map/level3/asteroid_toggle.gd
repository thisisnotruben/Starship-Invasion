extends IToggleable

@export var anim: AnimationPlayer = null
@export var door: Door = null


func toggle(activate: bool):
	super.toggle(activate)
	if anim != null:
		anim.play("start")

func _on_asteroid_shooter_game_finished():
	if anim != null:
		anim.play("end")
	if door != null:
		door.toggle(true)
