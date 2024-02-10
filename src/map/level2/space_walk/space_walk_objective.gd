extends IToggleable

@export var objective_map: ObjectiveMap = null


func _on_area_3d_body_entered(body: Node3D):
	if body is Character and not body.npc and objective_map != null:
		toggle(true)
		for objective in objective_map.objectives:
			if objective["type"] == ObjectiveMap.Type.TRAVERSE \
			and objective["name"] == name:
				objective["completed"] = true
