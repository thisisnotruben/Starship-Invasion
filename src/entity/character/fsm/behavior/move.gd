extends BehaviorState

@export var nav_agent: NavigationAgent3D = null
var move_to_pos := Vector3.ZERO


func enter():
	super.enter()
	if move_to_pos != Vector3.ZERO:
		nav_agent.target_position = move_to_pos
		if nav_agent.is_target_reachable():
			character.fsm.state = CharacterStates.Type.MOVE
		else:
			emit_signal("change_state", BehaviorStates.Type.ATTACK)
