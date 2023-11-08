extends Control

@export var player: Character = null
@export var game_menu: Control = null

@onready var tab: TabContainer = $center/panel/margin/tabs
@onready var popup: Control = $center/panel/margin/tabs/popup
@onready var prev_tab: Control = $center/panel/margin/tabs/vBox/restart

var play_focus_sfx := false
var tabs := {"main": 0, "popup": 1}

signal subcontrol_focused


func _ready():
	if player != null:
		player.connect("health_changed", func(h): visible = h == 0)

func _on_draw():
	if game_menu != null:
		game_menu.queue_free()

func _on_v_box_draw():
	play_focus_sfx = false
	prev_tab.grab_focus()
	play_focus_sfx = true

func _on_focus_entered():
	if play_focus_sfx:
		$snd_nav.play()

func _on_restart_pressed():
	$snd_game.play()
	await $snd_game.finished
	get_tree().reload_current_scene()

func _on_start_menu_pressed():
	$snd_popup.play()
	popup.display("Go to Start Menu?", "Go", "Stay")
	tab.current_tab = tabs["popup"]
	prev_tab = $center/panel/margin/tabs/vBox/start_menu
	if await popup.popup_return == "yes":
		$snd_start.play()
		await $snd_start.finished
		get_tree().change_scene_to_file("res://src/ui/start/start.tscn")
	else:
		$snd_back.play()
		tab.current_tab = tabs["main"]

func _on_exit_pressed():
	$snd_popup.play()
	popup.display("Exit Game?", "Exit", "Stay")
	tab.current_tab = tabs["popup"]
	prev_tab = $center/panel/margin/tabs/vBox/exit
	if await popup.popup_return == "yes":
		$snd_exit.play()
		await $snd_exit.finished
		get_tree().quit()
	else:
		$snd_back.play()
		tab.current_tab = tabs["main"]
