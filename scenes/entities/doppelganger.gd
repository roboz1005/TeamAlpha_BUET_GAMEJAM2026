extends CharacterBody2D
class_name Doppelganger

enum State { REPLAY, COMBAT, DODGE, COLLECT, ALERT_SEARCH, POSSESSED }

@export var detection_radius: float = 140.0

var state: State = State.REPLAY
var recording: RoundRecording
var skills: SkillSet
var is_special: bool = false
var health: int = 2
var controller: Player = null

var _frame_index: int = 0
var _fire_cooldown: float = 0.0
var _target_drop: Node = null
var _spawn_grace: float = 1.5   # ignores player-detection for a moment after spawning

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var alert_icon: Sprite2D = $AlertIcon

func setup(rec: RoundRecording, upgraded_special: bool = false) -> void:
	recording = rec
	skills = rec.skills_snapshot
	is_special = upgraded_special
	if is_special:
		skills = SkillSet.new()
		skills.damage_level = 3
		skills.fire_rate_level = 3
		skills.move_speed_level = 2
		skills.max_health_level = 3
		health = 5
		sprite.modulate = Color(1.0, 0.85, 0.2)   # gold tint for the elite
	else:
		health = 2 + skills.max_health_level
		sprite.modulate = Color(0.8, 0.2, 0.3)    # standard doppelganger tint

func _physics_process(delta: float) -> void:
	_fire_cooldown = max(0.0, _fire_cooldown - delta)
	_spawn_grace = max(0.0, _spawn_grace - delta)
	alert_icon.visible = state in [State.COMBAT, State.ALERT_SEARCH]

	match state:
		State.REPLAY:
			_do_replay()
			if _spawn_grace <= 0.0:
				_check_player_detection()
			_check_nearby_drops()
		State.COMBAT:
			_do_combat()
		State.DODGE:
			_do_dodge()
		State.COLLECT:
			_do_collect()
		State.ALERT_SEARCH:
			_do_search(delta)
		State.POSSESSED:
			pass   # driven externally via possessed_move()

func _do_replay() -> void:
	if _frame_index >= recording.positions.size():
		state = State.ALERT_SEARCH
		return
	var target_pos: Vector2 = recording.positions[_frame_index]
	global_position = global_position.move_toward(target_pos, 4.0)
	_frame_index += 1
	_replay_actions_for_frame(_frame_index)

func _replay_actions_for_frame(frame: int) -> void:
	for action in recording.actions:
		if action.get("frame") == frame and action.get("type") == "shoot":
			_fire_at(action.get("dir", 0.0))

func _check_player_detection() -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if player and not _player_is_hidden(player):
		if global_position.distance_to(player.global_position) < detection_radius:
			state = State.COMBAT

func _player_is_hidden(player: Player) -> bool:
	if not player.is_possessing_clone:
		return false
	for bush in get_tree().get_nodes_in_group("bushes"):
		if bush.hides(player.global_position):
			return true
	return false

func _do_combat() -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if not player or _player_is_hidden(player):
		state = State.REPLAY
		return
	var to_player := player.global_position - global_position
	if to_player.length() > detection_radius * 1.5:
		state = State.REPLAY
		return
	var dir := _steer_away_from_known_hazard(to_player.normalized())
	velocity = dir * (100 + skills.move_speed_level * 15)
	move_and_slide()
	if to_player.length() < 220 and _fire_cooldown <= 0.0:
		_fire_at(to_player.angle())

func _steer_away_from_known_hazard(dir: Vector2) -> Vector2:
	if recording.death_hazard_id == "":
		return dir
	var hazard := get_tree().get_first_node_in_group(recording.death_hazard_id)
	if hazard and global_position.distance_to(hazard.global_position) < 80:
		var away = (global_position - hazard.global_position).normalized()
		return (dir + away).normalized()
	return dir

func _fire_at(angle: float) -> void:
	_fire_cooldown = 1.2 - skills.fire_rate_level * 0.15
	var bullet := preload("res://scenes/entities/bullet.tscn").instantiate()
	bullet.direction = Vector2.RIGHT.rotated(angle)
	bullet.damage = 1 + skills.damage_level
	bullet.set_meta("source", "doppelganger")
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position   # set AFTER add_child

func _do_dodge() -> void:
	# Unreachable for now — nothing transitions the state machine into DODGE
	# yet. Left as a stub for a future "dodge incoming bullets" behavior;
	# harmless to leave as-is.
	state = State.COMBAT

func _check_nearby_drops() -> void:
	for drop in get_tree().get_nodes_in_group("drops"):
		if global_position.distance_to(drop.global_position) < 100:
			_target_drop = drop
			state = State.COLLECT
			break

func _do_collect() -> void:
	if not is_instance_valid(_target_drop):
		state = State.REPLAY
		return
	global_position = global_position.move_toward(_target_drop.global_position, 3.0)
	if global_position.distance_to(_target_drop.global_position) < 10:
		_target_drop.collect(self)
		_target_drop = null
		state = State.REPLAY

func _do_search(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if player and not _player_is_hidden(player):
		if global_position.distance_to(player.global_position) < detection_radius * 1.3:
			state = State.COMBAT
			return
	velocity = velocity.rotated(randf_range(-0.3, 0.3)).normalized() * 70
	move_and_slide()

func take_hit(amount: int, from_player: bool = true) -> void:
	health -= amount
	if health <= 0:
		_die(from_player)

func heal(amount: int = 1) -> void:
	health += amount

func _die(killed_by_player: bool) -> void:
	if state == State.POSSESSED and controller:
		controller.on_possessed_clone_destroyed()
	if killed_by_player:
		GameManager.player_currency += 5
		GameManager.add_xp(3)
		Events.doppelganger_killed.emit(self)
	#if is_special:
		#var pickup = preload("res://scenes/entities/clone_control_pickup.tscn").instantiate()
		#get_tree().current_scene.add_child(pickup)
		#pickup.global_position = global_position   # set AFTER add_child
	queue_free()

func get_possessed(player: Player) -> void:
	state = State.POSSESSED
	controller = player

func release_possession() -> void:
	state = State.ALERT_SEARCH
	controller = null

func possessed_move(dir: Vector2) -> void:
	velocity = dir * (140 + skills.move_speed_level * 15)
	move_and_slide()

func sabotage_from(_saboteur: Doppelganger) -> void:
	_die(true)
	_broadcast_alert()

func _broadcast_alert() -> void:
	for d in get_tree().get_nodes_in_group("doppelgangers"):
		if d != self and is_instance_valid(d):
			d.state = State.ALERT_SEARCH
