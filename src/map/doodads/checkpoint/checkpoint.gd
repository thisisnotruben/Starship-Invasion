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
var passed_by := false

signal on_checkpoint_reached()


func _on_player_entered(body: Node3D):
	if body == player and not passed_by:
		passed_by = true
		get_checkpoint_data()
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

	for toggle_path in data.get("toggle_door", []):
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