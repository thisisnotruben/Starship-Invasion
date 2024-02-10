extends BehaviorState

@export var nav_agent: NavigationAgent3D = null
@onready var melee_timer: Timer = $melee_cooldown
@onready var shoot_timer: Timer = $shoot_cooldown


func exit():
	super.exit()
	character.target = null

func process(_delta: float):
	if character.target == null \
	or character.target.fsm.state == CharacterStates.Type.DIE:
		emit_signal("change_state", BehaviorStates.Type.REST)
		return

	nav_agent.target_position = character.target.global_position
	if not nav_agent.is_target_reachable():
		emit_signal("change_state", BehaviorStates.Type.REST)
		return

	var state := -1
	var distance := snappedf(character.global_position.distance_to( \
		character.target.global_position), 0.01)

	if character.fsm.can_melee() and (character.melee_range >= distance \
	or character.hit_scan_melee.get_collider() == character.target):
		if melee_timer.time_left == 0:
			state = CharacterStates.Type.MELEE
			look_at_target()
	elif character.fsm.can_shoot() and (character.shoot_range >= distance \
		and character.hit_scan_shoot.get_collider() == character.target):
		if shoot_timer.time_left == 0:
			state = CharacterStates.Type.SHOOT
			look_at_target()
	else:
		state = CharacterStates.Type.MOVE

	if state != -1 and character.fsm._set_state(state):
		match state:
			CharacterStates.Type.MELEE:
				melee_timer.start()
			CharacterStates.Type.SHOOT:
				shoot_timer.start()

func look_at_target():
	character.img.look_at(Vector3(character.target.global_position.x, \
		character.global_position.y, character.target.global_position.z))
