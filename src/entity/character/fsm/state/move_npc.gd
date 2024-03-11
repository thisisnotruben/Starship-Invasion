extends IState

@onready var move: Move = get_parent()
@export var nav_agent: NavigationAgent3D = null


func _ready():
	if nav_agent != null:
		nav_agent.max_speed = move.speed

func physics_process(_delta: float):
	if not nav_agent.is_target_reachable() or nav_agent.is_target_reached():
		move.emit_signal("change_state", CharacterStates.Type.IDLE)
		return

	var next_point := nav_agent.get_next_path_position()
	var direction := move.character.global_position.direction_to(next_point)

	if direction:
		move.velocity.x = direction.x * move.speed
		move.velocity.z = direction.z * move.speed

	if move.character.global_position.distance_to(next_point) \
	>= nav_agent.target_desired_distance:
		move.character.img.look_at(Vector3(next_point.x, \
			move.character.global_position.y, next_point.z), Vector3.UP)
	else:
		move.emit_signal("change_state", CharacterStates.Type.IDLE)
