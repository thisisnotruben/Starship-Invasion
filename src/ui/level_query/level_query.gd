extends Node
class_name LevelQuery

const SAVE_PATH := "user://starship_invasion.cfg"
const VERSION := 1

static var unlocked_levels := [false, false, false, false]


static func _static_init():
	load_level()

static func unlock_level(level: int):
	if is_locked(level):
		unlocked_levels[level - 1] = true
		save_level()

static func is_locked(level: int) -> bool:
	return unlocked_levels.size() >= level and not unlocked_levels[level - 1]

static func have_played() -> bool:
	return unlocked_levels.any(func(l): return l)

static func finished_last_level() -> bool:
	return unlocked_levels[-1]

static func first_played_level() -> bool:
	return unlocked_levels.count(true) == 1

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
