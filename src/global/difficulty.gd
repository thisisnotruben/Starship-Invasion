extends Node
class_name Difficulty

enum Type {EASY, MEDIUM, HARD}
static var curr_diff := Type.MEDIUM
static var des_diff := Type.MEDIUM
const difficulty_stats := \
{
	Type.EASY: {
		"alien": {
			"health_max": 2,
			"melee_damage": 1
		},
		"pile_of_flesh": {
			"health_max": 2,
			"melee_damage": 1,
			"range_damage": 1,
			"special_cooldown": 6.0
		},
		"minion": {
			"health_max": 1,
			"melee_damage": 1
		},
		"space_warrior": {
			"health_max": 3,
			"melee_damage": 1,
			"range_damage": 1
		},
		"space_warrior_gold": {
			"health_max": 5,
			"melee_damage": 1,
			"range_damage": 1,
			"shoot_cooldown": 1.25
		},
		"space_sargent": {
			"health_max": 5,
			"melee_damage": 2,
			"range_damage": 2
		},
		"space_sargent_gold": {
			"health_max": 7,
			"melee_damage": 2,
			"range_damage": 2
		}
	},
	Type.MEDIUM: {
		"alien": {
			"health_max": 2,
			"melee_damage": 1
		},
		"pile_of_flesh": {
			"health_max": 4,
			"melee_damage": 1,
			"range_damage": 1,
			"special_cooldown": 3.8
		},
		"minion": {
			"health_max": 1,
			"melee_damage": 1
		},
		"space_warrior": {
			"health_max": 5,
			"melee_damage": 1,
			"range_damage": 1
		},
		"space_warrior_gold": {
			"health_max": 7,
			"melee_damage": 2,
			"range_damage": 2,
			"shoot_cooldown": 1.25
		},
		"space_sargent": {
			"health_max": 8,
			"melee_damage": 2,
			"range_damage": 2
		},
		"space_sargent_gold": {
			"health_max": 10,
			"melee_damage": 2,
			"range_damage": 2
		}
	},
	Type.HARD: {
		"alien": {
			"health_max": 3,
			"melee_damage": 1
		},
		"pile_of_flesh": {
			"health_max": 5,
			"melee_damage": 1,
			"range_damage": 2,
			"special_cooldown": 3.8
		},
		"minion": {
			"health_max": 2,
			"melee_damage": 1
		},
		"space_warrior": {
			"health_max": 7,
			"melee_damage": 1,
			"range_damage": 2
		},
		"space_warrior_gold": {
			"health_max": 9,
			"melee_damage": 2,
			"range_damage": 2,
			"shoot_cooldown": 1.25
		},
		"space_sargent": {
			"health_max": 10,
			"melee_damage": 2,
			"range_damage": 2
		},
		"space_sargent_gold": {
			"health_max": 13,
			"melee_damage": 2,
			"range_damage": 2
		}
	}
}

func _ready():
	set_difficulty()

func set_difficulty():
	if des_diff == curr_diff:
		return

	curr_diff = des_diff
	for character in get_tree().get_nodes_in_group("character"):
		var payload := {}

		match character.scene_file_path.get_file().get_basename():
			"swarm_alien", "swarm_alien_green", "swarm_alien_red":
				payload = difficulty_stats[des_diff]["alien"]
			"pile_of_flesh", "pile_of_flesh_blue", "pile_of_flesh_green":
				payload = difficulty_stats[des_diff]["pile_of_flesh"]
			"flesh_minion", "flesh_minion_blue", "flesh_minion_green":
				payload = difficulty_stats[des_diff]["minion"]
			"space_sargent", "space_sargent_purple":
				payload = difficulty_stats[des_diff]["space_sargent"]
			"space_sargent_gold":
				payload = difficulty_stats[des_diff]["space_sargent_gold"]
			"space_warrior",  "space_warrior_purple":
				payload = difficulty_stats[des_diff]["space_warrior"]
			"space_warrior_gold":
				payload = difficulty_stats[des_diff]["space_warrior_gold"]

		for data in payload:
			match data:
				"health_max":
					character.health_max = payload[data]
				"melee_damage":
					character.melee_damage = payload[data]
				"range_damage":
					character.range_damage = payload[data]
				"special_cooldown":
					character.get_node("fsm_behavior/attack/special_cooldown") \
						.wait_time = payload[data]
				"shoot_cooldown":
					character.get_node("fsm_behavior/attack/shoot_cooldown") \
						.wait_time = payload[data]
