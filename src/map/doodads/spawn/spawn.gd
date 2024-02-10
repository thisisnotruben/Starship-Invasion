extends IToggleable
class_name Spawn

@export var _spawns: Array[PackedScene] = []
@export var character_container: Node3D = null
@export_range(3.0, 60.0) var spawn_interval_sec := 15.0
@export var action_trigger: ITriggerable = null
@export var disabled := false
@export var door: Door = null

const door_time := 1.2


func toggle(activate: bool):
	if disabled:
		return
	super.toggle(activate)
	if activate:

		if door != null:
			door.toggle(true)
			await get_tree().create_timer(door_time * 1.2).timeout

		var spawn: Node3D = _spawns.pick_random().instantiate()
		character_container.add_child(spawn)
		spawn.global_transform.origin = global_transform.origin
		if action_trigger != null:
			action_trigger.trigger(spawn)

		await get_tree().create_timer(door_time).timeout
		if door != null:
			door.toggle(false)

		$timer.start(spawn_interval_sec)
	else:
		$timer.stop()

func _on_timer_timeout():
	toggle(true)
