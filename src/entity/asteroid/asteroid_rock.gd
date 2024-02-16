extends Node3D
class_name Asteroid

@export_range(0.0, 50.0) var speed = 5.0
@export var other_asteroid_body: Node3D = null

var spawn_call: Callable = func(): pass
var destroyed := false


func _ready():
	spawn_call.call()
	$SpaceRock0.visible = other_asteroid_body == null

func spawn(args := {}):
	if args.has_all(["parent", "spawn_pos", "velocity_dir", "scale"]):
		spawn_call = func():
			scale = args["scale"]; look_at_from_position( \
				args["spawn_pos"], args["velocity_dir"])
		args["parent"].add_sibling(self)

func _physics_process(delta: float):
	global_position += -transform.basis.z * speed * delta

func destroy():
	if not destroyed:
		destroyed = true
		$anim.play("explode")
		if other_asteroid_body != null:
			other_asteroid_body.hide()
		await $anim.animation_finished
		queue_free()
