extends Control
class_name DialogueMenu

@onready var label: RichTextLabel = $center/panel/margin/VBoxContainer/richTextLabel
@onready var continue_bttn: Button = $center/panel/margin/VBoxContainer/continue
@onready var snd: AudioStreamPlayer = $snd

@export var game_menu: Control = null

@export_category("Sound")
@export var snd_library: Array[AudioStream] = []
@export var play_snd := false
@export_range(0.0, 5.0) var pause_between_audio := 0.25

@export_category("Behavior")
@export var dialogue_tree: DialogueTree = null
@export_range(0.01, 1.0) var character_speed = 0.045
@export var pause_when_shown := true
@export var emit_dialogue_finished_signal := true

var active := false
var shown := false
var bttn_focused := false
var show_and_hide := false

signal dialogue_finished


func start_dialogue(idx: int, _show_and_hide := true):
	if dialogue_tree == null or idx >= dialogue_tree.dialogues.size():
		return
	show_and_hide = _show_and_hide
	shown = true
	bttn_focused = false
	continue_bttn.hide()

	var dialogue: String = dialogue_tree.dialogues[idx]
	var play_length: float = dialogue.length() * character_speed
	label.text = dialogue
	label.visible_ratio = 0.0

	if show_and_hide:
		show()
	if play_snd and not snd_library.is_empty():
		snd.stream = snd_library.pick_random()
		snd.play()

	active = true
	var tween := get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	await tween.tween_property(label, \
		"visible_ratio", 1.0, play_length).finished
	active = false
	bttn_focused = true
	continue_bttn.show()
	continue_bttn.grab_focus()
	$snd_nav.play()

func _on_snd_finished():
	if active and not is_zero_approx(pause_between_audio):
		await get_tree().create_timer(pause_between_audio).timeout
		if active:
			snd_library.shuffle()
			snd.stream = snd_library.pick_random()
			snd.play()

func _on_continue_pressed():
	if emit_dialogue_finished_signal:
		emit_signal("dialogue_finished")
	shown = false
	bttn_focused = false
	if show_and_hide:
		if pause_when_shown:
			get_tree().paused = false
		hide()

func _on_game_visibility_changed():
	if shown and game_menu != null:
		visible = not game_menu.visible
		if visible and bttn_focused:
			continue_bttn.grab_focus()

func _on_draw():
	if pause_when_shown:
		get_tree().paused = visible
