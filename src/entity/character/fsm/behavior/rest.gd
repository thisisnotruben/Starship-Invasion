extends BehaviorState


func enter():
	super.enter()
	character.fsm.state = CharacterStates.Type.IDLE
