extends CharacterBody2D
class_name RustBoss

@export var max_health: int = 20
@export var speed: float = 40.0
@export var shoot_interval: float = 2.0
@export var projectile_scene: PackedScene = preload("res://scenes/entities/enemy_projectile.tscn")
@export var rust_remover_scene: PackedScene = preload("res://scenes/entities/rust_remover.tscn")

var health: int
var direction: int = 1
var is_dead: bool = false
var is_hurt_animating: bool = false
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var wall_ray_right: RayCast2D = $WallRayRight
@onready var wall_ray_left: RayCast2D = $WallRayLeft
@onready var muzzle: Marker2D = $Muzzle
@onready var shoot_timer: Timer = $ShootTimer
@onready var damage_area: Area2D = $DamageArea
@onready var hurt_anim_timer: Timer = $HurtAnimTimer
@onready var death_timer: Timer = $DeathTimer

func _ready() -> void:
	health = max_health
	add_to_group("enemy")
	add_to_group("boss")
	shoot_timer.start(shoot_interval)

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.0

	var hit_wall: bool = (direction > 0 and wall_ray_right.is_colliding()) \
		or (direction < 0 and wall_ray_left.is_colliding())
	if hit_wall:
		direction *= -1

	velocity.x = direction * speed
	animated_sprite.flip_h = direction < 0
	if not is_hurt_animating:
		animated_sprite.play("move")
	move_and_slide()

func take_damage(amount: int = 1) -> void:
	if is_dead:
		return
	health -= amount
	if health <= 0:
		die()
	else:
		animated_sprite.play("hurt")
		is_hurt_animating = true
		hurt_anim_timer.start()

func die() -> void:
	is_dead = true
	animated_sprite.play("death")
	set_physics_process(false)
	shoot_timer.stop()
	damage_area.set_deferred("monitoring", false)
	var remover: RustRemover = rust_remover_scene.instantiate()
	get_tree().current_scene.add_child(remover)
	remover.global_position = global_position
	death_timer.start()

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

# "signal" — ShootTimer(Timer).timeout -> _on_shoot_timer_timeout()
func _on_shoot_timer_timeout() -> void:
	if is_dead:
		return
	var proj: EnemyProjectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(proj)
	var offset_x: float = abs(muzzle.position.x)
	var spawn_x: float = -offset_x if direction < 0 else offset_x
	proj.global_position = global_position + Vector2(spawn_x, muzzle.position.y)

	var player: Node = get_tree().get_first_node_in_group("player")
	var dir: float = 1.0
	if player:
		var diff: float = player.global_position.x - global_position.x
		dir = 1.0 if diff >= 0.0 else -1.0
	proj.set_direction(dir)
