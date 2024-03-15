extends Node3D
class_name Item

enum Type {
	HEALTH,
	ARMOR,
	BLUE_KEYCARD,
	GREEN_KEYCARD,
	RED_KEYCARD,
	YELLOW_KEYCARD,
	GUN
}

@export var type := Type.HEALTH
@export var hud_image: Texture = null


func _on_area_3d_body_entered(body: Node3D):
	if body is Character and not body.npc:
		match type:
			Type.HEALTH:
				if body.health == body.health_max:
					return
				body.health += 1
			Type.ARMOR, Type.GUN:
				pass
			_:
				add_to_inventory(body)
		$snd.play()
		await $snd.finished
		queue_free()

func add_to_inventory(character: Character, add := true, powerup: Item = null):
	character.inventory_add({"type": type, "icon": hud_image, \
		"add": add, "powerup": powerup})
