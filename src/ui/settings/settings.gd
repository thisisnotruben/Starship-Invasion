extends VBoxContainer

@onready var music: ProgressBar = $margin1/vBox/music_volume
@onready var sfx: ProgressBar = $margin1/vBox/sfx_volume
@onready var lens_dis: BaseButton = $margin2/grid/lens_distortion_check
@onready var grain: BaseButton = $margin2/grid/grain_check
@onready var tv: BaseButton = $margin2/grid/tv_check

signal back_pressed

const save_path := "user://overmind_settings.cfg"


func _on_back_pressed():
	emit_signal("back_pressed")

func _on_draw():
	$back.grab_focus()

func _on_save_pressed():
	var config := ConfigFile.new()
	config.set_value("general", "version", 1)
	config.set_value("settings", "music", music.value)
	config.set_value("settings", "sfx", sfx.value)
	config.set_value("settings", "lens_dis", lens_dis.button_pressed)
	config.set_value("settings", "grain", grain.button_pressed)
	config.set_value("settings", "tv", tv.button_pressed)
	config.save(save_path)

func load_settings():
	var config := ConfigFile.new()
	if config.load(save_path) != OK:
		return
		
	music.value = config.get_value("settings", "music", music.value)
	sfx.value = config.get_value("settings", "sfx", sfx.value)
	lens_dis.button_pressed = config.get_value("settings", "lens_dis", lens_dis.button_pressed)
	grain.button_pressed = config.get_value("settings", "grain", grain.button_pressed)
	tv.button_pressed = config.get_value("settings", "tv", tv.button_pressed)
