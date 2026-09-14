extends Node2D
class_name RoundArena

var _map_root: Node2D
var _special_timer: Timer

func _ready() -> void:
	_load_map()
	_spawn_player_at_random_point()
	GameManager.round_started.emit(GameManager.current_round, GameManager.recordings.size())
	_spawn_doppelgangers()
	_spawn_enemies()
	_start_special_doppel_timer()
	# Autoload signals — must be code, not editor-connectable.
	Events.enemy_killed.connect(_on_something_died)
	Events.doppelganger_killed.connect(_on_something_died)

func _load_map() -> void:
	var map_scene: PackedScene = load(GameManager.selected_map_path)
	_map_root = map_scene.instantiate()
	$MapContainer.add_child(_map_root)

func _spawn_player_at_random_point() -> void:
	var spawn_points := _map_root.get_node("PlayerSpawns").get_children()
	var chosen: Node2D = spawn_points[randi() % spawn_points.size()]
	$Player.global_position = chosen.global_position

func _spawn_doppelgangers() -> void:
	var doppel_scene := preload("res://scenes/entities/doppelganger.tscn")
	for i in GameManager.recordings.size():
		var rec: RoundRecording = GameManager.recordings[i]
		if rec.positions.is_empty():
			continue   # safety: skip a recording with no captured frames
		var d := doppel_scene.instantiate()
		d.call_deferred("add_to_group", "doppelgangers")
		add_child(d)
		d.global_position = rec.positions[0]   # spawns where the player started THAT round
		d.setup(rec)

func _spawn_enemies() -> void:
	var enemy_scene := preload("res://scenes/entities/enemy.tscn")
	var spawn_points := _map_root.get_node("EnemySpawns").get_children()
	var count := 3 + GameManager.current_round
	for i in count:
		var e := enemy_scene.instantiate()
		add_child(e)
		var spawn: Node2D = spawn_points[randi() % spawn_points.size()]
		e.global_position = spawn.global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))

func _start_special_doppel_timer() -> void:
	_special_timer = Timer.new()
	_special_timer.wait_time = 120.0
	_special_timer.autostart = true
	_special_timer.timeout.connect(_upgrade_random_doppelganger)
	add_child(_special_timer)

func _upgrade_random_doppelganger() -> void:
	var candidates := get_tree().get_nodes_in_group("doppelgangers").filter(
		func(d): return not d.is_special and d.state != Doppelganger.State.POSSESSED
	)
	if candidates.is_empty():
		return
	var chosen: Doppelganger = candidates[randi() % candidates.size()]
	chosen.setup(chosen.recording, true)

func _on_something_died(_who) -> void:
	await get_tree().process_frame   # let queue_free() actually finish first
	_check_round_clear()

func _check_round_clear() -> void:
	if get_tree().get_nodes_in_group("doppelgangers").is_empty() \
	and get_tree().get_nodes_in_group("enemies").is_empty():
		$Player.complete_round()
