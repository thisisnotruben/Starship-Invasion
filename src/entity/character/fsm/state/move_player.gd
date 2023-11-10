extends IState

@onready var move: Move = get_parent()


func physics_process(delta: float):
	var input_dir := Input.get_vector("move_w", "move_e", "move_n", "move_s")
	var direction := (move.character.img.transform.basis \
		* Vector3(input_dir.x, 0.0, input_dir.y)).normalized()

	if move.character.is_on_floor():
		if direction:
			move.velocity.x = direction.x * move.speed
			move.velocity.z = direction.z * move.speed
		else:
			move.velocity.x = lerp(move.velocity.x, direction.x * move.speed, delta * 7.0)
			move.velocity.z = lerp(move.velocity.z, direction.z * move.speed, delta * 7.0)
	else:
		move.velocity.x = lerp(move.velocity.x, direction.x * move.speed, delta * 3.0)
		move.velocity.z = lerp(move.velocity.z, direction.z * move.speed, delta * 3.0)

	move.apply_animation(input_dir)
	move.apply_camera_movement(delta)
