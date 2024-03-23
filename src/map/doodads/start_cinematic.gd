extends Node3D

@export var anim: AnimationPlayer = null
@export var player: Character = null


func _ready():
	if anim != null and Checkpoint.data.is_empty() \
	and LevelEnd.times_died == 0:
		anim.play("start_cinematic")
	else:
		player.npc = false
