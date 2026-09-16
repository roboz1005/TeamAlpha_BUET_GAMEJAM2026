extends CharacterBody2D
class_name Enemy

@export var speed: float = 70.0
@export var max_health: int = 2
@export var contact_damage: int = 1
@export var hard_mode_shoot_interval: float = 2.5
@export var enemy_projectile_scene: PackedScene = preload("res://scenes/entities/enemy_projectile.tscn")
@export var coin_scene: PackedScene = preload("res://scenes/entities/coin.tscn")
@export var health_pickup_scene: PackedScene = preload("res://scenes/entities/health_pickup.tscn")
@export var burst_pickup_scene: PackedScene = preload("res://scenes/entities/burst_pickup.tscn")
@export var coin_drop_chance: float = 0.5
@export var health_drop_chance: float = 0.15
@export var burst_drop_chance: float = 0.10

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: int = 1
var health: int
var is_dead: bool = false
var is_hurt_animating: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var wall_ray_right: RayCast2D = $WallRayRight
@onready var wall_ray_left: RayCast2D = $WallRayLeft
@onready var floor_ray_right: RayCast2D = $FloorRayRight
@onready var floor_ray_left: RayCast2D = $FloorRayLeft
@onready var damage_area: Area2D = $DamageArea
@onready var hurt_anim_timer: Timer = $HurtAnimTimer
@onready var death_timer: Timer = $DeathTimer
@onready var shoot_timer: Timer = $ShootTimer

func _ready() -> void:
	health = max_health
	add_to_group("enemy")
	# Hard mode: regular enemies shoot too, on top of contact damage.
	if GameManager.difficulty == "hard":
		shoot_timer.start(hard_mode_shoot_interval)

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.0

	var hit_wall: bool = (direction > 0 and wall_ray_right.is_colliding()) \
		or (direction < 0 and wall_ray_left.is_colliding())
	var about_to_fall: bool = (direction > 0 and not floor_ray_right.is_colliding()) \
		or (direction < 0 and not floor_ray_left.is_colliding())
	if hit_wall or about_to_fall:
		direction *= -1

	velocity.x = direction * speed
	animated_sprite.flip_h = direction < 0
	if not is_hurt_animating:
		animated_sprite.play("walk")
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
	_drop_loot()
	death_timer.start()

func _drop_loot() -> void:
	if randf() < coin_drop_chance:
		var coin: Coin = coin_scene.instantiate()
		get_tree().current_scene.add_child(coin)
		coin.global_position = global_position

	var roll: float = randf()
	if roll < health_drop_chance:
		var drop: HealthPickup = health_pickup_scene.instantiate()
		get_tree().current_scene.add_child(drop)
		drop.global_position = global_position
	elif roll < health_drop_chance + burst_drop_chance:
		var drop: BurstPickup = burst_pickup_scene.instantiate()
		get_tree().current_scene.add_child(drop)
		drop.global_position = global_position

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
		body.take_damage(contact_damage)

# "signal" — ShootTimer(Timer).timeout -> _on_shoot_timer_timeout()
func _on_shoot_timer_timeout() -> void:
	if is_dead:
		return
	var player: Node = get_tree().get_first_node_in_group("player")
	if not player:
		return
	var dir: Vector2 = player.global_position - global_position
	if dir.length() < 1.0:
		dir = Vector2.RIGHT
	var proj: EnemyProjectile = enemy_projectile_scene.instantiate()
	get_tree().current_scene.add_child(proj)
	proj.global_position = global_position
	proj.set_direction_vector(dir.normalized())
