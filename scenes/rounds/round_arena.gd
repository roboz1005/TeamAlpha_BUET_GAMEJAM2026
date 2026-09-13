extends Node2D
class_name RoundArena

const MIN_SPAWN_DISTANCE_FROM_PLAYER := 200.0

var _special_timer: Timer

func _ready() -> void:
	GameManager.round_started.emit(GameManager.current_round, GameManager.recordings.size())
	_spawn_doppelgangers()
	_spawn_enemies()
	_start_special_doppel_timer()

func _spawn_doppelgangers() -> void:
	var doppel_scene := preload("res://scenes/entities/doppelganger.tscn")
	var player_spawn: Vector2 = $PlayerSpawn.global_position
	var valid_points := $DoppelSpawns.get_children().filter(
		func(p): return p.global_position.distance_to(player_spawn) > MIN_SPAWN_DISTANCE_FROM_PLAYER
	)
	for i in GameManager.recordings.size():
		var rec: RoundRecording = GameManager.recordings[i]
		var d := doppel_scene.instantiate()
		d.call_deferred("add_to_group", "doppelgangers")
		add_child(d)
		d.global_position = valid_points[i % valid_points.size()].global_position
		d.setup(rec)

func _spawn_enemies() -> void:
	var enemy_scene := preload("res://scenes/entities/enemy.tscn")
	var spawn_points := $EnemySpawns.get_children()
	var count := 3 + GameManager.current_round
	for i in count:
		var e := enemy_scene.instantiate()
		add_child(e)
		var spawn: Node2D = spawn_points[randi() % spawn_points.size()]
		e.global_position = spawn.global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))

func _start_special_doppel_timer() -> void:
	# Created dynamically — can't be wired through the editor, see Section 4.
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
