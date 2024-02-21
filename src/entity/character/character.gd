extends CharacterBody3D
class_name Character

@onready var img: AnimatedSprite3D = $img
@onready var body: CollisionShape3D = $body
@onready var snd: AudioStreamPlayer3D = $snd
@onready var snd_shoot: AudioStreamPlayer3D = $snd_shoot
@onready var hit_scan_melee: RayCast3D = $img/hit_cast_melee
@onready var hit_scan_shoot: RayCast3D = $img/hit_cast_shoot
@onready var camera: Camera3D = $img/pivot/springArm3D/camera3D
@onready var anim: AnimationPlayer = $animationPlayer
@onready var anim_tree: AnimationTree = $animationTree
@onready var fsm: Fsm = $fsm
@onready var behavior: Fsm = $fsm_behavior.init({
	BehaviorStates.Type.ATTACK: $fsm_behavior/attack,
	BehaviorStates.Type.REST: $fsm_behavior/rest}
	, {"character": self})

@export_range(1, 10) var health_max: int = 2
@export var npc = true: set = _set_npc
@export var friendly := false: set = _set_friendly

@export_category("Melee")
@export_range(1, 10) var melee_damage: int = 1
@export_range(0.0, 50.0) var melee_range: float = 1.1

@export_category("Shoot")
@export_range(1, 10) var range_damage: int = 1

@export_category("Player")
@export_range(0.0, 10.0) var jump_velocity: float = 5.0
var can_shoot := true
@export var nav_agent: NavigationAgent3D = null
@export var objective_map: ObjectiveMap = null
var objective_path := {"lines": [], "points": []}

@export_category("Npc")
@export_range(0.0, 50.0) var shoot_range: float = 12.0

@export_category("Items")
@export var inventory: Array[Item.Type] = []
@export var drop: PackedScene # `Item`
@export_range(0.0, 1.0, 0.05) var drop_percent := 0.2

var health: int : set = _set_health
var target: Character = null

signal health_changed(_health)
signal inventory_added(_item)
signal show_objective(_show, blurb)


func _ready():
	var fsm_init := {}
	for _state in $fsm.get_children():
		if _state.enabled:
			fsm_init[_state.type] = [_state, _state.name]
	$fsm.init(fsm_init, {"character": self})
	behavior.state = BehaviorStates.Type.REST
	hit_scan_melee.target_position.y = melee_range
	hit_scan_shoot.target_position.y = shoot_range
	health = health_max
	get_tree().get_nodes_in_group("npc" if npc else "player") \
		.map(func(c): hit_scan_melee.add_exception(c); \
			hit_scan_shoot.add_exception(c))
	get_tree().get_nodes_in_group("player" if npc else "npc") \
		.map(func(c): hit_scan_melee.remove_exception(c); \
			hit_scan_shoot.remove_exception(c))
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
		img.rotate_y(-event.relative.x * Settings.mouse_sens)
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
	if npc:
		set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
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

func inventory_add(data: Dictionary):
	if data["add"]:
		if not inventory.has(data["type"]):
			inventory.append(data["type"])
			emit_signal("inventory_added", data)
		for objective in objective_map.objectives:
			match objective["type"]:
				ObjectiveMap.Type.COLLECT, ObjectiveMap.Type.KILL_COLLECT:
					if objective["name"] == data["type"]:
						objective["completed"] = true
	else:
		if inventory.has(data["type"]):
			inventory.erase(data["type"])
			emit_signal("inventory_added", data)

func on_interacted(interacted_name: String):
	for objective in objective_map.objectives:
		if objective["type"] == ObjectiveMap.Type.INTERACT \
		and objective["name"] == interacted_name:
			objective["completed"] = true

func is_foe(_body: Node3D) -> bool:
	return _body is Character and _body.fsm.state != CharacterStates.Type.DIE \
	and (_body.friendly != friendly or (not _body.npc and not friendly))

# player behavior

func _handle_input():
	if npc:
		return

	img.rotate_y(Input.get_axis("camera_right", "camera_left") * Settings.joy_sens)

	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = jump_velocity

	var state := CharacterStates.Type.IDLE
	if Input.get_vector("move_e", "move_w", "move_s", "move_n").length() > 0.0:
		state = CharacterStates.Type.MOVE
		if Input.is_action_just_pressed("shoot"):
			state = CharacterStates.Type.MOVE_SHOOT
	elif Input.is_action_just_pressed("shoot"):
		if can_shoot:
			state = CharacterStates.Type.SHOOT
	elif Input.is_action_just_pressed("melee"):
		state = CharacterStates.Type.MELEE
	elif Input.is_action_just_pressed("show_objective"):
		draw_objective_path(true)
	elif Input.is_action_just_released("show_objective"):
		draw_objective_path(false)

	if state != CharacterStates.Type.IDLE:
		draw_objective_path(false)

	fsm.state = state

func draw_objective_path(_show: bool):
	if _show:
		var objective_vector := Vector3.ZERO
		if objective_map == null:
			return

		for objective in objective_map.objectives:
			if not objective["completed"]:
				var objective_node: Node3D = get_node_or_null("../../" + objective["path"])
				if objective_node == null and objective.has("path2"):
					objective_node = get_node_or_null("../../" + objective["path2"])
				if objective_node != null:
					objective_vector = objective_node.global_position
					emit_signal("show_objective", _show, objective["blurb"])
					break

		if objective_vector == Vector3.ZERO:
			return
		nav_agent.target_position = objective_vector
		if not nav_agent.is_target_reachable():
			return

		var path = nav_agent.get_current_navigation_path()
		var drawed_item: Node3D = null
		for i in path.size():
			path[i] = Vector3(path[i].x, 0.5, path[i].z)
			drawed_item = Draw.point(path[i], 0.05, Color.TURQUOISE)
			objective_path["points"].append(drawed_item)
			add_sibling(drawed_item)
			if i > 0:
				drawed_item = Draw.line(path[i - 1], path[i], Color.TURQUOISE)
				objective_path["lines"].append(drawed_item)
				add_sibling(drawed_item)
	else:
		emit_signal("show_objective", _show, "")
		for key in objective_path.keys():
			objective_path[key].map(func(d): d.queue_free())
			objective_path[key].clear()

# npc behavior

func _on_visibility_screen_entered():
	set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)

func _on_visibility_screen_exited():
	set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)

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
