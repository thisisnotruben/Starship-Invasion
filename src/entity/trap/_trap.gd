extends IToggleable
class_name Trap

enum Type { ACTIVATE, PROXIMITY, TIME_INTERVAL, AUTOSTART }
@export var activate_type := Type.PROXIMITY
@export_range(1, 20) var damage: int = 1
@export_category("Time Interval")
@export_range(3.0, 60.0) var time_to_activate := 15.0
@export_range(3.0, 60.0) var time_cooldown := 5.0


func _ready():
	match activate_type:
		Type.AUTOSTART:
			toggle(true)
		Type.TIME_INTERVAL:
			$timer_interval.start(time_to_activate)

func _on_timer_interval_timeout():
	if activate_type == Type.TIME_INTERVAL:
		$timer_cooldown.start(time_cooldown)
		toggle(true)

func _on_timer_cooldown_timeout():
	if activate_type == Type.TIME_INTERVAL:
		$timer_interval.start(time_to_activate)
		toggle(false)

func _on_timer_timeout():
	$area3D.get_overlapping_bodies().map(hurt)

func _on_activate_sight_body_entered(body: Node3D):
	if activate_type == Type.PROXIMITY and body is Character:
		toggle(true)

func _on_activate_sight_body_exited(body: Node3D):
	if activate_type == Type.PROXIMITY and body is Character:
		toggle(false)

func _on_area_3d_body_entered(body: Node3D):
	hurt(body)

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

func _on_visibility_screen_entered():
	pass # Replace with function body.

func _on_visibility_screen_exited():
	pass # Replace with function body.
