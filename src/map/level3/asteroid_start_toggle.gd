extends ComputerToggle

@export var current_characters: Array[Character] = []


func _ready():
	for character in current_characters:
		character.died.connect(_remove_character)

func _input(event: InputEvent):
	if event.is_action_pressed("interact") and _player != null \
	and disabled and current_characters.is_empty():
		disabled = false
	super._input(event)

func _remove_character(character: Character):
	current_characters.erase(character)
