extends CharacterBody2D
class_name RustBoss


@export var max_health: int = 40
@export var chase_speed: float = 55.0
@export var normal_shot_interval: float = 1.0
@export var burst_shot_interval: float = 0.2
@export var burst_duration: float = 1.5
@export var area_shot_count: int = 12
@export var normal_phase_duration: float = 6.0
@export var teleport_min_distance: float = 50.0
@export var teleport_max_distance: float = 100.0
@export var projectile_scene: PackedScene = preload("res://scenes/entities/enemy_projectile.tscn")
@export var rust_remover_scene: PackedScene = preload("res://scenes/entities/rust_remover.tscn")
@export var split_boss_scene: PackedScene = preload("res://scenes/entities/rust_boss_small.tscn")

enum Phase { NORMAL, BURST, AREA, TELEPORT }
const SPECIAL_PHASES: Array[int] = [Phase.BURST, Phase.AREA, Phase.TELEPORT]

var health: int
var is_dead: bool = false
var is_active: bool = false
var is_hurt_animating: bool = false
var has_split: bool = false
var is_split_copy: bool = false
var current_phase: Phase = Phase.NORMAL
var gravity: float = 600 #ProjectSettings.get_setting("physics/2d/default_gravity")
var sound_played: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var muzzle: Marker2D = $Muzzle
@onready var damage_area: Area2D = $DamageArea
@onready var hurt_anim_timer: Timer = $HurtAnimTimer
@onready var death_timer: Timer = $DeathTimer
@onready var attack_timer: Timer = $AttackTimer
@onready var phase_timer: Timer = $PhaseTimer
@onready var sound_timer: Timer = $SoundTimer

func _ready() -> void:
	health = max_health
	add_to_group("enemy")
	add_to_group("boss")
	# Stays idle until start_fight() is called by boss_intro's Fight! button.

func start_fight() -> void:
	is_active = true
	_enter_phase(Phase.NORMAL)

func _physics_process(delta: float) -> void:
	if is_dead or not is_active:
		return
	scale = Vector2(5, 5)
	if not is_on_floor():
		velocity.y += gravity * delta
		if position.y > 400 and not sound_played:
			MusicController.fall_music_play()
			sound_played = true
			sound_timer.start()
	else:
		velocity.y = 0.0

	var player: Node = get_tree().get_first_node_in_group("player")
	if player and current_phase != Phase.TELEPORT:
		var dx: float = player.global_position.x - global_position.x
		if abs(dx) > 4.0:
			velocity.x = chase_speed * (1.0 if dx > 0.0 else -1.0)
			animated_sprite.flip_h = dx < 0.0
		else:
			velocity.x = 0.0
	else:
		velocity.x = 0.0

	if not is_hurt_animating:
		animated_sprite.play("move")
	move_and_slide()

func _enter_phase(p: Phase) -> void:
	current_phase = p
	attack_timer.stop()
	match p:
		Phase.NORMAL:
			attack_timer.start(normal_shot_interval)
			phase_timer.start(normal_phase_duration)
		Phase.BURST:
			attack_timer.start(burst_shot_interval)
			phase_timer.start(burst_duration)
		Phase.AREA:
			_fire_area_shot()
			phase_timer.start(0.8)
		Phase.TELEPORT:
			_teleport_near_player()
			phase_timer.start(1.0)

# "signal" — PhaseTimer(Timer).timeout -> _on_phase_timer_timeout()
func _on_phase_timer_timeout() -> void:
	if is_dead:
		return
	if current_phase == Phase.NORMAL:
		_enter_phase(SPECIAL_PHASES[randi() % SPECIAL_PHASES.size()])
	else:
		_enter_phase(Phase.NORMAL)

# "signal" — AttackTimer(Timer).timeout -> _on_attack_timer_timeout()
func _on_attack_timer_timeout() -> void:
	if is_dead:
		return
	if current_phase == Phase.NORMAL or current_phase == Phase.BURST:
		_fire_at_player()

