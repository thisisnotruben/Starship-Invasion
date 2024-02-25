extends BehaviorState

@export var nav_agent: NavigationAgent3D = null
var move_to_pos := Vector3.ZERO


func enter():
	super.enter()
	character.fsm.state = CharacterStates.Type.IDLE

	if move_to_pos != Vector3.ZERO:
		nav_agent.target_position = move_to_pos
		if not nav_agent.is_target_reachable():
			emit_signal("change_state", BehaviorStates.Type.ATTACK)
		else:
			character.fsm._set_state(CharacterStates.Type.MOVE)
