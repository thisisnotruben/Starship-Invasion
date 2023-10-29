extends Fsm

var anim_state_map := {}
@export var character: Character = null


func init(_states := {}, _state_args := {}) -> Fsm:
	var init_args := {} 
	for _state_type in _states:
		init_args[_state_type] = _states[_state_type][0]
		anim_state_map[_state_type] = _states[_state_type][1]
	super.init(init_args, _state_args)
	return self

func _set_state(_state_type):
	var prev_state_type = _curr["type"]
	
	if (_curr["state"] == null or not _curr["state"].locked) \
	and super._set_state(_state_type):
		
		if prev_state_type != -1:
			character.anim_tree["parameters/conditions/%s" \
				% anim_state_map[prev_state_type]] = false
		character.anim_tree["parameters/conditions/%s" \
			% anim_state_map[_state_type]] = true
		if not character.img.is_playing():
			character.img.play()
