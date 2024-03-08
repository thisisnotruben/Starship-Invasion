extends Node

const MINUTE: int = 60

@onready var snd_explode: AudioStreamPlayer = $snd_explode
@onready var snd_countdown: AudioStreamPlayer = $snd_countdown
@onready var game_timer: Timer = $timer
@onready var game_audio: Timer = $timer_audio

@export var player: Character = null
@export_category("Hud")
@export var countdown_panel: PanelContainer = null
@export var label: Label = null

@export_category("Countdown")
@export_range(60.0, MINUTE * 10.0) var countdown_sec := MINUTE * 5.0
@export var countdown_snd_library: Array[AudioStream] = []


func _ready():
	countdown_panel.show()
	set_process(label != null)
	game_timer.wait_time = countdown_sec
	game_audio.wait_time = countdown_sec - 10.0
	game_timer.start()
	game_audio.start()

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
