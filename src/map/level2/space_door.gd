extends IToggleable

@export var door_int: IToggleable = null
@export var door_ext: IToggleable = null

var door1 := false
var door2 := false

func _ready():
	if door_int != null:
		door_int.toggled.connect(func(a): door1 = not a)
	if door_ext != null:
		door_ext.toggled.connect(func(a): door2 = not a)

func toggle(activate: bool):
	super.toggle(activate)
	door_ext.toggle(activate)
	door_int.toggle(not activate)
