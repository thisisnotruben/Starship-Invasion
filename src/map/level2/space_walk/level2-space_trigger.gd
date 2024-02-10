extends ITriggerable

@export var player: Character = null
@export var move_to_marker: Marker3D = null


func trigger(node: Node3D):
	if node is Character and node.npc:
		if move_to_marker != null:
			pass
		node.aggro(player)
