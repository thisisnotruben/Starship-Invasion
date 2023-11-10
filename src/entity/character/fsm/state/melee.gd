extends CharacterState


func _init():
	type = CharacterStates.Type.MELEE

func enter():
	super.enter()
	play_quip()
	$timer.start()
	await $timer.timeout

	var hit_scan := character.hit_spawn.get_collider()
	if hit_scan is Character and character.is_foe(hit_scan):
		hit_scan.health -= character.melee_damage

	if not character.npc:
		emit_signal("change_state", CharacterStates.Type.IDLE)
