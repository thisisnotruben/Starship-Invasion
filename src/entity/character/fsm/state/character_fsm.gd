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

func _set_state(_state_type) -> bool:
	var prev_state_type = _curr["type"]

	if (_curr["state"] == null or not _curr["state"].locked) \
	and super._set_state(_state_type):

		if prev_state_type != -1:
			var prev_condition_anim: String = "parameters/conditions/%s" \
				% anim_state_map[prev_state_type]
			if character.anim_tree.get(prev_condition_anim) != null:
				character.anim_tree[prev_condition_anim] = false

		var condition_anim: String = "parameters/conditions/%s" \
			% anim_state_map[_state_type]
		if character.anim_tree.get(condition_anim) != null:
			character.anim_tree[condition_anim] = true

		var blend_pos: String = "parameters/%s/blend_position" \
			% anim_state_map[_state_type]
		if character.anim_tree.get(blend_pos) != null:
			var flip: Vector2 = character.anim_tree[blend_pos]
			match anim_state_map[_state_type]:
				"shoot", "move-shoot", "melee":
					flip = Vector2.UP if character.npc else Vector2.DOWN
				_:
					if flip == Vector2.ZERO:
						flip = Vector2.UP if character.npc else Vector2.DOWN
					else:
						flip.y *= -1.0
			character.anim_tree[blend_pos] = flip

		if not character.img.is_playing():
			character.img.play()
		return true
	return false

func can_melee() -> bool:
	return states.has(CharacterStates.Type.MELEE)

func can_shoot() -> bool:
	return states.has_all([CharacterStates.Type.SHOOT, \
		CharacterStates.Type.MOVE_SHOOT])
