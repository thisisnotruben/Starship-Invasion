extends Node3D
class_name ComputerToggle

@export var i_toggleable: IToggleable = null
@export var can_revert_toggle := true
@export var disabled := false
var trigger: bool = true

@export var sfx_activate: AudioStream = null
@export var sfx_deactivate: AudioStream = null

@export_group("Item")
@export var need_item := false
@export var item_needed := Item.Type.HEALTH
@export var sfx_denied: AudioStream = null

var _player: Character = null


func _ready():
	set_process_input(false)
	if i_toggleable != null:
		i_toggleable.toggled.connect(func(t): trigger = not t)

func _input(event: InputEvent):
	if event.is_action_pressed("interact"):
		if disabled:
			$snd.stream = sfx_denied
			$snd.play()
		elif _player != null and (can_revert_toggle or trigger):
			$snd.stream = sfx_activate if trigger else sfx_deactivate
			if need_item:
				if _player.inventory.has(item_needed):
					i_toggleable.toggle(trigger)
					_player.on_interacted(name)
				else:
					$snd.stream = sfx_denied
			else:
				i_toggleable.toggle(trigger)
				_player.on_interacted(name)
			$snd.play()

func _on_sight_body_entered(body: Node3D):
	if body is Character and not body.npc:
		set_process_input(true)
		_player = body

func _on_sight_body_exited(body: Node3D):
	if body == _player:
		set_process_input(false)
		_player = null
