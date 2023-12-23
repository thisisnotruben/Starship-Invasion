extends IToggleable

@export var o2_timer: Timer = null
@onready var cooldown_timer: Timer = $cooldown_timer


func toggle(activate: bool):
	if cooldown_timer.time_left == 0.0:
		super.toggle(activate)
		if o2_timer.time_left > 0.0:
			o2_timer.start(o2_timer.wait_time)
		cooldown_timer.start()
