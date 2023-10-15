extends Control

@onready var snd: AudioStreamPlayer = $snd
@onready var tab: TabContainer = $center/panel/margin/tabs
@onready var popup: Control = $center/panel/margin/tabs/popup
@onready var prev_tab: Control = $center/panel/margin/tabs/main/resume_game
var tabs := {"main": 0, "license": 1, \
"credits": 2, "popup": 3, "controls": 4}


func _ready():
	connect("visibility_changed", Callable(self, "_on_visibility_changed"))

func _input(event: InputEvent):
	if event.is_action_pressed("pause") and tab.current_tab == tabs["main"]:
		snd.play()
		visible = !visible
	elif event.is_action_pressed("ui_cancel") \
	and tab.current_tab in [tabs["license"], \
	tabs["credits"], tabs["popup"], tabs["controls"]]:
		snd.play()
		_on_back_pressed()

func _on_resume_game_pressed():
	snd.play()
	hide()

func _on_start_menu_pressed():
	snd.play()
	popup.display("Go to Start Menu?", "Go", "Stay")
	prev_tab = $center/panel/margin/tabs/main/start_menu
	tab.current_tab = tabs["popup"]
	if await popup.popup_return == "yes":
		snd.play()
		get_tree().paused = false
		get_tree().change_scene_to_file("res://src/ui/start/start.tscn")
	else:
		snd.play()
		tab.current_tab = tabs["main"]

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
	snd.play()
	popup.display("Exit Game?", "Exit", "Stay")
	tab.current_tab = tabs["popup"]
	prev_tab = $center/panel/margin/tabs/main/exit
	if await popup.popup_return == "yes":
		get_tree().quit()
	else:
		snd.play()
		tab.current_tab = tabs["main"]

func _on_back_pressed():
	snd.play()
	tab.current_tab = tabs["main"]

func _on_visibility_changed():
	if get_tree() != null:
		get_tree().paused = visible
		if not visible:
			tab.current_tab = tabs["main"]
			prev_tab = $center/panel/margin/tabs/main/resume_game

func _on_main_draw():
	prev_tab.grab_focus()

func next_level(prompt: bool, next_level_scene: PackedScene):
	visible = prompt
	if prompt:
		popup.display("Go Next Level?!", "Go", "Stay")
		tab.current_tab = tabs["popup"]
		if await popup.popup_return == "yes":
			get_tree().change_scene_to_packed(next_level_scene)
		else:
			snd.play()
			hide()
