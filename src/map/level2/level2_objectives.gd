extends ObjectiveMap


func _init():
	objectives = [
		{
			"path": "items/blue-keycard",
			"completed": false,
			"blurb": "Collect blue keycard to unlock door.",
			"type": Type.COLLECT,
			"name" : Item.Type.BLUE_KEYCARD
		},
		{
			"path": "toggles/toggle-computer-blue-keycard/Marker3D",
			"completed": false,
			"blurb": "Enter terminal to unlock door.",
			"type": Type.INTERACT,
			"name": "toggle-computer-blue-keycard"
		},
		{
			"path": "items/green-keycard",
			"completed": false,
			"blurb": "Collect green keycard to unlock door.",
			"type": Type.COLLECT,
			"name" : Item.Type.GREEN_KEYCARD
		},
		{
			"path": "toggles/toggle-computer-1",
			"completed": false,
			"blurb": "Enter terminal to unlock door.",
			"type": Type.INTERACT,
			"name": "toggle-computer-1"
		},
		{
			"path": "items/red-keycard",
			"completed": false,
			"blurb": "Collect red keycard to unlock door.",
			"type": Type.COLLECT,
			"name" : Item.Type.RED_KEYCARD
		},
		{
			"path": "toggles/toggle-computer-red-keycard/Marker3D",
			"completed": false,
			"blurb": "Enter terminal to unlock door.",
			"type": Type.INTERACT,
			"name": "toggle-computer-red-keycard"
		},
		{
			"path": "toggles/space-walk",
			"completed": false,
			"blurb": "Space walk to reach other side of ship.",
			"type": Type.TRAVERSE,
			"name": "space-walk"
		},
		{
			"path": "items/yellow-keycard",
			"completed": false,
			"blurb": "Collect yellow keycard to unlock door.",
			"type": Type.COLLECT,
			"name" : Item.Type.YELLOW_KEYCARD
		},
		{
			"path": "toggles/toggle-computer3-yellow-keycard/Marker3D",
			"completed": false,
			"blurb": "Enter terminal to unlock door.",
			"type": Type.INTERACT,
			"name": "toggle-computer3-yellow-keycard"
		},
		{
			"path": "nav/props/ladder/level_transition",
			"completed": false,
			"blurb": "Exit and complete level.",
			"type": Type.INTERACT,
			"name": "level_transition"
		}
	]
