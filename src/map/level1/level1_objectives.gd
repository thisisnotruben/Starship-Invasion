extends ObjectiveMap


func _init():
	objectives = [
		{
			"path": "characters/Space Warrior Gold",
			"path2": "characters/YELLOW_KEYCARD",
			"completed": false,
			"blurb": "Collect yellow keycard to unlock door to master terminal.",
			"type": Type.KILL_COLLECT,
			"name" : Item.Type.YELLOW_KEYCARD
		},
		{
			"path": "toggles/toggle-computer-2",
			"completed": false,
			"blurb": "Enter terminal to unlock door.",
			"type": Type.INTERACT,
			"name": "toggle-computer-2"
		},
		{
			"path": "items/red-keycard",
			"completed": false,
			"blurb": "Collect red keycard to unlock door to final area.",
			"type": Type.COLLECT,
			"name" : Item.Type.RED_KEYCARD
		},
		{
			"path": "nav/props/ladder/level_transition",
			"completed": false,
			"blurb": "Exit and complete level.",
			"type": Type.INTERACT,
			"name": "level_transition"
		},
	]
