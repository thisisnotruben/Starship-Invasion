extends BehaviorState

@export var nav_agent: NavigationAgent3D = null
@onready var melee_timer: Timer = $melee_cooldown
@onready var shoot_timer: Timer = $shoot_cooldown

var state := -1
var attacking := false
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
	attacking = false
	distance = snappedf(character.global_position.distance_to( \
		character.target.global_position), 0.01)

	if character.fsm.can_melee() and (character.melee_range >= distance \
	or character.hit_scan_melee.get_collider() == character.target):
		attacking = true
		if is_zero_approx(melee_timer.time_left):
			state = CharacterStates.Type.MELEE
	elif character.fsm.can_shoot() and (character.shoot_range >= distance
	and character.hit_scan_shoot.get_collider() == character.target):
		attacking = true
		if is_zero_approx(shoot_timer.time_left):
			state = CharacterStates.Type.SHOOT
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
