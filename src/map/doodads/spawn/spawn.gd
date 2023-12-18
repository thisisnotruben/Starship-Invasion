extends IToggleable
class_name Spawn

enum Type { INTERVAL, ACTIVATE }

@export var _spawn: PackedScene = null
@export_range(0.0, 1.0) var spawn_chance := 0.5
@export_range(3.0, 60.0) var spawn_interval_sec := 15.0
@export var action_trigger: ITriggerable = null


func toggle(activate: bool):
	super.toggle(activate)
	var spawn: Node3D = _spawn.instantiate()
	spawn.global_transform.origin = global_transform.origin
	if action_trigger != null:
		action_trigger.trigger(spawn)
