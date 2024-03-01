extends Node
class_name LevelQuery

const SAVE_PATH := "user://starship_invasion.cfg"
const VERSION := 1

static var unlocked_levels := [true, false, false, false]


static func _static_init():
	load_level()

static func unlock_level(level: int):
	if is_locked(level):
		unlocked_levels[level] = true
		save_level()

static func is_locked(level: int):
	return unlocked_levels.size() > level and not unlocked_levels[level]

static func save_level():
	var config := ConfigFile.new()
	config.set_value("general", "version", VERSION)
	config.set_value("unlocked_levels", "levels", unlocked_levels)
	config.save(SAVE_PATH)

static func load_level():
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		unlocked_levels = config.get_value("unlocked_levels", "levels", \
			[true, false, false, false])
