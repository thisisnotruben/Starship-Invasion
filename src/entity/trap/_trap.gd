extends IToggleable
class_name Trap

enum Type { ACTIVATE, PROXIMITY, TIME }
@export var activate_type := Type.PROXIMITY
@export_range(10.0, 60.0) var time_to_activate := 15.0
@export_range(1, 20) var damage: int = 1


func _ready():
	if activate_type == Type.TIME:
		$timer_chance.start(time_to_activate)

func _on_timer_chance_timeout():
	if activate_type == Type.TIME:
		toggle(true)

func _on_timer_timeout():
	var bodies: Array[Node3D] = $area3D.get_overlapping_bodies()
	if bodies.is_empty():
		$timer.stop()
	else:
		bodies.map(hurt)

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
		$timer.start()

func toggle(activate: bool):
	$area3D/collisionShape3D.set_deferred("disabled", not activate)
	if activate:
		$snd.play()
	else:
		$snd.stop()
