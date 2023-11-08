extends VBoxContainer

const SAVE_PATH := "user://overmind_settings.cfg"
const VERSION := 1
static var dirty := false

var play_focus_sfx := false
@onready var music: ProgressBar = $margin1/vBox/music_volume
@onready var sfx: ProgressBar = $margin1/vBox/sfx_volume
@onready var lens_dis: BaseButton = $margin2/grid/lens_distortion_check
@onready var grain: BaseButton = $margin2/grid/grain_check
@onready var tv: BaseButton = $margin2/grid/tv_check

signal back_pressed
signal subcontrol_focused


func _on_back_pressed():
	emit_signal("back_pressed")

func _on_draw():
	play_focus_sfx = false
	$back.grab_focus()
	play_focus_sfx = true

func _on_focus_entered():
	if play_focus_sfx:
		emit_signal("subcontrol_focused")

func _on_save_pressed():
	var config := ConfigFile.new()
	config.set_value("general", "version", VERSION)
	config.set_value("settings", "music", music.value)
	config.set_value("settings", "sfx", sfx.value)
	config.set_value("settings", "lens_dis", lens_dis.button_pressed)
	config.set_value("settings", "grain", grain.button_pressed)
	config.set_value("settings", "tv", tv.button_pressed)
	config.save(SAVE_PATH)

func load_settings() -> bool:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return false
		
	music.value = config.get_value("settings", "music", music.value)
	sfx.value = config.get_value("settings", "sfx", sfx.value)
	lens_dis.button_pressed = config.get_value("settings", "lens_dis", lens_dis.button_pressed)
	grain.button_pressed = config.get_value("settings", "grain", grain.button_pressed)
	tv.button_pressed = config.get_value("settings", "tv", tv.button_pressed)
	return true

func set_settings():
	for music_player in get_tree().get_nodes_in_group("music"):
		pass
	for sfx_player in get_tree().get_nodes_in_group("sfx"):
		pass
	for lens_dis_effect in get_tree().get_nodes_in_group("lens_dis"):
		lens_dis_effect.visible = lens_dis.button_pressed
	for grain_effect in get_tree().get_nodes_in_group("grain"):
		grain_effect.visible = grain.button_pressed
	for tv_effect in get_tree().get_nodes_in_group("tv"):
		tv_effect.visible = tv.button_pressed
