extends Node3D
class_name Checkpoint

static var data := {}
static var items := {
	Item.Type.BLUE_KEYCARD: preload("res://src/items/keycard/blue_keycard.tscn"),
	Item.Type.GREEN_KEYCARD: preload("res://src/items/keycard/green_keycard.tscn"),
	Item.Type.RED_KEYCARD: preload("res://src/items/keycard/red_keycard.tscn"),
	Item.Type.YELLOW_KEYCARD: preload("res://src/items/keycard/yellow_keycard.tscn")
}

@export var player: Character = null
@export var disabled := false
@export var i_toggelable: IToggleable = null
var passed_by := false

signal on_checkpoint_reached()


func _on_player_entered(body: Node3D):
	if body == player and not passed_by and not disabled:
		activate()

func activate():
		$snd.play()
		passed_by = true
		get_checkpoint_data()
		if i_toggelable != null:
			i_toggelable.toggle(true)
		emit_signal("on_checkpoint_reached")

func get_checkpoint_data():
	data["level_name"] = owner.name

	data["position"] = player.global_position
	data["rotation"] = player.img.rotation.y
	data["health"] = player.health

	data["inventory"] = []
	for item_type in player.inventory:
		data["inventory"].append(items[item_type])

	data["npc"] = []
	for character in get_tree().get_nodes_in_group("character"):
		if character.npc:
			data["npc"].append(character.get_path())

	data["item"] = []
	for item in get_tree().get_nodes_in_group("item"):
		data["item"].append(item.get_path())

	data["toggle_door"] = []
	for node in get_tree().get_nodes_in_group("toggle_door"):
		if node.type == Door.Type.ACTIVATE and node.activated:
			data["toggle_door"].append(node.get_path())

	data["checkpoint"] = []
	for node in get_tree().get_nodes_in_group("checkpoint"):
		if node.passed_by:
			data["checkpoint"].append(node.get_path())

	data["objectives"] = ObjectiveMap.objectives

	var toggle: ComputerToggle = get_tree() \
		.get_first_node_in_group("toggle_computer_asteroid")
	if toggle != null:
		data["toggle_computer_asteroid"] = toggle.current_characters.is_empty()

	var music: MusicPlayer = get_tree().get_first_node_in_group("music")
	data["music"] = {
		"idx": music.music_list.find(music.stream),
		"pos" : music.get_playback_position()
	}

static func set_checkpoint_data(_player: Character):
	if data.is_empty():
		return
	var level := _player.owner
	if data.get("level_name", "") != _player.owner.name:
		data.clear()
		return

	for datam in data:
		match datam:
			"position":
				_player.global_position = data[datam]
			"rotation":
				_player.img.rotate_y(data[datam])
			"health":
				_player.health = data[datam]
			"inventory":
				for item in data[datam]:
					item.instantiate().add_to_inventory(_player)
			"npc":
				_get_difference_and_delete(level, data[datam], "character")
			"item":
				_get_difference_and_delete(level, data[datam], "item")
			"checkpoint":
				for node_path in data[datam]:
					var node := level.get_node_or_null(node_path)
					if node != null:
						node.set("passed_by", true)
			"objectives":
				ObjectiveMap.objectives = data[datam]
			"toggle_computer_asteroid":
				level.get_tree().get_first_node_in_group( \
					"toggle_computer_asteroid").current_characters.clear()
			"music":
				var music: MusicPlayer = level.get_tree() \
					.get_first_node_in_group("music")
				music.stop()
				music.stream = music.music_list[data[datam]["idx"]]
				music.play(data[datam]["pos"])

	var mapped_toggle := {}
	for comp_toggle in level.get_tree().get_nodes_in_group("toggle_computer"):
		mapped_toggle[comp_toggle.i_toggleable.get_path()] = comp_toggle

	for toggle_path in data.get("toggle_door", []):
		if mapped_toggle.has(toggle_path):
			mapped_toggle[toggle_path].call("activate", _player)
		else:
			level.get_node(toggle_path).call("toggle", true)

static func _get_difference_and_delete(level: Node, alive: Array, group: String):
	var all := []
	for node in level.get_tree().get_nodes_in_group(group):
		if node is Character and not node.npc:
			continue
		all.append(node.get_path())

	for alive_node_path in alive:
		all.erase(alive_node_path)

	for dead_node_path in all:
		var node := level.get_node_or_null(dead_node_path)
		if node != null:
			node.queue_free()
