extends Node

@export var player: Character = null
var in_safe_zone := false

@export_group("Oxygen")
@export_range(0.0, 120.0) var oxygen_sec_max := 120.0
@export var o2_progress_bar: ProgressBar = null

@export_group("Asteroids")
@export var asteroid_parent: Node3D = null
@export_range(0.0, 24.0) var asteroid_timer_max := 12.0
@export_range(0.0, 24.0) var asteroid_timer_min := 6.0
@export_range(0.0, 1.0) var asteroid_indicator_per := 0.8

@export_group("Spawns")
@export var spawns: Array[Spawn] = []


@onready var o2_timer: Timer = $oxygen_timer

signal on_show_o2_timer(visible)


func _ready():
	set_physics_process(false)

func _physics_process(_delta: float):
	if o2_progress_bar != null:
		o2_progress_bar.value = o2_timer.time_left / oxygen_sec_max
	else:
		set_physics_process(false)

func _on_oxygen_timer_timeout():
	if player != null:
		player.health = 0

func _on_asteroid_timer_timeout():
	asteroid_parent.get_children().map(func(p): p.emitting = true)
	if not in_safe_zone and player != null:
		player.health = 0
	_start_asteroid_timer()

func _on_asteroid_indicator_timer_timeout():
	$snd.play()

func _on_area_3d_body_entered(body: Node3D):
	if _is_player(body):
		emit_signal("on_show_o2_timer", true)
		o2_timer.start(oxygen_sec_max)
		_start_asteroid_timer()
		spawns.map(func(t): t.toggle(true))
		set_physics_process(true)

func _on_area_3d_body_exited(body: Node3D):
	if _is_player(body):
		emit_signal("on_show_o2_timer", false)
		o2_timer.stop()
		$asteroid_indicator_timer.stop()
		$asteroid_timer.stop()
		spawns.map(func(t): t.toggle(false))
		set_physics_process(false)

func _on_safe_zone_body_entered(body: Node3D):
	if body == player:
		in_safe_zone = true

func _on_safe_zone_body_exited(body: Node3D):
	if body == player:
		in_safe_zone = false

func _is_player(body: Node3D) -> bool:
	return body is Character and not body.npc

func _start_asteroid_timer():
	var new_asteroid_time := randf_range(asteroid_timer_min, asteroid_timer_max)
	$asteroid_indicator_timer.start(new_asteroid_time * asteroid_indicator_per)
	$asteroid_timer.start(new_asteroid_time)
