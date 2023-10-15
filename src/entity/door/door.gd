extends IToggleable
class_name Door

enum Type{ ACTIVATE, PROXIMITY }
@export var type: Type = Type.PROXIMITY
@export var door_nav: NavigationRegion3D = null


func _ready():
	if door_nav == null:
		print_debug("[%s] doesn't have set value: 'door_nav'." % get_path())

func _on_area_3d_body_entered(body: Node3D):
	if _can_access(body):
		toggle(true)

func _on_area_3d_body_exited(body: Node3D):
	if _can_access(body):
		toggle(false)

func _on_animated_sprite_3d_animation_finished():
	$collisionShape3D.set_deferred("disabled", bool($img.frame_progress))
	if door_nav != null:
		door_nav.set_deferred("enabled", not bool($img.frame_progress))

func _can_access(body: Node3D) -> bool:
	return type == Type.PROXIMITY and body is Character and not body.npc

func toggle(open: bool):
	$snd.play()
	$img.play("default", 1.0, not open)
	if not open:
		$collisionShape3D.set_deferred("disabled", false)
