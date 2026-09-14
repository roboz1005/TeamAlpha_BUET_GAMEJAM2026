extends CharacterBody2D
class_name Player

signal died
signal round_completed
signal health_changed(current: int, max: int)

const SPEED := 160.0
const MAX_HEALTH := 3
const BASE_SHOOT_COOLDOWN := 0.4

@onready var recorder: RecordingComponent = $RecordingComponent
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var bullet_scene = preload("res://scenes/entities/bullet.tscn")

var health: int
var is_possessing_clone: bool = false
var held_clone_control_item: bool = false
var possessed_doppelganger: Doppelganger = null

var _shoot_cooldown: float = 0.0
var _temp_fire_rate_bonus: float = 0.0
var _temp_speed_bonus: float = 0.0
var _temp_defense_active: bool = false

func _ready() -> void:
	add_to_group("player")
	health = MAX_HEALTH + GameManager.player_skills.max_health_level
	health_changed.emit(health, MAX_HEALTH)

func _physics_process(delta: float) -> void:
	if is_possessing_clone and possessed_doppelganger:
		_handle_possessed_input()
		return

	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * (SPEED + GameManager.player_skills.move_speed_level * 15 + _temp_speed_bonus)
	move_and_slide()

	_update_facing_sprite()

	_shoot_cooldown = max(0.0, _shoot_cooldown - delta)
	if Input.is_action_just_pressed("shoot") and _shoot_cooldown <= 0.0:
		_shoot()
	if Input.is_action_just_pressed("use_clone_control") and held_clone_control_item:
		_activate_clone_control()

func _update_facing_sprite() -> void:
	# Same technique as the reference script: snap the mouse angle to the
	# nearest 45°, turn it into an octant 0-7, play "walk<octant>". No gun —
	# the body itself faces the cursor.
	var mouse := get_local_mouse_position()
	var octant := wrapi(int(snappedf(mouse.angle(), PI / 4) / (PI / 4)), 0, 8)
	sprite.animation = "walk%d" % octant
	if velocity.length() > 0.1:
		sprite.play()
	else:
		sprite.stop()
		sprite.frame = 1

func _shoot() -> void:
	var cooldown := BASE_SHOOT_COOLDOWN - GameManager.player_skills.fire_rate_level * 0.05 - _temp_fire_rate_bonus
	_shoot_cooldown = max(cooldown, 0.08)

	var aim_dir := get_global_mouse_position() - global_position
	if aim_dir.length() < 0.001:
		aim_dir = Vector2.RIGHT
	aim_dir = aim_dir.normalized()

	recorder.log_action("shoot", {"dir": aim_dir.angle()})
	var bullet = bullet_scene.instantiate() as Bullet
	bullet.direction = aim_dir
	bullet.damage = 1 + GameManager.player_skills.damage_level
	bullet.set_meta("source", "player")
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position   # no gun marker — fires from center

func take_hit(amount: int = 1) -> void:
	var final_amount := amount
	if _temp_defense_active:
		final_amount = max(0, amount - 1)
	health -= final_amount
	health_changed.emit(health, MAX_HEALTH)
	if health <= 0:
		die("")

func heal(amount: int = 1) -> void:
	health = min(health + amount, MAX_HEALTH + GameManager.player_skills.max_health_level)
	health_changed.emit(health, MAX_HEALTH)

func apply_temp_skill(kind: String, duration: float = 12.0) -> void:
	match kind:
		"temp_firerate":
			_temp_fire_rate_bonus = 0.15
		"temp_speed":
			_temp_speed_bonus = 60.0
		"temp_defense":
			_temp_defense_active = true
	var timer := get_tree().create_timer(duration)
	timer.timeout.connect(_clear_temp_skill.bind(kind))

func _clear_temp_skill(kind: String) -> void:
	match kind:
		"temp_firerate":
			_temp_fire_rate_bonus = 0.0
		"temp_speed":
			_temp_speed_bonus = 0.0
		"temp_defense":
			_temp_defense_active = false

func die(hazard_id: String) -> void:
	recorder.mark_death(hazard_id)
	died.emit()
	GameManager.finish_round(recorder.recording, true)

func complete_round() -> void:
	round_completed.emit()
	GameManager.finish_round(recorder.recording, false)

func _activate_clone_control() -> void:
	var target := _find_nearest_doppelganger()
	if target:
		is_possessing_clone = true
		held_clone_control_item = false
		possessed_doppelganger = target
		target.get_possessed(self)
		get_tree().current_scene.get_node("CameraRig").follow_target = target
		VFX.spawn(VFX.POSSESSION_SWIRL, target.global_position)

func release_clone_control() -> void:
	if possessed_doppelganger:
		possessed_doppelganger.release_possession()
	is_possessing_clone = false
	possessed_doppelganger = null
	get_tree().current_scene.get_node("CameraRig").follow_target = self

func on_possessed_clone_destroyed() -> void:
	is_possessing_clone = false
	possessed_doppelganger = null
	get_tree().current_scene.get_node("CameraRig").follow_target = self
	take_hit(1)

func _handle_possessed_input() -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	possessed_doppelganger.possessed_move(input_dir)

	if Input.is_action_just_pressed("sabotage"):
		var target := _find_nearest_doppelganger_excluding(possessed_doppelganger)
		if target and possessed_doppelganger.global_position.distance_to(target.global_position) < 60:
			target.sabotage_from(possessed_doppelganger)
			_compromise_current_hideout()

	if Input.is_action_just_pressed("release_control"):
		release_clone_control()

func _compromise_current_hideout() -> void:
	for bush in get_tree().get_nodes_in_group("bushes"):
		if bush.hides(global_position):
			bush.compromise()

func _find_nearest_doppelganger() -> Doppelganger:
	var best: Doppelganger = null
	var best_dist := INF
	for d in get_tree().get_nodes_in_group("doppelgangers"):
		var dist := global_position.distance_to(d.global_position)
		if dist < best_dist and dist < 250.0:
			best = d
			best_dist = dist
	return best

func _find_nearest_doppelganger_excluding(exclude: Doppelganger) -> Doppelganger:
	var best: Doppelganger = null
	var best_dist := INF
	for d in get_tree().get_nodes_in_group("doppelgangers"):
		if d == exclude:
			continue
		var dist := exclude.global_position.distance_to(d.global_position)
		if dist < best_dist:
			best = d
			best_dist = dist
	return best
