extends Control

@export var game_menu: Control = null
@export var can_show := true
var showing := false


func start():
	if LevelQuery.first_played_level() and can_show:
		showing = true
		$anim.play("fade")
		await $anim.animation_finished
		showing = false
		hide()
	else:
		hide()

func _on_game_visibility_changed():
	if showing:
		visible = not game_menu.visible

func _on_visibility_changed():
	get_tree().paused = visible
