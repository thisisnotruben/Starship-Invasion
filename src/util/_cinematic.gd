extends Node3D


func _ready():
	look_at_me("Camera3D")

func look_at_me(nodePath: NodePath):
	for prop in get_tree().get_nodes_in_group("prop"):
		prop.set("look_at_node", get_node(nodePath))
