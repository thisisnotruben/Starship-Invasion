extends CharacterBody3D
class_name Character


@onready var anim_state_machine: AnimationNodeStateMachinePlayback \
	= $animationPlayer["parameters/playback"]
@onready var fsm: Fsm = $fsm.init($fsm.get_children(), {"character": self})


func _physics_process(delta: float):
	fsm.physics_process(delta)

func _process(delta: float):
	fsm.process(delta)
