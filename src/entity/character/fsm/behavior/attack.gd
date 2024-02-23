extends BehaviorState

@export var nav_agent: NavigationAgent3D = null
@export var special_state: Special = null
@export_range(0.0, 1.0, 0.05) var special_chance := 0.5

@onready var melee_timer: Timer = $melee_cooldown
@onready var shoot_timer: Timer = $shoot_cooldown
@onready var special_timer: Timer = $special_cooldown

var state := -1
var distance := -1.0


func exit():
	super.exit()
	character.target = null

func process(_delta: float):
	if character.target == null \
	or character.target.fsm.state == CharacterStates.Type.DIE:
		emit_signal("change_state", BehaviorStates.Type.REST)
		return

	character.img.look_at(Vector3(character.target.global_position.x, \
		character.global_position.y, character.target.global_position.z))

	state = -1
	distance = snappedf(character.global_position.distance_to( \
		character.target.global_position), 0.01)

	# check if can special
	if special_state.enabled and special_state.is_valid_state() \
	and snappedf(randf_range(0.0, 1.0), 0.1) >= special_chance:
		if is_zero_approx(special_timer.time_left):
			state = CharacterStates.Type.SPECIAL

	# check if can melee
	elif character.fsm.can_melee() and (character.melee_range >= distance \
	or character.hit_scan_melee.get_collider() == character.target):
		if is_zero_approx(melee_timer.time_left):
			state = CharacterStates.Type.MELEE

	# check if can shoot
	elif character.fsm.can_shoot() and (character.shoot_range >= distance
	and character.hit_scan_shoot.get_collider() == character.target):
		if is_zero_approx(shoot_timer.time_left):
			state = CharacterStates.Type.SHOOT

	# otherwise move
	else:
		nav_agent.target_position = character.target.global_position
		if nav_agent.is_target_reachable():
			state = CharacterStates.Type.MOVE
		else:
			emit_signal("change_state", BehaviorStates.Type.REST)

	if state != -1 and character.fsm._set_state(state):
		match state:
			CharacterStates.Type.MELEE:
				melee_timer.start()
			CharacterStates.Type.SHOOT:
				shoot_timer.start()
			CharacterStates.Type.SPECIAL:
				special_timer.start()
