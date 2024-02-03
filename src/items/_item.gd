extends Node3D
class_name Item

enum Type {
	HEALTH,
	ARMOR,
	BLUE_KEYCARD,
	GREEN_KEYCARD,
	RED_KEYCARD,
	YELLOW_KEYCARD
}

@export var type := Type.HEALTH
@export var hud_image: Texture = null


func _on_area_3d_body_entered(body: Node3D):
	if body is Character and not body.npc:
		match type:
			Type.HEALTH:
				body.health += 1
			Type.ARMOR:
				pass
			_:
				body.inventory_add({"type": type,
					"icon": hud_image, "add": true})
		$snd.play()
		await $snd.finished
		queue_free()
