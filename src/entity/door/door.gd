extends IToggleable
class_name Door

enum Type{ ACTIVATE, PROXIMITY }
@export var type: Type = Type.PROXIMITY

signal door_activated(opened: bool)


func _on_area_3d_body_entered(body: Node3D):
	if _can_access(body):
		toggle(true)

func _on_area_3d_body_exited(body: Node3D):
	if _can_access(body):
		toggle(false)

func _can_access(body: Node3D) -> bool:
	return type == Type.PROXIMITY and body is Character and not body.npc

func toggle(open: bool):
	super.toggle(open)
	if open:
		$anim.play("open")
	else:
		$anim.play("close")

func _on_anim_animation_finished(anim_name: String):
	emit_signal("door_activated", anim_name == "open")
