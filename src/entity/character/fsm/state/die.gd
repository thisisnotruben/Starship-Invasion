extends CharacterState


func _on_animation_tree_animation_finished(anim_name: String):
	if active and anim_name == "die":
		character.queue_free()
