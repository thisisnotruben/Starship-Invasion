extends Special

@export var minion_scene: PackedScene = null
@export var spawn_points: Array[NavigationAgent3D] = []
@export var bullet_scene: PackedScene = null
@export_flags_3d_physics var bullet_spwan_coll = \
	0b00000000_00000000_00000000_00100001


func enter():
	super.enter()
	spawn_minion()

func is_valid_state() -> bool:
	if minion_scene == null \
	or character.target == null or bullet_scene == null:
		emit_signal("change_state", CharacterStates.Type.IDLE)
		return false
	return true

func get_spawn_point() -> Node3D:
	var spawn_point: NavigationAgent3D = spawn_points.pick_random()
	spawn_point.target_position = character.target.global_position
	if spawn_point.is_target_reachable():
		return spawn_point.get_parent()
	else:
		spawn_points.shuffle()
		for point in spawn_points:
			point.target_position = character.target.global_position
			if point.is_target_reachable():
				return point.get_parent()
	return null

func spawn_minion():
	if not is_valid_state():
		return

	var spawn_point := get_spawn_point()
	if spawn_point == null:
		emit_signal("change_state", CharacterStates.Type.IDLE)
		return

	var bullet: Node = bullet_scene.instantiate()
	bullet.tree_exited.connect(Callable(_on_bullet_freed) \
		.bind(spawn_point.global_position))
	bullet.spawn_shot({"from_character": character, \
		"origin_pos": character.global_position, \
		"target_pos": spawn_point.global_position, \
		"coll_mask": bullet_spwan_coll})

func _on_bullet_freed(spawn_point_pos: Vector3):
	var minion := minion_scene.instantiate()
	character.add_sibling(minion)
	minion.global_transform.origin = spawn_point_pos
	minion.aggro(character.target)
