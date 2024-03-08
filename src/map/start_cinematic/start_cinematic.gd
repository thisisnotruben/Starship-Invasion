extends Node3D

@onready var anim: AnimationPlayer = $anim
@export var act0_music: AudioStream = null


func _ready():
	set_physics_process(false)

func _physics_process(_delta: float):
	$turrets/turret.pivot.look_at($starships/starship1.global_position)
	$turrets/turret2.pivot.look_at($starships/starship3.global_position)

func _on_dialogue_finished():
	anim.play("act1")

func _on_anim_animation_finished(anim_name: String):
	var next_anim := ""
	match anim_name:
		"act1":
			next_anim = "act2"
		"act2":
			next_anim = "act3"
		"act3":
			next_anim = "act4"
			$turrets/turret.set_aim(false)
			$turrets/turret2.set_aim(false)
			set_physics_process(false)
		"act4":
			next_anim = "act5"
		"act5":
			next_anim = "act6"
	if not next_anim.is_empty():
		anim.play(next_anim)

func act0_start():
	$music.stream = act0_music
	$music.play()

func act2_shake_cam():
	$act2.shake(4.0)

func act3_start():
	$turrets/turret.set_aim(true)
	$turrets/turret2.set_aim(true)
	set_physics_process(true)

func act3_turret_shoot(turret_path: NodePath):
	get_node(turret_path).shoot()

func act4_shoot(cin_shoot_path: NodePath):
	get_node(cin_shoot_path).shoot()

func act4_start(activate := true):
	$starships/starship1.toggle(activate)
	$starships/starship3.toggle(activate)

func act5_shoot(cin_shoot_path: NodePath):
	get_node(cin_shoot_path).shoot()
