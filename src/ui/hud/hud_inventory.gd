extends TextureRect

@onready var label: Label = $label
var timer: Timer = null


func init(data: Dictionary):
	texture = data["icon"]
	if data["powerup"] != null:
		timer = data["powerup"].timer
		data["powerup"].tree_exiting.connect(func(): set_process(false))
		data["character"].died.connect(func(_c): set_process(false))
	return self

func _ready():
	set_process(timer != null)

func _process(_delta: float):
	var minutes: int = floor(timer.time_left / 60.0)
	if minutes > 0:
		label.text = "%d:%02d" % [minutes, int(timer.time_left) % 60]
	else:
		label.text = "%02d" % (int(timer.time_left) % 60)
