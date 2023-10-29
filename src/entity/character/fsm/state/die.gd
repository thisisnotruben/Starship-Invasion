extends CharacterState


func enter():
	super.enter()
	play_quip(true)
	locked = true

func _on_animation_tree_animation_finished(_anim_name: String):
	if active:
		character.queue_free()
