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
			"path": "toggles/space-walk",
			"completed": false,
			"blurb": "Space walk to reach other side of ship.",
			"type": Type.TRAVERSE,
			"name": "space-walk"
		},
		{
			"path": "items/red-keycard",
			"completed": false,
			"blurb": "Collect red keycard to unlock door.",
			"type": Type.COLLECT,
			"name" : Item.Type.RED_KEYCARD
		},
		{
			"path": "toggles/toggle-computer3/Marker3D",
			"completed": false,
			"blurb": "Enter terminal to unlock door.",
			"type": Type.INTERACT,
			"name": "toggle-computer3"
		}
	]
