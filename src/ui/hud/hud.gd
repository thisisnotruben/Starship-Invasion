extends Control

@export var player: Character = null
@export var health_scene: PackedScene = null

@onready var health_container: Control = $margin/vBox/hBox/health
@onready var inventory_container: Control = $margin/vBox/hBox/inventory
var health_level := []
const hurt_color := [Color("#b50a0a80"), Color("#b50a0a00")]


func _ready():
	if player != null:
		player.show_objective.connect(_on_show_objective)
		player.health_changed.connect(_on_player_health_changed)
		player.inventory_added.connect(_on_player_inventory_changed)
		for i in player.health:
			health_level.append(health_scene.instantiate())
			health_container.add_child(health_level[-1])
		Checkpoint.set_checkpoint_data(player)

func _on_show_objective(_show: bool, blurb: String):
	$margin/vBox/center.modulate = Color.WHITE if _show \
		else Color.TRANSPARENT
	$margin/vBox/center/label.text = "Objective: " + blurb

func _on_show_checkpoint():
	$margin/vBox/center.modulate = Color.WHITE
	$margin/vBox/center/label.text = "Checkpoint Reached!"
	await get_tree().create_timer(1.0).timeout
	$margin/vBox/center.modulate = Color.TRANSPARENT

func _on_player_health_changed(health: int):
	var amount := health - health_container.get_child_count()
	if amount < 0:
		$hurt.color = hurt_color[0]
		get_tree().create_tween().tween_property( \
			$hurt, "color", hurt_color[1], 0.5) \
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

func show_alert(duration: float, impact: bool):
	if impact:
		$impact/anim.play("impact")
		await get_tree().create_timer(duration).timeout
		$impact/anim.stop()
	else:
		$alert/anim.play("alert")
		await get_tree().create_timer(duration).timeout
		$alert/anim.stop()

func _on_show_hull_integrity(_visible: bool):
	$margin/vBox/hull_integrity.visible = _visible
