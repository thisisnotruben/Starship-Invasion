extends VBoxContainer
class_name Settings

# File data
const SAVE_PATH := "user://overmind_settings.cfg"
const VERSION := 1

# Audio
const bus_layout := {"music": 1, "sfx": 2}
static var max_volume_music := AudioServer.get_bus_volume_db(bus_layout["music"])
static var max_volume_sfx := AudioServer.get_bus_volume_db(bus_layout["sfx"])

# Sensitivity
static var mouse_sens := 0.004
static var joy_sens := 0.06
static var brightness_level := 1.5

var play_focus_sfx := false
var on_init := true
@onready var brightness_level_slider: HSlider = $tabs_container/visual/brightness/brightness_level
@onready var lens_dis: BaseButton = $tabs_container/visual/shader/hBox/lens_distortion_check
@onready var grain: BaseButton = $tabs_container/visual/shader/hBox/grain_check
@onready var tv: BaseButton = $tabs_container/visual/shader/hBox/tv_check
@onready var music: HSlider = $tabs_container/audio/music_volume
@onready var sfx: HSlider = $tabs_container/audio/sfx_volume
@onready var mouse_sens_slider : HSlider = $tabs_container/sensitivity/mouse_sens
@onready var joystick_sens_slider : HSlider = $tabs_container/sensitivity/joystick_sens
@onready var disabled_tab: BaseButton = $tabs/visual
var tabs := {"audio": 1, "visual": 0, "sensitivity": 2}

static var dirty_values := {}

signal back_pressed
signal subcontrol_focused


func _ready():
	var is_clean := dirty_values.is_empty()
	music.max_value = max_volume_music
	sfx.max_value = max_volume_sfx
	brightness_level_slider.value = brightness_level
	mouse_sens_slider.value = mouse_sens
	joystick_sens_slider.value = joy_sens
	on_init = false
	if is_clean:
		_load_settings()
	else:
		_set_settings(dirty_values)

func _on_back_pressed():
	emit_signal("back_pressed")

func _on_visibility_changed():
	if visible:
		play_focus_sfx = false
		$back.grab_focus()
		play_focus_sfx = true

func _on_focus_entered():
	if play_focus_sfx:
		emit_signal("subcontrol_focused")

func _on_shader_pressed():
	$tabs_container.current_tab = tabs["visual"]
	_handle_tabs($tabs/visual)
	$tabs/audio.grab_focus()

func _on_volume_pressed():
	$tabs_container.current_tab = tabs["audio"]
	_handle_tabs($tabs/audio)
	$tabs/sensitivity.grab_focus()

func _on_sensitivity_pressed():
	$tabs_container.current_tab = tabs["sensitivity"]
	_handle_tabs($tabs/sensitivity)
	$tabs/visual.grab_focus()

func _handle_tabs(button: BaseButton):
	button.disabled = true
	disabled_tab.disabled = false
	disabled_tab = button

func _on_brightness_level_value_changed(value: float):
	if not on_init:
		get_tree().get_nodes_in_group("world_env").map( \
			func(w): w.environment.adjustment_brightness = value)
		dirty_values["brightness"] = value

func _on_lens_distortion_check_toggled(button_pressed: bool):
	_toggle("lens_dis", button_pressed)

func _on_grain_check_toggled(button_pressed: bool):
	_toggle("grain", button_pressed)

func _on_tv_check_toggled(button_pressed: bool):
	_toggle("tv", button_pressed)

func _on_music_volume_value_changed(value: float):
	if not on_init:
		AudioServer.set_bus_volume_db(bus_layout["music"], value)
		dirty_values["music"] = value

func _on_sfx_volume_value_changed(value: float):
	if not on_init:
		AudioServer.set_bus_volume_db(bus_layout["sfx"], value)
		dirty_values["sfx"] = value

func _on_mouse_sens_value_changed(value: float):
	dirty_values["mouse_sens"] = value
	mouse_sens = value

func _on_joystick_sens_value_changed(value: float):
	dirty_values["joy_sens"] = value
	joy_sens = value

func _on_reset_pressed():
	$snd_save.play()
	_set_settings({"music": 0.0, "sfx": 0.0, \
		"lens_dis": false, "grain": false, "tv": false, \
		"mouse_sens": 0.004, "joy_sens": 0.06, "brightness": 1.5})

func _on_save_pressed():
	$snd_save.play()
	var config := ConfigFile.new()
	config.set_value("general", "version", VERSION)
	config.set_value("settings", "brightness", brightness_level_slider.value)
	config.set_value("settings", "lens_dis", lens_dis.button_pressed)
	config.set_value("settings", "grain", grain.button_pressed)
	config.set_value("settings", "tv", tv.button_pressed)
	config.set_value("settings", "music", music.value)
	config.set_value("settings", "sfx", sfx.value)
	config.set_value("settings", "mouse_sens", mouse_sens_slider.value)
	config.set_value("settings", "joy_sens", joystick_sens_slider.value)
	config.save(SAVE_PATH)

func _load_settings():
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		var load_data := {}
		for key in config.get_section_keys("settings"):
			load_data[key] = config.get_value("settings", key)
		_set_settings(load_data)

func _toggle(effect: String, on: bool):
	get_tree().get_nodes_in_group(effect).map(func(e): e.visible = on)
	dirty_values[effect] = on

func _set_settings(payload: Dictionary):
	for key in payload:
		match key:
			"music":
				music.value = payload[key]
			"sfx":
				sfx.value = payload[key]
			"lens_dis":
				lens_dis.button_pressed = payload[key]
			"grain":
				grain.button_pressed = payload[key]
			"tv":
				tv.button_pressed = payload[key]
			"mouse_sens":
				mouse_sens_slider.value = payload[key]
			"joy_sens":
				joystick_sens_slider.value = payload[key]
			"brightness":
				brightness_level_slider.value = payload[key]
