extends CharacterState


func _init():
	type = CharacterStates.Type.DIE

func enter():
	super.enter()
	play_quip(true)
	locked = true

func _on_animation_tree_animation_finished(_anim_name: String):
	if active and character.npc:
		if character.drop != null and character.drop_percent > 0.0 \
		and character.drop_percent > randf():
			var item: Node3D = character.drop.instantiate()
			character.add_sibling(item)
			item.global_transform.origin = character.global_transform.origin
		character.queue_free()
