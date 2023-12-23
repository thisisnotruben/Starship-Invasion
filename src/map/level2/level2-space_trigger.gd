extends ITriggerable

@export var player: Character = null


func trigger(node: Node3D):
	if node is Character and node.npc:
		node.aggro(player)
