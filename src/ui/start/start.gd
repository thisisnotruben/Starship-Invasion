extends Control

@onready var snd: AudioStreamPlayer = $snd
@onready var tab: TabContainer = $center/panel/margin/tabs
var tabs := {"main": 0, "difficulty": 1, "license": 2, "credits": 3}


func _on_start_pressed():
	snd.play()
	tab.current_tab = tabs["difficulty"]

func _on_license_pressed():
	snd.play()
	tab.current_tab = tabs["license"]

func _on_credits_pressed():
	snd.play()
	tab.current_tab = tabs["credits"]

func _on_exit_pressed():
	get_tree().quit()

func _on_difficulty_mode_pressed(difficulty_mode: String):
	var payload := {}
	match difficulty_mode:
		"easy":
			pass
		"medium":
			pass
		"hard":
			pass
	
	snd.play()
	$loader.start("res://src/map/level1.tscn")

func _on_back_pressed():
	snd.play()
	tab.current_tab = tabs["main"]
	
func _on_main_draw():
	$center/panel/margin/tabs/main/start.grab_focus()

func _on_difficulty_draw():
	$center/panel/margin/tabs/difficulty/easy.grab_focus()

func _on_loader_done_loading(packed_scene: PackedScene):
	var root = get_tree().root
	queue_free()
	await self.tree_exited
	var scene = packed_scene.instantiate()
	root.add_child(scene)
