extends Node

@export_group("Asteroids")
@export_range(3.0, 24.0) var asteroid_timer_min := 8.0
@export_range(3.0, 24.0) var asteroid_timer_max := 12.0
@export var alert_heads_up: float = 3.0

@export_group("Other")
@export var space_celestials: Node3D = null

@export_category("Dialogue")
@export var dialogue: DialogueMenu = null
@export_range(0, 10, 1) var dialogue_idx = -1

@onready var camera_shake: Node = $camera_shake
@onready var asteroid_timer: Timer = $asteroid_timer
@onready var asteroid_visual: GPUParticles3D = $asteroid/asteroids
@onready var asteroid_indicator_timer: Timer = $asteroid_indicator_timer
@onready var snd_impact: AudioStreamPlayer = $snd_impact
@onready var hit_box: Area3D = $area3D

var spawned_characters := []
var in_safe_zone := []
var active := false
var passed_by := false

signal on_alert(duration: float, impact: bool)

func _ready():
	for spawn_point in get_tree().get_nodes_in_group("spawn"):
		spawn_point.spawned_character.connect(_on_spawn_entered)

func _on_spawn_entered(character: Character):
	spawned_characters.append(character)
	character.died.connect(func(c):
		spawned_characters.erase(c)
		in_safe_zone.erase(c))

func _on_asteroid_indicator_timer_timeout():
	camera_shake.shake(0.5)
	emit_signal("on_alert", alert_heads_up, false)
	$snd.play()

func _on_asteroid_timer_timeout():
	spawned_characters.filter(func(c): return not in_safe_zone.has(c)) \
		.map(func(c): c.health = 0)
	if active:
		emit_signal("on_alert", asteroid_visual.lifetime, true)
		camera_shake.shake(asteroid_visual.lifetime)
		asteroid_visual.emitting = true

		await get_tree().create_timer(0.4).timeout
		for i in range(snd_impact.max_polyphony):
			snd_impact.play()
			await get_tree().create_timer(randf_range(0.1, 0.3)).timeout

		await get_tree().create_timer(asteroid_visual.lifetime).timeout
		_start_asteroid_timer()

func _on_area_3d_body_entered(body: Node3D):
	if _is_player(body):
		if not passed_by and dialogue != null and dialogue_idx != -1:
			dialogue.start_dialogue(dialogue_idx)
			passed_by = true

		space_celestials.show()
		active = true
		get_tree().call_group("celestial", "toggle", true)
		_start_asteroid_timer()
		_toggle_spawns(true)
		$space_sound.fade(true)

func _on_area_3d_body_exited(body: Node3D):
	if _is_player(body):
		get_tree().call_group("celestial", "toggle", false)
		space_celestials.hide()
		active = false
		asteroid_indicator_timer.stop()
		asteroid_timer.stop()
		_toggle_spawns(false)
		$space_sound.fade(false)
		spawned_characters.map(func(c): c.health = 0)

func _on_safe_zone_body_entered(body: Node3D):
	if body is Character and not in_safe_zone.has(body):
		in_safe_zone.append(body)

func _on_safe_zone_body_exited(body: Node3D):
	in_safe_zone.erase(body)

func _is_player(body: Node3D) -> bool:
	return body is Character and not body.npc

func _toggle_spawns(toggle: bool):
	get_tree().get_nodes_in_group("spawn").map(func(s): s.toggle(toggle))

func _start_asteroid_timer():
	if active:
		var new_asteroid_time := randf_range(asteroid_timer_min, asteroid_timer_max)
		asteroid_indicator_timer.start(new_asteroid_time - alert_heads_up)
		asteroid_timer.start(new_asteroid_time)
