extends Control

@export var player: Character = null
@export var health_scene: PackedScene = null

@onready var tab: TabContainer = $margin/vBox/tabs
var tabs := {"o2": 0, "hull_integrity": 1}

@onready var overheat_level: ProgressBar = $margin/vBox/padding/hbox/progressBar
@onready var shoot_timer: Timer = $shoot_timer
var existing_tweens := []

@onready var health_container: Control = $margin/vBox/hBox/health
@onready var inventory_container: Control = $margin/vBox/hBox/inventory
var health_level := []
const hurt_color := [Color("#b50a0a80"), Color("#b50a0a00")]


func _ready():
	if player != null:
		player.show_objective.connect(_on_show_objective)
		player.on_shoot.connect(_on_shoot)
		player.health_changed.connect(_on_player_health_changed)
		player.inventory_added.connect(_on_player_inventory_changed)
		for i in player.health:
			health_level.append(health_scene.instantiate())
			health_container.add_child(health_level[-1])

func _on_show_objective(show: bool, blurb: String):
	$margin/vBox/center.modulate = Color.WHITE if show \
		else Color.TRANSPARENT
	$margin/vBox/center/label.text = "Objective: " + blurb

func _on_shoot(overheat_per: float, \
cooldown_sec: float, shoot_cooldown_timer: float):
	existing_tweens.map(func(t): t.kill())
	existing_tweens.clear()
	overheat_level.value += overheat_per
	player.can_shoot = not is_equal_approx( \
		overheat_level.value, overheat_level.max_value)

	shoot_timer.start(shoot_cooldown_timer)
	await shoot_timer.timeout

	player.can_shoot = true
	var tween := get_tree().create_tween()
	tween.tween_property(overheat_level, "value", \
		0.0, cooldown_sec)
	existing_tweens.append(tween)

func _on_player_health_changed(health: int):
	var tween := get_tree().create_tween()
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

func _on_show_o2_timer(_visible: bool):
	tab.current_tab = tabs["o2"]
	tab.visible = _visible

func _on_show_hull_integrity(_visible: bool):
	tab.current_tab = tabs["hull_integrity"]
	tab.visible = _visible
