extends VBoxContainer

const SAVE_PATH := "user://overmind_settings.cfg"
const VERSION := 1

const bus_layout := {"music": 1, "sfx": 2}
static var max_volume_music := AudioServer.get_bus_volume_db(bus_layout["music"])
static var max_volume_sfx := AudioServer.get_bus_volume_db(bus_layout["sfx"])

var play_focus_sfx := false
var on_init_volume := true
@onready var music: HSlider = $tabs_container/volume/music_volume
@onready var sfx: HSlider = $tabs_container/volume/sfx_volume
@onready var lens_dis: BaseButton = $tabs_container/shader/lens_distortion_check
@onready var grain: BaseButton = $tabs_container/shader/grain_check
@onready var tv: BaseButton = $tabs_container/shader/tv_check
@onready var keyboard_sens : HSlider = $tabs_container/sensitivity/keyboard_sens
@onready var joystick_sens : HSlider = $tabs_container/sensitivity/joystick_sens
var tabs := {"volume": 0, "shader": 1, "sensitivity": 2}

static var dirty_values := {}

signal back_pressed
signal subcontrol_focused


func _ready():
	var is_clean := dirty_values.is_empty()
	music.max_value = max_volume_music
	sfx.max_value = max_volume_sfx
	on_init_volume = false
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

func _on_volume_toggled(button_pressed: bool):
	#var other_tabs := [$tabs/shader, $tabs/sensitivity]
	#other_tabs.map(func(b): b.set_block_signals(true))
	#other_tabs.map(func(b): b.button_pressed = !button_pressed)
	$tabs/shader.grab_focus()
	$tabs_container.current_tab = tabs["volume"]
	$tabs/volume.disabled = button_pressed
	#other_tabs.map(func(b): b.set_block_signals(false))

func _on_shader_toggled(button_pressed: bool):
	#var other_tabs := [$tabs/volume, $tabs/sensitivity]
	#other_tabs.map(func(b): b.set_block_signals(true))
	#other_tabs.map(func(b): b.button_pressed = !button_pressed)
	$tabs/sensitivity.grab_focus()
	$tabs_container.current_tab = tabs["shader"]
	$tabs/shader.disabled = button_pressed
	#other_tabs.map(func(b): b.set_block_signals(false))

func _on_sensitivity_toggled(button_pressed: bool):
	#var other_tabs := [$tabs/volume, $tabs/shader]
	#other_tabs.map(func(b): b.set_block_signals(true))
	#other_tabs.map(func(b): b.button_pressed = !button_pressed)
	$tabs/volume.grab_focus()
	$tabs_container.current_tab = tabs["sensitivity"]
	$tabs/sensitivity.disabled = button_pressed
	#other_tabs.map(func(b): b.set_block_signals(false))

func _on_music_volume_value_changed(value: float):
	if not on_init_volume:
		AudioServer.set_bus_volume_db(bus_layout["music"], value)
		dirty_values["music"] = value

func _on_sfx_volume_value_changed(value: float):
	if not on_init_volume:
		AudioServer.set_bus_volume_db(bus_layout["sfx"], value)
		dirty_values["sfx"] = value

func _on_lens_distortion_check_toggled(button_pressed: bool):
	_toggle("lens_dis", button_pressed)

func _on_grain_check_toggled(button_pressed: bool):
	_toggle("grain", button_pressed)

func _on_tv_check_toggled(button_pressed: bool):
	_toggle("tv", button_pressed)

func _on_keyboard_sens_value_changed(value: float):
	dirty_values["keyboard_sens"] = value

func _on_joystick_sens_value_changed(value: float):
	dirty_values["joystick_sens"] = value

func _on_save_pressed():
	$snd_save.play()
	var config := ConfigFile.new()
	config.set_value("general", "version", VERSION)
	config.set_value("settings", "music", music.value)
	config.set_value("settings", "sfx", sfx.value)
	config.set_value("settings", "lens_dis", lens_dis.button_pressed)
	config.set_value("settings", "grain", grain.button_pressed)
	config.set_value("settings", "tv", tv.button_pressed)
	config.set_value("settings", "keyboard_sens", keyboard_sens.value)
	config.set_value("settings", "joystick_sens", joystick_sens.value)
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
			"keyboard_sens":
				keyboard_sens.value = payload[key]
			"joystick_sens":
				joystick_sens.value = payload[key]
