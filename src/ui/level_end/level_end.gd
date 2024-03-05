extends Control

static var times_died: int = 0
static var time_started: int = 0

var victims: int = 0
var total_victims: int = 0
var next_level: PackedScene = null


func _ready():
	if times_died == 0:
		time_started = Time.get_ticks_msec()
	total_victims = get_tree().get_nodes_in_group("character") \
		.map(func(c): c.tree_exited.connect(Callable( \
		self, "_on_victim_died").bind(c))).size() - 1

func _on_victim_died(victim: Character):
	if victim.npc:
		victims += 1
	else:
		times_died += 1

func _on_draw():
	$finish.grab_focus()
	var final_time_sec := float(Time.get_ticks_msec() - time_started) / 1000.0
	$grid/victims.text = "%d/%d" % [victims, total_victims]
	$grid/times_died.text = str(times_died)
	$grid/time.text = "%d:%02d" \
		% [floor(final_time_sec / 60), int(final_time_sec) % 60]

func _on_finish_pressed():
	if next_level != null:
		times_died = 0
		Checkpoint.data.clear()
		$snd_start.play()
		await $snd_start.finished
		get_tree().paused = false
		get_tree().change_scene_to_packed(next_level)
