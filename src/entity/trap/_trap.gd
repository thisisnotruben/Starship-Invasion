extends IToggleable
class_name Trap

enum Type { ACTIVATE, PROXIMITY, TIME_INTERVAL, AUTOSTART }
@export var activate_type := Type.PROXIMITY
@export_range(1, 20) var damage: int = 1
@export_category("Time Interval")
@export_range(3.0, 60.0) var time_to_activate := 15.0
@export_range(3.0, 60.0) var time_cooldown := 5.0
@export_category("Time Interval Random")
@export var time_int_ran := false
@export_range(0.0, 0.5) var rand_amount := 0.25

@onready var img: AnimatedSprite3D = $img
@onready var timer: Timer = $timer
@onready var visibility: VisibleOnScreenNotifier3D = $visibility


func _on_timer_interval_timeout():
	if activate_type == Type.TIME_INTERVAL:
		$timer_cooldown.start(time_cooldown)
		toggle(true)

func _on_timer_cooldown_timeout():
	if activate_type == Type.TIME_INTERVAL:
		$timer_interval.start(_get_rand_amount())
		toggle(false)

func _on_timer_timeout():
	$area3D.get_overlapping_bodies().map(hurt)

func _on_visibility_screen_entered():
	set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
	match activate_type:
		Type.AUTOSTART:
			toggle(true)
		Type.TIME_INTERVAL:
			$timer_interval.start(_get_rand_amount())

func _on_visibility_screen_exited():
	set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	if activated:
		toggle(false)

func _on_activate_sight_body_entered(body: Node3D):
	if activate_type == Type.PROXIMITY \
	and body is Character and visibility.is_on_screen():
		toggle(true)

func _on_activate_sight_body_exited(body: Node3D):
	if activate_type == Type.PROXIMITY \
	and body is Character and activated:
		toggle(false)

func _on_area_3d_body_entered(body: Node3D):
	hurt(body)
	timer.start()

func hurt(body: Node3D):
	if body is Character:
		body.health -= damage

func toggle(activate: bool):
	super.toggle(activate)
	$area3D/collisionShape3D.set_deferred("disabled", not activate)
	if activate:
		$snd.play()
		$timer.start()
	else:
		$snd.stop()
		$timer.stop()

func _get_rand_amount() -> float:
	var timer_sec := time_to_activate
	if time_int_ran:
		if randi_range(0, 1) == 1:
			timer_sec *= (1.0 + rand_amount)
		else:
			timer_sec *= (1.0 - rand_amount)
	return timer_sec
