extends Control

@onready var tab: TabContainer = $center/panel/margin/tabs
@onready var popup: Control = $center/panel/margin/tabs/popup
@onready var prev_tab: Control = $center/panel/margin/tabs/main/resume_game
var tabs := {"main": 0, "license": 1, "credits": 2, \
"popup": 3, "controls": 4, "settings": 5}


func _ready():
	connect("visibility_changed", Callable(self, "_on_visibility_changed"))

func _input(event: InputEvent):
	if event.is_action_pressed("pause") \
	or (visible and event.is_action_pressed("ui_cancel")) \
	and tab.current_tab == tabs["main"]:
		visible = !visible
		if visible:
			$snd_pause.play()
		else:
			$snd_resume.play()
	elif event.is_action_pressed("ui_cancel") \
	and [tabs["license"], tabs["credits"], tabs["popup"], \
	tabs["controls"], tabs["settings"]].has(tab.current_tab):
		_on_back_pressed()

func _on_focus_entered():
	$snd_nav.play()

func _on_resume_game_pressed():
	$snd_resume.play()
	hide()

func _on_start_menu_pressed():
	$snd_popup.play()
	popup.display("Go to Start Menu?", "Go", "Stay")
	prev_tab = $center/panel/margin/tabs/main/start_menu
	tab.current_tab = tabs["popup"]
	if await popup.popup_return == "yes":
		$snd_start.play()
		await $snd_start.finished
		get_tree().paused = false
		get_tree().change_scene_to_file("res://src/ui/start/start.tscn")
	else:
		$snd_back.play()
		tab.current_tab = tabs["main"]

func _on_controls_pressed():
	$snd.play()
	prev_tab = $center/panel/margin/tabs/main/grid/controls
	tab.current_tab = tabs["controls"]

func _on_settings_pressed():
	$snd.play()
	prev_tab = $center/panel/margin/tabs/main/grid/settings
	tab.current_tab = tabs["settings"]

func _on_license_pressed():
	$snd.play()
	prev_tab = $center/panel/margin/tabs/main/grid/license
	tab.current_tab = tabs["license"]

func _on_credits_pressed():
	$snd.play()
	prev_tab = $center/panel/margin/tabs/main/grid/credits
	tab.current_tab = tabs["credits"]

func _on_exit_pressed():
	$snd_popup.play()
	popup.display("Exit Game?", "Exit", "Stay")
	tab.current_tab = tabs["popup"]
	prev_tab = $center/panel/margin/tabs/main/exit
	if await popup.popup_return == "yes":
		$snd_exit.play()
		await $snd_exit.finished
		get_tree().quit()
	else:
		$snd_back.play()
		tab.current_tab = tabs["main"]

func _on_back_pressed():
	$snd_back.play()
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
			$snd_back.play()
			hide()


