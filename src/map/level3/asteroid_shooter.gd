extends Node3D

const min_rot := deg_to_rad(-90.0)
const max_rot := deg_to_rad(90.0)

@onready var spawn_point_constraint: MeshInstance3D = $spawn_point_mesh
@onready var asteroid_timer: Timer = $asteroid_timer
@onready var game_timer: Timer = $game_timer
@export var cam: Camera3D = null
@export var anim: AnimationPlayer = null

@export_category("Turret")
@export var turrets: Array[AsteroidTurret] = []
@export var aim_length := 600
var turret_idx: int = 0
var current_aim_dir := Vector2.ZERO

@export_category("Asteroid")
@export var asteroids: Array[PackedScene] = []
@export_range(1.0, 4.0) var rand_asteroid_scale_limit = 2.0
@export_range(1, 6, 1) var sim_amount_max := 3
@export_range(0.5, 3.0) var spawn_min_sec := 2.0
@export_range(0.5, 5.0) var spawn_max_sec := 3.0

@export_category("hud feedback")
@export var hull_integrity: ProgressBar = null
@export var countdown_label: Label = null

@export_category("Orchestrator")
@export_range(60, 600.0, 1.0) var game_timer_sec := 60
@export_range(1, 20, 1) var max_hull_life: int = 10
@export var difficulty: Curve = null

var hull_life := -1
var game_done := false

signal game_started
signal game_finished
signal game_failed(health: int)
signal hull_hit


func _ready():
	$shake_cam.camera = cam
	set_physics_process(false)
	set_process_input(false)
	hull_life = max_hull_life

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		current_aim_dir = event.global_position
		update_turret_aim()

func _physics_process(_delta: float):
	for turret in turrets:
		turret.pivot.rotate_x(Input.get_axis("move_s", "move_n") * Settings.joy_sens)
		turret.pivot.rotate_y(Input.get_axis("move_e", "move_w") * Settings.joy_sens)
		turret.pivot.rotation.x = clamp(turret.pivot.rotation.x, min_rot, max_rot)
		turret.pivot.rotation.y = clamp(turret.pivot.rotation.y, min_rot, max_rot)
	if Input.is_action_just_pressed("shoot"):
		turrets[turret_idx].shoot()
		turret_idx = (turret_idx + 1) % turrets.size()
	if countdown_label != null:
		countdown_label.text = "%d:%02d" \
			% [floor(game_timer.time_left / 60), int(game_timer.time_left) % 60]

func start_game(start: bool = true, failed := false):
	set_physics_process(start)
	set_process_input(start)
	$space_background.fade(start)
	for turret in turrets:
		turret.set_physics_process(start)
		turret.rotate_gun = not start
	if start:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
		asteroid_timer.start(randf_range(spawn_min_sec, spawn_max_sec))
		game_timer.start(game_timer_sec)
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		asteroid_timer.stop()
		game_timer.stop()
	if not failed:
		emit_signal("game_started" if start else "game_finished")

func _on_asteroid_timer_timeout():
	asteroid_timer.start(randf_range(spawn_min_sec, spawn_max_sec))
	for i in range(sim_amount_max):
		spawn_asteroid()

func update_turret_aim():
	for turret in turrets:
		turret.pivot.look_at(cam.project_ray_origin(current_aim_dir) \
			+ cam.project_ray_normal(current_aim_dir) * aim_length)

func spawn_asteroid():
	var spawn_area := spawn_point_constraint.global_position
	var offest := Vector3(spawn_point_constraint.mesh.size.x,
		spawn_point_constraint.mesh.size.y, 0.0) / 2.0
	var min_spawn := spawn_area - offest
	var max_spawn := spawn_area + offest
	var rand_spawn := Vector3(randf_range(min_spawn.x, max_spawn.x), \
		randf_range(min_spawn.y, max_spawn.y), spawn_area.z)
	var vel_dir := spawn_area.direction_to(cam.global_position) \
		.normalized().ceil()
	asteroids.pick_random().instantiate().spawn( \
		{"parent": self, "spawn_pos": rand_spawn, "velocity_dir": vel_dir, \
		"scale": randf_range(1.0, rand_asteroid_scale_limit)})

func _on_game_timer_timeout():
	start_game(false)

func _on_space_hull_area_entered(area: Area3D):
	hull_life = clampi(hull_life - 1, 0, max_hull_life)
	if hull_integrity != null:
		hull_integrity.value = float(hull_life) / float(max_hull_life)
	if not game_done:
		if hull_life == 0:
			game_done = true
			emit_signal("game_failed", 0)
			emit_signal("game_finished")
			anim.play("death_cam")
			start_game(false, true)
		else:
			emit_signal("hull_hit")
			$shake_cam.shake(0.5, false)
	var node := area.owner
	if node is Asteroid:
		node.destroy()

func _on_dialogue_finished():
	$snd.play()
	start_game(true)
