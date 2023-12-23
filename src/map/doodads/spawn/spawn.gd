extends IToggleable
class_name Spawn

@export var _spawns: Array[PackedScene] = []
@export_range(3.0, 60.0) var spawn_interval_sec := 15.0
@export var action_trigger: ITriggerable = null


func toggle(activate: bool):
	super.toggle(activate)
	if activate:
		var spawn: Node3D = _spawns.pick_random().instantiate()
		spawn.global_transform.origin = global_transform.origin
		if action_trigger != null:
			action_trigger.trigger(spawn)
		$timer.start(spawn_interval_sec)
	else:
		$timer.stop()

func _on_timer_timeout():
	toggle(true)
