extends Control

@export var game_menu: Control = null

var showing := false

func _ready():
	if LevelQuery.first_played_level():
		showing = true
		$anim.play("fade")
		await $anim.animation_finished
		showing = false
	else:
		hide()

func _on_game_visibility_changed():
	if showing:
		visible = not game_menu.visible
