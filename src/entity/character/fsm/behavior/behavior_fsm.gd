extends Fsm

var character: Character = null


func init(_states := {}, _state_args := {}) -> Fsm:
	super.init(_states, _state_args)
	character = _state_args["character"]
	return self

func _set_state(_state_type) -> bool:
	if super._set_state(_state_type):
		if character.npc:
			character.set_performance_process(not \
				states[_state_type].need_physics_process)
		return true
	return false
