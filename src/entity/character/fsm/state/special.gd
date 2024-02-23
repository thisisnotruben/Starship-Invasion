extends CharacterState
class_name Special


func _init():
	type = CharacterStates.Type.SPECIAL

func enter():
	super.enter()
	play_quip(true)

func is_valid_state() -> bool:
	return false
