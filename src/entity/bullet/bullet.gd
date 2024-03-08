extends Node3D
class_name Bullet

@onready var ray := $rayCast3D
@export_range(0.0, 50.0) var speed = 10.0
@export_range(1.0, 5.0) var toss_time := 1.5
@export_range(0.0, 5.0) var toss_height := 3.0

var damage: int = 0
var spawn_call: Callable = func(): pass
var from_character: Character = null
var hit := false


func _ready():
	spawn_call.call()

func spawn_shot(args := {}):
	var node: Node3D = null

	if args.has("character"):
		node = args["character"]
		from_character = node
		node.snd_shoot.play()
		damage = node.range_damage

		var exceptions := []
		if node.is_in_group("friendly"):
			exceptions = node.get_tree().get_nodes_in_group("friendly")
		elif node.is_in_group("foe"):
			exceptions = node.get_tree().get_nodes_in_group("foe")

		spawn_call = func():
			exceptions.map(func(e): ray.add_exception(e))
			transform.origin = node.hit_scan_shoot.global_position
			transform.basis = node.img.basis

		node.add_sibling(self)

	elif args.has_all(["from_character", \
	"origin_pos", "target_pos", "coll_mask"]):
		node = args["from_character"]
		node.snd_shoot.play()
		damage = 0

		spawn_call = func():
			set_physics_process(false)
			look_at_from_position(args["origin_pos"], args["target_pos"])

			var tween_to := get_tree().create_tween().set_parallel()
			tween_to.tween_property(self, "global_position:x", \
				args["target_pos"].x, toss_time)
			tween_to.tween_property(self, "global_position:z", \
				args["target_pos"].z, toss_time)

			var tween_toss := get_tree().create_tween()
			tween_toss.tween_property(self, "global_position:y", \
				toss_height, toss_time / 2.0) \
				.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
			tween_toss.tween_property(self, "global_position:y", \
				args["target_pos"].y, toss_time / 2.0) \
				.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
			tween_toss.tween_callback(hit_effect)

		node.add_sibling(self)

	elif args.has_all(["trap", "target", "exclude"]):
		node = args["trap"]
		node.snd_shoot.play()
		damage = node.damage

		spawn_call = func():
			args["exclude"].map(func(e): ray.add_exception(e))
			look_at_from_position(node.global_position, \
				args["target"].global_position)

		if node.path_follow == null:
			node.add_sibling(self)
		else:
			node.path_follow.add_sibling(self)

	elif args.has("asteroid_turret"):
		node = args["asteroid_turret"]
		args["snd_player"].play()
		damage = args["damage"]

		spawn_call = func ():
			look_at_from_position(node.ray.global_position, \
				node.laser_mesh.global_position)

		node.add_sibling(self)

	elif args.has_all(["parent", "origin", "target"]):
		node = args["parent"]
		spawn_call = func():
			look_at_from_position(args["origin"], args["target"])
		node.add_sibling(self)

func _physics_process(delta: float):
	if hit:
		return

	if ray.is_colliding():
		hit = true
		hit_effect()
		var hit_scan = ray.get_collider()
		if hit_scan is Character:
			hit_scan.health -= damage
			if from_character != null:
				hit_scan.aggro(from_character)
		elif hit_scan is Area3D:
			hit_scan = hit_scan.owner
			if hit_scan is Asteroid:
				hit_scan.destroy()
	else:
		global_position += -transform.basis.z * speed * delta

func hit_effect():
	$snd.play()
	$meshInstance3D.hide()
	if has_node("GPUParticles3D"):
		get_node("GPUParticles3D").hide()
	$gpuParticles3D.emitting = true
	$timer_hit.start()

func _on_timer_timeout():
	queue_free()
