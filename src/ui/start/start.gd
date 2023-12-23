extends Control

var play_focus_sfx := false
var level_query := false
@onready var tab: TabContainer = $center/panel/margin/tabs
@onready var popup: Control = $center/panel/margin/tabs/popup
@onready var prev_tab: Control = $center/panel/margin/tabs/main/start
@onready var lvl_bttn_focus: Control = $center/panel/margin/tabs/level/level1
var tabs := {"main": 0, "license": 1, "credits": 2, \
"controls": 3, "popup": 4, "settings": 5, "level": 6}


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	randomize()

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel") \
	and [tabs["license"], tabs["credits"], tabs["controls"], \
	tabs["popup"], tabs["settings"], tabs["level"]] \
	.has(tab.current_tab):
		_on_back_pressed()

func _on_focus_entered():
	if play_focus_sfx:
		$snd_nav.play()

func _on_start_pressed():
	$snd.play()
	prev_tab = $center/panel/margin/tabs/main/start
	lvl_bttn_focus = $center/panel/margin/tabs/level/level1
	tab.current_tab = tabs["level"]

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
		$center/panel/margin/tabs/popup/hBox/yes.release_focus()
		await $snd_exit.finished
		get_tree().quit()
	else:
		$snd_back.play()
		tab.current_tab = tabs["main"]

func _on_back_pressed():
	$snd_back.play()
	tab.current_tab = tabs["level" if level_query else "main"]
	level_query = false

func _on_main_draw():
	play_focus_sfx = false
	prev_tab.grab_focus()
	play_focus_sfx = true

func _on_level_draw():
	play_focus_sfx = false
	lvl_bttn_focus.grab_focus()
	play_focus_sfx = true

func _on_level_pressed(level: int):
	if LevelQuery.is_locked(level - 1):
		level_query = true
		$snd_popup.play()
		popup.display("You haven't complete prior level...\n" \
			+ "Complete prior level?", "Go", "Stay")
		tab.current_tab = tabs["popup"]
		lvl_bttn_focus = get_node("center/panel/margin/tabs/level/level%s" \
			 % level)
		if await popup.popup_return == "yes":
			_go_to_next_level(level)
		else:
			$snd_back.play()
			tab.current_tab = tabs["level"]
	else:
		_go_to_next_level(level)

func _go_to_next_level(level: int):
	LevelQuery.unlock_level(level - 1)
	set_process_input(false)
	get_node("center/panel/margin/tabs/level/level%s" % level).release_focus()
	$snd_game.play()
	await $snd_game.finished
	get_tree().change_scene_to_file("res://src/map/level%s.tscn" % level)
