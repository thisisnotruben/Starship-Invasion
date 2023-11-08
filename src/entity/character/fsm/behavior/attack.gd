extends BehaviorState

@export var nav_agent: NavigationAgent3D = null


func enter():
	super.enter()
	character.fsm.state = CharacterStates.Type.IDLE

func process(_delta: float):
	if character.target != null:
		nav_agent.target_position = character.target.global_position
		if nav_agent.is_target_reachable():
			
			var state := -1
			var distance := character.global_position.distance_to( \
			character.target.global_position)
			
			if character.fsm.can_melee() and character.melee_range >= distance:
				state = CharacterStates.Type.MELEE
			elif character.fsm.can_shoot() and character.shoot_range >= distance:
				state = CharacterStates.Type.SHOOT
			else:
				state = CharacterStates.Type.MOVE
			
			if state != -1:
				character.fsm.state = state
		else:
			emit_signal("change_state", BehaviorStates.Type.REST)
