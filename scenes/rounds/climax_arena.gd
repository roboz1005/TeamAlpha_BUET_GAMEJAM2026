extends Node2D
class_name ClimaxArena

func _ready() -> void:
	GameManager.round_started.emit(GameManager.current_round, GameManager.recordings.size())
	# Autoload signal — must be code, see Section 4.
	Events.doppelganger_killed.connect(_check_victory)
	_spawn_all_doppelgangers_hostile()

func _spawn_all_doppelgangers_hostile() -> void:
	var doppel_scene := preload("res://scenes/entities/doppelganger.tscn")
	var spawn_points := $RoundArena/DoppelSpawns.get_children()
	for i in GameManager.recordings.size():
		var rec: RoundRecording = GameManager.recordings[i]
		var d := doppel_scene.instantiate()
		d.add_to_group("doppelgangers")
		add_child(d)
		d.global_position = spawn_points[i % spawn_points.size()].global_position
		d.setup(rec)
		d.state = Doppelganger.State.COMBAT   # skip replay, go straight hostile

func _check_victory(_d) -> void:
	await get_tree().process_frame
	if get_tree().get_nodes_in_group("doppelgangers").is_empty():
		GameManager.game_won.emit()
		get_tree().change_scene_to_file("res://scenes/ui/victory_screen.tscn")