func _get_muzzle_global_position() -> Vector2:
	var offset_x: float = abs(muzzle.position.x)
	var mirrored_x: float = -offset_x if animated_sprite.flip_h else offset_x
	return global_position + Vector2(mirrored_x, muzzle.position.y)

func _fire_at_player() -> void:
	var player: Node = get_tree().get_first_node_in_group("player")
	if not player:
		return
	var origin: Vector2 = _get_muzzle_global_position()
	var to_player: Vector2 = player.global_position - origin
	if to_player.length() < 1.0:
		to_player = Vector2.RIGHT
	_spawn_projectile(origin, to_player.normalized())

func _fire_area_shot() -> void:
	var origin: Vector2 = global_position
	var angle_step: float = TAU / float(area_shot_count)
	for i in area_shot_count:
		var dir: Vector2 = Vector2.RIGHT.rotated(angle_step * i)
		_spawn_projectile(origin, dir)

func _spawn_projectile(origin: Vector2, dir_vector: Vector2) -> void:
	var proj: EnemyProjectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(proj)
	proj.global_position = origin
	proj.set_direction_vector(dir_vector)

func _teleport_near_player() -> void:
	var player: Node = get_tree().get_first_node_in_group("player")
	if not player:
		return
	var angle: float = randf() * TAU
	var dist: float = randf_range(teleport_min_distance, teleport_max_distance)
	global_position = player.global_position + Vector2.RIGHT.rotated(angle) * dist + Vector2((0.5 - randf()) * 60, -60)
	sound_played = false
	
func take_damage(amount: int = 1) -> void:
	if is_dead:
		return
	health -= amount
	if health <= 0:
		die()
		return
	if not has_split and not is_split_copy and health <= -100: #int(max_health / 2.0)
		_split()
		return
	animated_sprite.play("hurt")
	is_hurt_animating = true
	hurt_anim_timer.start()

func _split() -> void:
	has_split = true
	if split_boss_scene == null:
		push_error("RustBoss: 'Split Boss Scene' is not assigned — continuing without splitting.")
		return
	remove_from_group("boss")
	remove_from_group("enemy")
	is_active = false
	set_physics_process(false)
	attack_timer.stop()
	phase_timer.stop()
	damage_area.set_deferred("monitoring", false)

	for i in 2:
		var copy: RustBoss = split_boss_scene.instantiate()
		copy.is_split_copy = true
		copy.max_health = int(max_health / 2.0)
		copy.scale = scale * 0.5
		get_tree().current_scene.add_child(copy)
		copy.global_position = global_position + Vector2(-30 if i == 0 else 30, 0)
		copy.start_fight()

	queue_free()

func die() -> void:
	is_dead = true
	animated_sprite.play("death")
	set_physics_process(false)
	attack_timer.stop()
	phase_timer.stop()
	damage_area.set_deferred("monitoring", false)
	remove_from_group("boss")

	var any_boss_alive: bool = false
	for b in get_tree().get_nodes_in_group("boss"):
		if is_instance_valid(b) and not b.is_dead:
			any_boss_alive = true
			break

	if not any_boss_alive:
		var remover: RustRemover = rust_remover_scene.instantiate()
		get_tree().current_scene.call_deferred("add_child",remover)
		remover.global_position = global_position

	death_timer.start()

func return_surface():
	var player: Node = get_tree().get_first_node_in_group("player")
	if not player:
		return
	global_position = player.global_position + Vector2(0,-60)
	sound_played = false
	
# "signal" — HurtAnimTimer(Timer).timeout -> _on_hurt_anim_timer_timeout()
func _on_hurt_anim_timer_timeout() -> void:
	is_hurt_animating = false

# "signal" — DeathTimer(Timer).timeout -> _on_death_timer_timeout()
func _on_death_timer_timeout() -> void:
	queue_free()

# "signal" — DamageArea(Area2D).body_entered -> _on_damage_area_body_entered(body)
func _on_damage_area_body_entered(body: Node) -> void:
	if is_dead:
		return
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(1)


func _on_sound_timer_timeout() -> void:
	return_surface()
