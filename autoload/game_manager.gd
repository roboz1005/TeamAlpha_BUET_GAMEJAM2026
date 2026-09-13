extends Node

signal round_started(round_number: int, doppelganger_count: int)
signal round_ended(round_number: int, player_died: bool)
signal game_won
signal game_over

const TOTAL_ROUNDS_BEFORE_CLIMAX := 9   # rounds 1..9 normal, round 10 = climax

var current_round: int = 1
var recordings: Array[RoundRecording] = []
var player_skills: SkillSet = SkillSet.new()
var player_currency: int = 0

var xp: int = 0
var xp_to_next_level: int = 10

func _ready() -> void:
	randomize()

func start_new_run() -> void:
	current_round = 1
	recordings.clear()
	player_skills = SkillSet.new()
	player_currency = 0
	xp = 0
	xp_to_next_level = 10
	get_tree().call_deferred("change_scene_to_file","res://scenes/rounds/round_arena.tscn")

func doppelganger_count_for_round(round_number: int) -> int:
	return max(0, round_number - 1)

func finish_round(recording: RoundRecording, player_died: bool) -> void:
	recording.round_number = current_round
	recording.skills_snapshot = player_skills.duplicate_skills()
	recordings.append(recording)
	round_ended.emit(current_round, player_died)

	if current_round >= TOTAL_ROUNDS_BEFORE_CLIMAX:
		get_tree().call_deferred("change_scene_to_file","res://scenes/rounds/climax_arena.tscn")
	else:
		current_round += 1
		get_tree().call_deferred("change_scene_to_file","res://scenes/rounds/round_arena.tscn")

func add_xp(amount: int) -> void:
	xp += amount
	while xp >= xp_to_next_level:            # while, not if — a big XP grant
		xp -= xp_to_next_level               # can cross more than one threshold
		xp_to_next_level = int(xp_to_next_level * 1.4)
		_unlock_random_skill_tier()

func _unlock_random_skill_tier() -> void:
	var choices := ["damage_level", "fire_rate_level", "move_speed_level", "max_health_level"]
	var pick: String = choices[randi() % choices.size()]
	player_skills.set(pick, player_skills.get(pick) + 1)
	Events.skill_unlocked.emit(pick)
