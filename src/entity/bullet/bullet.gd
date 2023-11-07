extends Node3D

@onready var ray := $rayCast3D
@export_range(0.0, 50.0) var speed = 10.0
var damage: int = 0
var spawn_call: Callable = func(): pass


func _ready():
	spawn_call.call()

func spawn_shot(args := {}):
	var node: Node3D = null
	
	if args.has("character"):
		node = args["character"]
		node.snd_shoot.play()
		var shoot_dir := Vector2.UP if node.npc else Vector2.DOWN
		node.anim_tree["parameters/shoot/blend_position"] = shoot_dir
		node.anim_tree["parameters/move-shoot/blend_position"] = shoot_dir
		
		var exceptions := []
		if node.is_in_group("friendly"):
			exceptions = node.get_tree().get_nodes_in_group("friendly")
		elif node.is_in_group("foe"):
			exceptions = node.get_tree().get_nodes_in_group("foe")
		exceptions.map(func(e): $rayCast3D.add_exception(e))
		
		damage = node.range_damage
		transform.origin = node.hit_spawn.global_transform.origin
		transform.basis = node.img.basis
		node.add_sibling(self)
		
	elif args.has_all(["trap", "target"]):
		node = args["trap"]
		node.snd_shoot.play()
		damage = node.damage
		
		spawn_call = func():
			look_at_from_position(node.global_position, \
				args["target"].global_position)
		
		if node.path_follow == null:
			node.add_sibling(self)
		else:
			node.path_follow.add_sibling(self)

func _physics_process(delta: float):
	global_position += -transform.basis.z * speed * delta
	
	if ray.is_colliding():
		var hit_scan = ray.get_collider()
		if hit_scan is Character:
			hit_scan.health -= damage
		ray.enabled = false
		
		$snd.play()
		$meshInstance3D.hide()
		$gpuParticles3D.emitting = true
		$timer_hit.start()

func _on_timer_timeout():
	queue_free()
