extends Node3D

@export var anim: AnimationPlayer = null
@export var player: Character = null


func _ready():
	if anim != null and Checkpoint.data.is_empty():
		anim.play("start_cinematic")
	else:
		player.npc = false
