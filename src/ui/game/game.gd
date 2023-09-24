extends Control

@onready var popup: Control = $center/panel/margin/tabs/popup
@onready var snd: AudioStreamPlayer = $snd
@onready var tab: TabContainer = $center/panel/margin/tabs
var tabs := {"main": 0, "license": 1, "credits": 2, "popup": 3}


func _input(event: InputEvent):
	if event.is_action_pressed("pause"):
		snd.play()
		visible = !visible

func _on_resume_game_pressed():
	snd.play()
	hide()

func _on_start_menu_pressed():
	snd.play()
	popup.display("Go to Start Menu?", "Go", "Stay")
	tab.current_tab = tabs["popup"]
	if await popup.popup_return == "yes":
		snd.play()
		$loader.start("res://src/ui/start/start.tscn")
	else:
		snd.play()
		tab.current_tab = tabs["main"]

func _on_license_pressed():
	snd.play()
	tab.current_tab = tabs["license"]

func _on_credits_pressed():
	snd.play()
	tab.current_tab = tabs["credits"]

func _on_exit_pressed():
	snd.play()
	popup.display("Exit Game?", "Exit", "Stay")
	tab.current_tab = tabs["popup"]
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

func _on_main_draw():
	$center/panel/margin/tabs/main/resume_game.grab_focus()

func _on_loader_done_loading(packed_scene: PackedScene):
	var root = get_tree().root
	queue_free()
	await self.tree_exited
	var scene = packed_scene.instantiate()
	root.add_child(scene)
