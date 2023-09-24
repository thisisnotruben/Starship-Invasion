extends CharacterState


func enter():
	character.anim_state_machine.travel("shoot")
