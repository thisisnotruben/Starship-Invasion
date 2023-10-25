extends CharacterState


func enter():
	super.enter()
	play_quip()
	character.anim_tree["parameters/melee/blend_position"] = \
		Vector2.UP if character.npc else Vector2.DOWN

func _on_animation_tree_animation_finished(_anim_name: String):
	if active:
		
		var hit_scan := character.hit_spawn.get_collider()
		if hit_scan is Character and character.is_foe(hit_scan):
			hit_scan.health -= character.melee_damage
		
		if not character.npc:
			emit_signal("change_state", CharacterStates.Type.IDLE)
