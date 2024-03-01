extends Node3D

@export var anim: AnimationPlayer = null
@export var player: Character = null


func _ready():
	if anim != null and Checkpoint.data.is_empty():
		anim.play("start_cinematic")
	else:
		player.npc = false

func set_look_at(node_path: NodePath):
	var node := get_node_or_null(node_path)
	if node != null:
		for prop in get_tree().get_nodes_in_group("prop"):
			prop.set("look_at_node", node)
