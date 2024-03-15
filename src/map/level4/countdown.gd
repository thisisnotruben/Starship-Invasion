extends Node
class_name CountDown

const MINUTE: int = 60

static var time_left: float = -1.0

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
	shake_cam.noise = FastNoiseLite.new()
	player.died.connect(func():
		game_timer.stop()
		game_audio.stop())

func start():
	if LevelEnd.times_died == 0:
		time_left = -1.0
	var _countdown_sec = time_left if time_left != -1.0 else countdown_sec
	game_timer.wait_time = _countdown_sec
	game_audio.wait_time = _countdown_sec - 10.0
	game_timer.start()
	game_audio.start()
	rand_explode_timer.start( \
		randf_range(rand_min_explode_sec, rand_max_explode_sec))

func set_text():
	label.text = "%d:%02d" % [floor(game_timer.time_left / MINUTE), \
		int(game_timer.time_left) % MINUTE]

func _process(_delta: float):
	set_text()

func _on_tree_exiting():
	time_left = game_timer.time_left

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
	if not explode_snd_library.is_empty():
		snd_rand_explode.stream = explode_snd_library.pick_random()
		snd_rand_explode.play()
		shake_cam.camera = player.camera
		shake_cam.shake(randf_range(1.0, shake_cam_sec_max))
	rand_explode_timer.start( \
		randf_range(rand_min_explode_sec, rand_max_explode_sec))


