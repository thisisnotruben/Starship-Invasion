extends CharacterState


func _init():
	type = CharacterStates.Type.DIE

func enter():
	super.enter()
	play_quip(true)
	locked = true

func _on_animation_tree_animation_finished(_anim_name: String):
	if active and character.npc:
		character.queue_free()
