extends Control


func _on_credits_back_pressed():
	get_tree().quit()

func _on_start_menu_pressed():
	get_tree().change_scene_to_file("res://src/ui/start/start.tscn")
