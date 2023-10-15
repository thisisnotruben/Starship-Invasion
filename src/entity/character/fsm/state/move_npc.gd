extends IState

@onready var move: Move = get_parent()
@export var nav_agent: NavigationAgent3D = null


func physics_process(_delta: float):
	if not nav_agent.is_target_reachable() \
	or nav_agent.is_target_reached():
		return

	var next_point := nav_agent.get_next_path_position()
	var direction := move.character.global_position.direction_to(next_point)
	
	if direction:
		move.velocity.x = direction.x * move.speed
		move.velocity.z = direction.z * move.speed
		
	move.character.img.look_at(Vector3(next_point.x, \
		move.character.global_position.y, next_point.z), Vector3.UP)
	
	move.apply_animation(Vector2(direction.x, direction.z))
