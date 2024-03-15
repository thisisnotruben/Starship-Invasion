extends Control

static var shown := false

@export var game_menu: Control = null
@export var can_show := true
var showing := false


func start():
	if LevelQuery.first_played_level() and can_show and not shown:
		shown = true
		showing = true
		$anim.play("fade")
		await $anim.animation_finished
		showing = false
	hide()

func _on_game_visibility_changed():
	if showing:
		visible = not game_menu.visible

func _on_visibility_changed():
	get_tree().paused = visible

func level4_start():
	var countdown: CountDown = get_tree() \
		.get_first_node_in_group("countdown")
	if countdown != null:
		countdown.start()
