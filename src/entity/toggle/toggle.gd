extends Node3D

@export var i_toggleable: IToggleable = null
var trigger: bool = true


func _ready():
	set_process_input(i_toggleable != null)

func _input(event: InputEvent):
	if event.is_action("interact") and i_toggleable != null \
	and not $area3D.get_overlapping_bodies().filter(_has_player).is_empty() \
	and ((i_toggleable is Door and i_toggleable.type == Door.Type.ACTIVATE) \
	or (i_toggleable is Trap and i_toggleable.type == Trap.Type.ACTIVATE)
	or (i_toggleable is Spawn and i_toggleable.type == Trap.Type.ACTIVATE)):
		i_toggleable.toggle(trigger)
		trigger = !trigger
		$snd.play()

func _has_player(body: Node3D):
	return body is Character and !body.npc
