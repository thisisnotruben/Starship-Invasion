extends Node

@export_group("Asteroids")
@export_range(3.0, 24.0) var asteroid_timer_min := 8.0
@export_range(3.0, 24.0) var asteroid_timer_max := 12.0
@export var alert_heads_up: float = 3.0

@onready var camera_shake: Node = $camera_shake
@onready var asteroid_timer: Timer = $asteroid_timer
@onready var asteroid_visual: GPUParticles3D = $asteroid/asteroids
@onready var asteroid_indicator_timer: Timer = $asteroid_indicator_timer
@onready var hit_box: Area3D = $area3D

var in_safe_zone := []

signal on_alert(duration: float, impact: bool)


func _on_asteroid_indicator_timer_timeout():
	camera_shake.shake(0.5)
	emit_signal("on_alert", alert_heads_up, false)
	$snd.play()

func _on_asteroid_timer_timeout():
	emit_signal("on_alert", asteroid_visual.lifetime, true)
	camera_shake.shake(asteroid_visual.lifetime)
	asteroid_visual.emitting = true

	for character in hit_box.get_overlapping_bodies():
		if not in_safe_zone.has(character):
			character.health = 0

	await get_tree().create_timer(asteroid_visual.lifetime).timeout
	_start_asteroid_timer()

func _on_area_3d_body_entered(body: Node3D):
	if _is_player(body):
		_start_asteroid_timer()
		_toggle_spawns(true)
		$space_sound.fade(true)

func _on_area_3d_body_exited(body: Node3D):
	if _is_player(body):
		asteroid_indicator_timer.stop()
		asteroid_timer.stop()
		_toggle_spawns(false)
		$space_sound.fade(false)

func _on_safe_zone_body_entered(body: Node3D):
	if body is Character and not in_safe_zone.has(body):
		in_safe_zone.append(body)

func _on_safe_zone_body_exited(body: Node3D):
	if body is Character:
		in_safe_zone.erase(body)

func _is_player(body: Node3D) -> bool:
	return body is Character and not body.npc

func _toggle_spawns(toggle: bool):
	for spawn in $spawns.get_children():
		if spawn is Spawn:
			spawn.toggle(toggle)

func _start_asteroid_timer():
	var new_asteroid_time := randf_range(asteroid_timer_min, asteroid_timer_max)
	asteroid_indicator_timer.start(new_asteroid_time - alert_heads_up)
	asteroid_timer.start(new_asteroid_time)
