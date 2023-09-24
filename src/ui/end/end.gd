extends Control


func _on_credits_back_pressed():
	get_tree().quit()

func _on_start_menu_pressed():
	$loader.start("res://src/ui/start/start.tscn")

func _on_loader_done_loading(packed_scene: PackedScene):
	var root = get_tree().root
	queue_free()
	await self.tree_exited
	var scene = packed_scene.instantiate()
	root.add_child(scene)
