extends Node2D
class_name ClimaxArena

var _map_root: Node2D

func _ready() -> void:
	_load_map()
	_spawn_player_at_random_point()
	GameManager.round_started.emit(GameManager.current_round, GameManager.recordings.size())
	Events.doppelganger_killed.connect(_check_victory)
	_spawn_all_doppelgangers_hostile()

func _load_map() -> void:
	var map_scene: PackedScene = load(GameManager.selected_map_path)
	_map_root = map_scene.instantiate()
	$MapContainer.add_child(_map_root)

func _spawn_player_at_random_point() -> void:
	var spawn_points := _map_root.get_node("PlayerSpawns").get_children()
	var chosen: Node2D = spawn_points[randi() % spawn_points.size()]
	$Player.global_position = chosen.global_position

func _spawn_all_doppelgangers_hostile() -> void:
	var doppel_scene := preload("res://scenes/entities/doppelganger.tscn")
	for i in GameManager.recordings.size():
		var rec: RoundRecording = GameManager.recordings[i]
		if rec.positions.is_empty():
			continue
		var d := doppel_scene.instantiate()
		d.call_deferred("add_to_group", "doppelgangers")
		add_child(d)
		d.global_position = rec.positions[0]
		d.setup(rec)
		d.state = Doppelganger.State.COMBAT   # skip replay, go straight hostile
		d.make_climax_giant()

func _check_victory(_d) -> void:
	await get_tree().process_frame
	if get_tree().get_nodes_in_group("doppelgangers").is_empty():
		GameManager.game_won.emit()
		get_tree().call_deferred("change_scene_to_file", "res://scenes/ui/victory_screen.tscn")
