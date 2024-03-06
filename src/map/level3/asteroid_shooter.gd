extends Node3D

@onready var spawn_point_constraint: MeshInstance3D = $spawn_point_mesh
@onready var asteroid_timer: Timer = $asteroid_timer
@onready var game_timer: Timer = $game_timer
@export var cam: Camera3D = null
@export var anim: AnimationPlayer = null
@onready var _anim: AnimationPlayer = $anim
@onready var aim_cursor: Marker3D = $aim_cursor

@export_category("Turret")
@export var turrets: Array[AsteroidTurret] = []
@export var aim_length := 600
@export_range(100.0, 1000.0) var turret_aim_speed :=  580.0
var turret_idx: int = 0

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
var screen_size := Vector2( \
	ProjectSettings.get("display/window/size/viewport_width"), \
	ProjectSettings.get("display/window/size/viewport_height"))

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
		update_turret_aim(project_aim(event.global_position))

func _physics_process(delta: float):
	var input_dir := Input.get_vector("move_w", "move_e", "move_n", "move_s")
	if not input_dir.is_zero_approx():
		var target_pos = (Vector2(aim_cursor.global_position.x, \
			aim_cursor.global_position.y) + input_dir.normalized() \
			* turret_aim_speed * delta).clamp(Vector2.ZERO, screen_size)
		aim_cursor.global_position.x = target_pos.x
		aim_cursor.global_position.y = target_pos.y
		update_turret_aim(project_aim(target_pos))

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
		var start_cursor_pos = project_aim(screen_size / 2.0)
		aim_cursor.global_position.z = start_cursor_pos.z
		update_turret_aim(start_cursor_pos)
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		asteroid_timer.stop()
		game_timer.stop()
		get_tree().get_nodes_in_group("asteroid").map(func(a): a.queue_free())
	if not failed:
		emit_signal("game_started" if start else "game_finished")

func _on_asteroid_timer_timeout():
	asteroid_timer.start(randf_range(spawn_min_sec, spawn_max_sec))
	for i in range(sim_amount_max):
		spawn_asteroid()

func project_aim(pos: Vector2) -> Vector3:
	return cam.project_ray_origin(pos) + cam.project_ray_normal(pos) * aim_length

func update_turret_aim(aim_to: Vector3):
	for turret in turrets:
		turret.pivot.look_at(aim_to)

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
	_anim.play("end_win")

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
			_anim.play("end_failed")
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
