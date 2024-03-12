extends Node

const MINUTE: int = 60

@onready var snd_explode: AudioStreamPlayer = $snd_explode
@onready var snd_rand_explode: AudioStreamPlayer = $snd_rand_explode
@onready var snd_countdown: AudioStreamPlayer = $snd_countdown
@onready var game_timer: Timer = $timer
@onready var game_audio: Timer = $timer_audio
@onready var rand_explode_timer: Timer = $timer_rand_explode
@onready var shake_cam: ShakeCam = $shake_cam

@export var player: Character = null
@export_category("Hud")
@export var countdown_panel: PanelContainer = null
@export var label: Label = null

@export_category("Countdown")
@export_range(60.0, MINUTE * 30.0) var countdown_sec := MINUTE * 20.0
@export var countdown_snd_library: Array[AudioStream] = []

@export_category("Random Explosions")
@export var explode_snd_library: Array[AudioStream] = []
@export_range(1.0, MINUTE) var rand_min_explode_sec := MINUTE * 0.2
@export_range(1.0, MINUTE * 3.0) var rand_max_explode_sec := MINUTE
@export_range(1.0, 3.0) var shake_cam_sec_max := 2.5


func _ready():
	countdown_panel.show()
	set_process(label != null)
	game_timer.wait_time = countdown_sec
	game_audio.wait_time = countdown_sec - 10.0
	game_timer.start()
	game_audio.start()
	rand_explode_timer.start( \
		randf_range(rand_min_explode_sec, rand_max_explode_sec))
	shake_cam.noise = FastNoiseLite.new()

func _process(_delta):
	label.text = "%d:%02d" % [floor(game_timer.time_left / MINUTE), \
		int(game_timer.time_left) % MINUTE]

func _on_timer_timeout():
	snd_explode.play()
	if player != null:
		player.health = 0

func _on_timer_audio_timeout():
	for stream in countdown_snd_library:
		snd_countdown.stream = stream
		snd_countdown.play()
		await get_tree().create_timer(1.0).timeout

func _on_timer_rand_explode_timeout():
	snd_rand_explode.stream = explode_snd_library.pick_random()
	snd_rand_explode.play()
	shake_cam.camera = player.camera
	shake_cam.shake(randf_range(1.0, shake_cam_sec_max))
	rand_explode_timer.start( \
		randf_range(rand_min_explode_sec, rand_max_explode_sec))
