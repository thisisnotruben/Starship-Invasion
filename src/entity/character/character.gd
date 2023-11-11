extends CharacterBody3D
class_name Character

@onready var img: AnimatedSprite3D = $img
@onready var body: CollisionShape3D = $body
@onready var snd: AudioStreamPlayer3D = $snd
@onready var snd_shoot: AudioStreamPlayer3D = $snd_shoot
@onready var hit_spawn: RayCast3D = $img/hit_cast
@onready var camera: Camera3D = $img/pivot/springArm3D/camera3D
@onready var anim_tree: AnimationTree = $animationTree
@onready var anim_state_machine: AnimationNodeStateMachinePlayback \
	= anim_tree["parameters/playback"]
@onready var fsm: Fsm = $fsm
@onready var behavior: Fsm = $fsm_behavior.init({
	BehaviorStates.Type.ATTACK: $fsm_behavior/attack,
	BehaviorStates.Type.REST: $fsm_behavior/rest}
	, {"character": self})

@export_range(1, 10) var health_max: int = 2
@export var npc = true: set = _set_npc
@export var friendly := false: set = _set_friendly

@export_subgroup("Melee")
@export_range(1, 10) var melee_damage: int = 1
@export_range(0.0, 50.0) var melee_range: float = 1.0

@export_subgroup("Shoot")
@export_range(1, 10) var range_damage: int = 1

@export_subgroup("Player")
@export_range(0.0, 1.0) var cam_sens_mouse := 0.004
@export_range(0.0, 5.0) var cam_sens_action := 0.04
@export_range(0.0, 10.0) var jump_velocity: float = 5.0
@export_subgroup("Npc")
@export_range(0.0, 50.0) var shoot_range: float = 5.0

var health: int : set = _set_health
var target: Character = null

signal health_changed(_health)


func _ready():
	var fsm_init := {}
	for _state in $fsm.get_children():
		if _state.enabled:
			fsm_init[_state.type] = [_state, _state.name]
	$fsm.init(fsm_init, {"character": self})
	behavior.state = BehaviorStates.Type.REST
	hit_spawn.target_position.y = melee_range
	health = health_max
	get_tree().get_nodes_in_group("npc" if npc else "player") \
		.map(func(c): hit_spawn.add_exception(c))
	get_tree().get_nodes_in_group("player" if npc else "npc") \
		.map(func(c): hit_spawn.remove_exception(c))
	_set_npc(npc)

func _on_nav_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity

func _physics_process(delta: float):
	behavior.physics_process(delta)
	fsm.physics_process(delta)
	move_and_slide()

func _process(delta: float):
	_handle_input()
	behavior.process(delta)
	fsm.process(delta)

func _input(event: InputEvent):
	if not npc and event is InputEventMouseMotion:
		img.rotate_y(-event.relative.x * cam_sens_mouse)
	fsm.input(event)

func _set_health(_health: int):
	health = clampi(_health, 0, health_max)
	if health >= 0 and fsm.state != CharacterStates.Type.DIE:
		emit_signal("health_changed", health)
	if health == 0:
		fsm.state = CharacterStates.Type.DIE
		set_physics_process(false)
		set_process_input(false)
		set_process(false)

func _set_npc(_npc: bool):
	npc = _npc
	$img/pivot/springArm3D/camera3D.current = !_npc
	$img/spotLight3D.visible = !_npc
	$navigationAgent3D.avoidance_enabled = _npc
	remove_from_group("player" if _npc else "npc")
	add_to_group("npc" if _npc else "player")
	_set_friendly(friendly)

func _set_friendly(_friendly: bool):
	friendly = _friendly
	if npc:
		if _friendly:
			remove_from_group("foe")
			add_to_group("friendly")
		else:
			remove_from_group("friendly")
			add_to_group("foe")
	else:
		add_to_group("friendly")

func is_foe(_body: Node3D) -> bool:
	return _body is Character and _body.fsm.state != CharacterStates.Type.DIE \
	and (_body.friendly != friendly or (not _body.npc and not friendly))

# player behavior

func _handle_input():
	if npc:
		return

	img.rotate_y(Input.get_axis("camera_right", "camera_left") * \
		cam_sens_action)

	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = jump_velocity

	var state := CharacterStates.Type.IDLE
	if Input.get_vector("move_e", "move_w", "move_s", "move_n").length() > 0.0:
		state = CharacterStates.Type.MOVE
		if Input.is_action_just_pressed("shoot"):
			state = CharacterStates.Type.MOVE_SHOOT
	elif Input.is_action_just_pressed("shoot"):
		state = CharacterStates.Type.SHOOT
	elif Input.is_action_just_pressed("melee"):
		state = CharacterStates.Type.MELEE

	fsm.state = state

# npc behavior

func _on_sight_body_entered(_body: Node3D):
	if not aggro(_body) \
	and $fsm_behavior.state == BehaviorStates.Type.ATTACK \
	and _body.target == null:
		_body.aggro(target)

func _on_sight_area_entered(area: Node3D):
	if npc and target == null and area.owner is Bullet \
	and area.owner.from_character != null:
		aggro(area.owner.from_character)

func aggro(_body: Node3D) -> bool:
	if npc and is_foe(_body):
		target = _body
		behavior.state = BehaviorStates.Type.ATTACK
		$sight.get_overlapping_bodies() \
			.filter(func(b): return \
				b != self and not is_foe(b) and b.target == null) \
			.map(func(c): c.aggro(target))
		return true
	return false
