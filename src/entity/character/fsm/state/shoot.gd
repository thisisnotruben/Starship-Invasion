extends CharacterState

@export var bullet_scene: PackedScene


func _init():
	type = CharacterStates.Type.SHOOT

func enter():
	super.enter()
	play_quip()
	bullet_scene.instantiate().spawn_shot({"character": character})

func _on_animation_tree_animation_finished(_anim_name: String):
	if active:
		emit_signal("change_state", CharacterStates.Type.IDLE)
