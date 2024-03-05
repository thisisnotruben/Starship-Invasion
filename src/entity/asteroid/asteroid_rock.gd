extends Node3D
class_name Asteroid

@onready var snd: AudioStreamPlayer3D = $snd
@onready var particles: GPUParticles3D = $GPUParticles3D

@export_range(0.0, 50.0) var speed = 5.0
@export var other_asteroid_body: Node3D = null
@export var snd_library: Array[AudioStream] = []
@export_range(1.0, 10.0) var wait_for_snd := 4.0


var spawn_call: Callable = func(): pass
var destroyed := false


func _ready():
	spawn_call.call()
	$SpaceRock0.visible = other_asteroid_body == null

func spawn(args := {}):
	if args.has_all(["parent", "spawn_pos", "velocity_dir", "scale"]):
		spawn_call = func():
			look_at_from_position( args["spawn_pos"], args["velocity_dir"])
			scale *= args["scale"]
			particles.process_material.scale_min *= args["scale"] * 0.3
			particles.process_material.scale_max *= args["scale"] * 0.3
		args["parent"].add_sibling(self)

func _physics_process(delta: float):
	global_position += -transform.basis.z * speed * delta

func destroy():
	if not destroyed:
		destroyed = true
		set_physics_process(false)
		if other_asteroid_body != null:
			other_asteroid_body.hide()
		$anim.play("explode")
		if snd_library.is_empty():
			await $anim.animation_finished
			queue_free()
		else:
			snd.stream = snd_library.pick_random()
			snd.play()
			await snd.finished
			queue_free()
