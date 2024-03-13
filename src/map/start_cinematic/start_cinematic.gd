extends Node3D

@onready var anim: AnimationPlayer = $anim
@export var act0_music: AudioStream = null
@export var next_level: PackedScene = null

var started := false


func _ready():
	set_physics_process(false)
	if StartMenu.chosen_level_scene != null:
		next_level = StartMenu.chosen_level_scene

func _physics_process(_delta: float):
	$turrets/turret.pivot.look_at($starships/starship1.global_position)
	$turrets/turret2.pivot.look_at($starships/starship3.global_position)

func _on_dialogue_finished():
	if started:
		if StartMenu.next_level != -1:
			LevelQuery.unlock_level(StartMenu.next_level)
		get_tree().change_scene_to_packed(next_level)
	else:
		anim.play("act01")
	started = true

func _on_anim_animation_finished(anim_name: String):
	var next_anim := ""
	match anim_name:
		"act01":
			next_anim = "act02"
		"act02":
			next_anim = "act03"
		"act03":
			next_anim = "act04"
			$turrets/turret.set_aim(false)
			$turrets/turret2.set_aim(false)
			set_physics_process(false)
		"act04":
			next_anim = "act05"
		"act05":
			next_anim = "act06"
			$turrets/turret.set_aim(false)
			$turrets/turret2.set_aim(false)
			set_physics_process(false)
		"act06":
			next_anim = "act07"
		"act07":
			next_anim = "act08"
		"act08":
			next_anim = "act09"
		"act09":
			next_anim = "act10"
		"act10":
			next_anim = "act11"
		"act11":
			next_anim = "act12"
		"act12":
			next_anim = "act13"
	if anim.has_animation(next_anim):
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
	act3_turret_shoot(cin_shoot_path)

func act4_start(activate := true):
	$starships/starship1.toggle(activate)
	$starships/starship3.toggle(activate)

func act5_shoot(cin_shoot_path: NodePath):
	act3_turret_shoot(cin_shoot_path)

func act6_start():
	act3_start()

func act6_fires(activate := true):
	for node in $"act6-fires".get_children():
		if node is IToggleable:
			node.toggle(activate)
	await get_tree().create_timer(1.5).timeout
	$"act6-fires/GPUParticles3D".emitting = activate
	$"act6-fires/GPUParticles3D2".emitting = activate

func act9_start():
	var characters := $characters.get_children()
	characters.append_array($"act3-squadron".get_children())
	characters = characters.filter(func(c): return c is Character)
	characters.shuffle()

	var start_attack := func(character: Character):
		await get_tree().create_timer(randf_range(0.25, 1.2)).timeout
		character.behavior.state = BehaviorStates.Type.ATTACK

	for character in characters:
		start_attack.call(character)

func act9_die(character_path: NodePath):
	var character: Character = get_node_or_null(character_path)
	if character != null:
		character.health = 0

func switch_target(from: NodePath, target: NodePath):
	var from_character: Character = get_node_or_null(from)
	var target_character: Character = get_node_or_null(target)
	if from_character != null and target_character != null:
		from_character.target = target_character
		from_character.behavior.state = BehaviorStates.Type.ATTACK

func act11_start():
	$"act10-survivor/character".move_to( \
		$"act10-survivor/Marker3D".global_position)

func act12_start():
	var door: Door = $maps/NavigationRegion3D/props/door
	door.toggle(true)
	await door.door_activated
	$"act12-survivor/character".move_to($"act12-survivor/into_station".global_position)
	await get_tree().create_timer(3.5).timeout
	door.toggle(false)
