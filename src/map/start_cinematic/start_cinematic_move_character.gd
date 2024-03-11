extends ITriggerable

@export var move_to_marker: Marker3D = null


func trigger(_node: Node3D):
	if _node is Character:
		_node.move_to(move_to_marker.global_position)
