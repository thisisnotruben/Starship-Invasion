extends Control

@onready var snd: AudioStreamPlayer = $snd
@onready var tab: TabContainer = $center/panel/margin/tabs
@onready var prev_tab: Control = $center/panel/margin/tabs/main/start
var tabs := {"main": 0, "difficulty": 1, \
"license": 2, "credits": 3, "controls": 4}


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		if tab.current_tab in [tabs["difficulty"], tabs["license"], \
		tabs["credits"], tabs["controls"]]:
			_on_back_pressed()

func _on_start_pressed():
	snd.play()
	prev_tab = $center/panel/margin/tabs/main/start
	tab.current_tab = tabs["difficulty"]

func _on_controls_pressed():
	snd.play()
	prev_tab = $center/panel/margin/tabs/main/controls
	tab.current_tab = tabs["controls"]

func _on_license_pressed():
	snd.play()
	prev_tab = $center/panel/margin/tabs/main/license
	tab.current_tab = tabs["license"]

func _on_credits_pressed():
	snd.play()
	prev_tab = $center/panel/margin/tabs/main/credits
	tab.current_tab = tabs["credits"]

func _on_exit_pressed():
	get_tree().quit()

func _on_difficulty_mode_pressed(difficulty_mode: String):
	var _payload := {}
	match difficulty_mode:
		"easy":
			pass
		"medium":
			pass
		"hard":
			pass
	
	snd.play()
	get_tree().change_scene_to_file("res://src/map/level1.tscn")

func _on_back_pressed():
	snd.play()
	tab.current_tab = tabs["main"]

func _on_main_draw():
	prev_tab.grab_focus()

func _on_difficulty_draw():
	$center/panel/margin/tabs/difficulty/easy.grab_focus()
