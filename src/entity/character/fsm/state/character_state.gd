extends IState
class_name CharacterState

@export var quips := [AudioStream]
@export_range(0.0, 1.0) var quip_play_chance := 1.0
var character: Character = null
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func init(args := {}) -> IState:
	character = args["character"]
	return self
	
func physics_process(delta: float):
	character.velocity.y -= gravity * delta

func enter():
	super.enter()
	play_quip()

func play_quip(idx: int = -1):
	if not quips.is_empty() and quip_play_chance >= randf():
		if idx == -1: 
			character.snd.stream = quips.pick_random()
		else:
			character.snd.stream = quips[idx]
		character.snd.play()
