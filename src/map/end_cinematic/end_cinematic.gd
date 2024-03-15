extends Node3D

@onready var anim: AnimationPlayer = $anim
@onready var snd: AudioStreamPlayer = $explosions_snd
@onready var snd_countdown: AudioStreamPlayer = $countdown_snd
@onready var shake_cam: ShakeCam = $shake_cam

@export var snd_library: Array[AudioStream] = []
@export var countdown_snd_library: Array[AudioStream] = []
@export var start_menu_scene: PackedScene = null

func _init():
	LevelQuery.last_cinematic_played = true

func _on_anim_animation_finished(anim_name: String):
	var next_act = ""
	match anim_name:
		"act00":
			next_act = "act01"
		"act01":
			next_act = "act02"
		"act02":
			next_act = "act03"
		"act03":
			next_act = "act04"
		"act04":
			next_act = "act05"
		_:
			get_tree().change_scene_to_packed(start_menu_scene)
	if anim.has_animation(next_act):
		anim.play(next_act)

func shake_camera(duration: float):
	shake_cam.camera = get_viewport().get_camera_3d()
	shake_cam.shake(duration)

func act00_start():
	var door: Door = $maps/nav/door
	door.toggle(true)
	await door.door_activated
	$acts/act00/character.move_to( \
		$"acts/act00/act-00_Marker3D".global_position)
	$"acts/act00/Space Warrior Gold".move_to( \
		$"acts/act00/act-00_Marker3D2".global_position)
	$acts/act00/SwarmAlien.move_to( \
		$"acts/act00/act-00_Marker3D3".global_position)
	$acts/act00/pile_of_flesh_red.move_to( \
		$"acts/act00/act-00_Marker3D4".global_position)

func act00_explode():
	shake_camera(4.0)
	[$acts/act00/trap_fire, $acts/act00/trap_fire2, $acts/act00/trap_fire4, \
		$acts/act00/trap_fire3].map(func(t): t.toggle(true))
	[$acts/act00/explosion, $acts/act00/explosion2, $acts/act00/explosion3] \
		.map(func(t): t.trigger(null))

func act01_play_snd():
	for i in [0.8, 1.2, 2.0, 1.5, 1.75, 0.9, 1.5, \
	1.75, 0.5, 1.75, 0.5, 1.2, 0.2, 0.1, 1.0, 0.2, \
	0.1, 0.05, 0.02, 0.1]:
		await get_tree().create_timer(i).timeout
		snd.stream = snd_library.pick_random()
		snd.play()

func start_fires():
	$fire.get_children().filter(func(n): return n is IToggleable) \
		.map(func(t): t.toggle(true))

func start_explosions(big_ones:= false):
	var explosions: Node = $big_explosions if big_ones else $explosions
	for explosion in explosions.get_children():
		await get_tree().create_timer(randf_range(0.2, 0.4)).timeout
		explosion.toggle(true)

func start_explosions_instant():
	var explosions := $big_explosions.get_children()
	explosions.append_array($explosions.get_children())
	explosions.shuffle()
	for explosion in explosions:
		explosion.particles.lifetime = randf_range(1.5, 2.5)
		explosion.toggle(true)
	await get_tree().create_timer(1.0).timeout
	[$fire, $maps, $lights].map(func(n): n.hide())

func start_countdown():
	for stream in countdown_snd_library:
		snd_countdown.stream = stream
		snd_countdown.play()
		await get_tree().create_timer(1.0).timeout

func move_in_ship():
	$acts/act05/nav/ship_interior/character.move_to( \
		$acts/act05/nav/ship_interior/Marker3D.global_position)
