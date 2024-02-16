extends ObjectiveMap


func _init():
	objectives = [
		{
			"path": "items/green-keycard",
			"completed": false,
			"blurb": "Collect green keycard to unlock door.",
			"type": Type.COLLECT,
			"name" : Item.Type.GREEN_KEYCARD
		},
		{
			"path": "items/blue-keycard",
			"completed": false,
			"blurb": "Collect blue keycard to unlock door.",
			"type": Type.COLLECT,
			"name" : Item.Type.BLUE_KEYCARD
		},
		{
			"path": "asteroid_shooter/toggle-computer",
			"completed": false,
			"blurb": "Enter terminal to override the ship defence system.",
			"type": Type.INTERACT,
			"name": "toggle-computer"
		},
		{
			"path": "characters/Space Warrior Gold9",
			"path2": "characters/RED_KEYCARD",
			"completed": false,
			"blurb": "Collect red keycard to unlock door to master terminal.",
			"type": Type.KILL_COLLECT,
			"name" : Item.Type.RED_KEYCARD
		},
		{
			"path": "nav/props/ladder/level_transition",
			"completed": false,
			"blurb": "Exit and complete level.",
			"type": Type.INTERACT,
			"name": "level_transition"
		}
	]
