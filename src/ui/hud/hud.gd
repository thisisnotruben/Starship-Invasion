extends Control

@export var player: Character = null
@export var health_scene: PackedScene = null

@onready var health_container: Control = $margin/vBox/hBox/health
@onready var inventory_container: Control = $margin/vBox/hBox/inventory
var health_level := []
const hurt_color := [Color("#b50a0a80"), Color("#b50a0a00")]


func _ready():
	if player != null:
		player.health_changed.connect(_on_player_health_changed)
		player.inventory_added.connect(_on_player_inventory_changed)
		for i in player.health:
			health_level.append(health_scene.instantiate())
			health_container.add_child(health_level[-1])

func _on_player_health_changed(health: int):
	var amount := health - health_container.get_child_count()

	if amount < 0:
		$hurt.color = hurt_color[0]
		var tween_hurt := get_tree().create_tween()
		tween_hurt.tween_property($hurt, "color", hurt_color[1], 0.5) \
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BOUNCE)

	for i in abs(amount):
		if amount > 0:
			health_level.append(health_scene.instantiate())
			health_container.add_child(health_level[-1])
		elif amount < 0 and not health_level.is_empty():
			var lost_health: Control = health_level.pop_back()
			var tween_heart := get_tree().create_tween()
			tween_heart.tween_property(lost_health, "modulate", Color.TRANSPARENT, 0.5) \
				.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BOUNCE)
			tween_heart.tween_callback(lost_health.queue_free)

func _on_player_inventory_changed(data: Dictionary):
	if data["add"]:
		var item: TextureRect = health_scene.instantiate()
		item.texture = data["icon"]
		inventory_container.add_child(item)
		item.name = str(data["type"])
	else:
		var item := inventory_container.get_node_or_null(data["type"])
		if item != null:
			item.queue_free()
