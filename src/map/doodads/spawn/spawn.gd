extends IToggleable
class_name Spawn

@export var _spawns: Array[PackedScene] = []
@export var character_container: Node3D = null
@export_range(3.0, 60.0) var spawn_interval_sec := 15.0
@export var action_trigger: ITriggerable = null
@export var disabled := false
@export var door: Door = null

var spawn: Node3D = null

signal spawned_character(character: Character)


func _ready():
	if door != null:
		door.door_activated.connect(_on_door_activated)

func toggle(activate: bool):
	if disabled:
		return
	super.toggle(activate)
	if activate:
		if door != null:
			door.toggle(true)
		elif action_trigger != null:
			action_trigger.trigger(spawn)
			$timer.start(spawn_interval_sec)
	else:
		$timer.stop()

func _on_door_activated(opened: bool):
	if opened:
		spawn = _spawns.pick_random().instantiate()
		character_container.add_child(spawn)
		spawn.add_to_group("space_walk_spawned_character")
		spawn.global_transform.origin = global_transform.origin
		if action_trigger != null:
			action_trigger.trigger(spawn)
		spawned_character.emit(spawn)
		await get_tree().create_timer(1.25).timeout
		door.toggle(false)
		await door.door_activated
		if activated:
			$timer.start(spawn_interval_sec)

func _on_timer_timeout():
	toggle(true)
