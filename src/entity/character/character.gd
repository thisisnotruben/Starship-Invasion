extends CharacterBody3D
class_name Character

@onready var img: AnimatedSprite3D = $img
@onready var snd: AudioStreamPlayer3D = $snd
@onready var snd_shoot: AudioStreamPlayer3D = $snd_shoot
@onready var hit_spawn: RayCast3D = $img/rayCast3D
@onready var camera: Camera3D = $img/pivot/springArm3D/camera3D
@onready var anim_tree: AnimationTree = $animationTree
@onready var anim_state_machine: AnimationNodeStateMachinePlayback \
	= anim_tree["parameters/playback"]
@onready var fsm: Fsm = $fsm.init({
	CharacterStates.Type.IDLE: [$fsm/idle, "idle"],
	CharacterStates.Type.MOVE: [$fsm/move, "move"],
	CharacterStates.Type.MOVE_SHOOT: [$fsm/move_shoot, "move-shoot"],
	CharacterStates.Type.SHOOT: [$fsm/shoot, "shoot"],
	CharacterStates.Type.MELEE: [$fsm/melee, "melee"],
	CharacterStates.Type.DIE: [$fsm/die, "die"]}
	, {"character": self})
@onready var behavior: Fsm = $fsm_behavior.init({
	BehaviorStates.Type.ATTACK: $fsm_behavior/attack,
	BehaviorStates.Type.REST: $fsm_behavior/rest}
	, {"character": self})

@export_range(1, 10) var health_max: int = 2
@export var npc = true: set = _set_npc
@export var friendly := false: set = _set_friendly
@export_subgroup("Melee")
@export_range(1, 10) var melee_damage: int = 1
@export_range(0.0, 50.0) var melee_range: float = 2.5
@export_subgroup("Shoot")
@export_range(1, 10) var range_damage: int = 1
@export_subgroup("Player")
@export_range(0.0, 1.0) var cam_sens_mouse := 0.004
@export_range(0.0, 5.0) var cam_sens_action := 0.04
@export_range(0.0, 10.0) var jump_velocity: float = 5.0
@export_subgroup("Npc")
@export_range(0.0, 50.0) var shoot_range: float = 5.0

var health: int = health_max: set = _set_health
var target: Character = null


func _ready():
	behavior.state = BehaviorStates.Type.REST

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
	health = _health
	health = clampi(health, 0, health_max)
	if health == 0:
		fsm.state = CharacterStates.Type.DIE

func _set_npc(_npc: bool):
	npc = _npc
	$img/pivot/springArm3D/camera3D.current = !_npc
	if _npc:
		remove_from_group("player")
		add_to_group("npc")
	else:
		remove_from_group("npc")
		add_to_group("player")
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

func _on_area_3d_body_entered(body: Node3D):
	if npc and body is Character and is_foe(body) \
	and body.fsm.state != CharacterStates.Type.DIE:
		target = body
		behavior.state = BehaviorStates.Type.ATTACK

func is_foe(character: Character) -> bool:
	return character.friendly != friendly \
	or (not character.npc and not friendly)
