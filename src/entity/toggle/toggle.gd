extends Node3D

@export var i_toggleable: IToggleable = null
@export var can_revert_toggle = true
var trigger: bool = true
@export var sfx_door: AudioStream = null
@export var sfx_trap: AudioStream = null
@export var sfx_spawn: AudioStream = null


func _ready():
	set_process_input(i_toggleable != null)

func _input(event: InputEvent):
	if can_revert_toggle and i_toggleable != null and event.is_action("interact") \
	and not $area3D.get_overlapping_bodies().filter(_has_player).is_empty():

		var stream: AudioStream = null
		if i_toggleable is Door and i_toggleable.type == Door.Type.ACTIVATE:
			stream = sfx_door
		if i_toggleable is Trap and i_toggleable.type == Trap.Type.ACTIVATE:
			stream = sfx_trap
		if i_toggleable is Spawn and i_toggleable.type == Trap.Type.ACTIVATE:
			stream = sfx_spawn

		if stream != null:
			i_toggleable.toggle(trigger)
			trigger = !trigger
			$snd.stream = stream
			$snd.play()

func _has_player(body: Node3D):
	return body is Character and !body.npc
