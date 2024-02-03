extends Control

var play_focus_sfx := false

@export var player: Character = null
var dead := false
var level_transition := false

@onready var tab: TabContainer = $center/panel/margin/tabs
@onready var popup: Control = $center/panel/margin/tabs/popup
@onready var prev_tab: Control = $center/panel/margin/tabs/main/resume_game
var tabs := {"main": 0, "license": 1, "credits": 2, \
"popup": 3, "controls": 4, "settings": 5, "dead": 6}


func _ready():
	visibility_changed.connect(_on_visibility_changed)
	if player != null:
		player.health_changed.connect(show_death_screen)
	get_tree().get_nodes_in_group("level_transition") \
		.map(func(n): n.query_transiition.connect( \
		Callable(self, "next_level")))

func _input(event: InputEvent):
	if not dead and event.is_action_pressed("pause") \
	or (visible and event.is_action_pressed("ui_cancel")) \
	and (tab.current_tab == tabs["main"] or level_transition):
		visible = !visible
		if visible:
			$snd_pause.play()
		elif level_transition:
			$snd_back.play()
		else:
			$snd_resume.play()
	elif event.is_action_pressed("ui_cancel") \
	and [tabs["license"], tabs["credits"], tabs["popup"], \
	tabs["controls"], tabs["settings"]].has(tab.current_tab):
		_on_back_pressed(not dead)

func _on_focus_entered():
	if play_focus_sfx:
		$snd_nav.play()

func _on_resume_game_pressed():
	$snd_resume.play()
	hide()

func _on_start_menu_pressed(main := true):
	$snd_popup.play()
	popup.display("Go to Start Menu?", "Go", "Stay")
	prev_tab = $center/panel/margin/tabs/main/start_menu if main \
	 else $center/panel/margin/tabs/dead/start_menu
	tab.current_tab = tabs["popup"]
	if await popup.popup_return == "yes":
		$snd_start.play()
		$center/panel/margin/tabs/popup/hBox/yes.release_focus()
		await $snd_start.finished
		get_tree().paused = false
		get_tree().change_scene_to_file("res://src/ui/start/start.tscn")
	else:
		$snd_back.play()
		tab.current_tab = tabs["main" if main else "dead"]

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

func _on_exit_pressed(main := true):
	$snd_popup.play()
	popup.display("Exit Game?", "Exit", "Stay")
	tab.current_tab = tabs["popup"]
	prev_tab = $center/panel/margin/tabs/main/exit if main \
		else $center/panel/margin/tabs/dead/exit
	if await popup.popup_return == "yes":
		$snd_exit.play()
		$center/panel/margin/tabs/popup/hBox/yes.release_focus()
		await $snd_exit.finished
		get_tree().quit()
	else:
		$snd_back.play()
		tab.current_tab = tabs["main" if main else "dead"]

func _on_back_pressed(main := true):
	$snd_back.play()
	tab.current_tab = tabs["main" if main else "dead"]

func _on_restart_pressed():
	$snd_game.play()
	await $snd_game.finished
	get_tree().reload_current_scene()

func _on_visibility_changed():
	if not dead and is_inside_tree() \
	and get_tree() != null:
		get_tree().paused = visible
		if not visible:
			tab.current_tab = tabs["main"]
			prev_tab = $center/panel/margin/tabs/main/resume_game

func _on_main_draw():
	play_focus_sfx = false
	prev_tab.grab_focus()
	play_focus_sfx = true

func show_death_screen(player_health: int):
	if player_health == 0:
		$snd_pause.play()
		dead = true
		prev_tab = $center/panel/margin/tabs/dead/restart
		tab.current_tab = tabs["dead"]
		show()

func next_level(prompt: bool, next_level_scene: PackedScene, level: int):
	level_transition = prompt
	visible = prompt
	if prompt:
		popup.display("Go Next Level?!", "Go", "Stay")
		tab.current_tab = tabs["popup"]
		if await popup.popup_return == "yes":
			LevelQuery.unlock_level(level - 1)
			get_tree().paused = false
			get_tree().change_scene_to_packed(next_level_scene)
		else:
			$snd_back.play()
			hide()
