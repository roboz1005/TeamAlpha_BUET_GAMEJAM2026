extends CharacterBody2D
class_name Player

@export var speed: float = 200.0
@export var jump_velocity: float = -280.0
@export var max_health: int = 3
@export var invincibility_time: float = 0.5
@export var fire_rate: float = 0.25
@export var death_reload_delay: float = 0.6


var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var health: int
var facing_left: bool = false
var is_dead: bool = false
var invincible: bool = false
var can_shoot: bool = true
var is_action_animating: bool = false
var normal_fire_rate: float

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var muzzle: Marker2D = $Muzzle
@onready var invincibility_timer: Timer = $InvincibilityTimer
@onready var action_anim_timer: Timer = $ActionAnimTimer
@onready var fire_rate_timer: Timer = $FireRateTimer
@onready var death_timer: Timer = $DeathTimer
@onready var burst_timer: Timer = $BurstTimer

func _ready() -> void:
	max_health += GameManager.max_health_bonus
	health = max_health
	normal_fire_rate = fire_rate
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var direction: float = Input.get_axis("move_left", "move_right")

	if direction > 0.0:
		facing_left = false
		animated_sprite.flip_h = false
	elif direction < 0.0:
		facing_left = true
		animated_sprite.flip_h = true

	if direction != 0.0:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)

	# Held down, not just-pressed — this is what makes fire auto-repeat while
	# the button is held. shoot() itself enforces the cooldown below.
	if Input.is_action_pressed("shoot"):
		shoot()

	_update_animation(direction)
	move_and_slide()

func _update_animation(direction: float) -> void:
	if is_action_animating:
		return
	if not is_on_floor():
		animated_sprite.play("jump")
	elif direction != 0.0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")

func _lock_animation(duration: float) -> void:
	is_action_animating = true
	action_anim_timer.start(duration)

func shoot() -> void:
	if not can_shoot or is_dead:
		return
	can_shoot = false
	fire_rate_timer.start(fire_rate)

	var info: Dictionary = GameManager.BULLET_CATALOG.get(GameManager.equipped_bullet, GameManager.BULLET_CATALOG["default"])
	var bullet_scene: PackedScene = load(info["scene"])
	var bullet: Bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	var offset_x: float = abs(muzzle.position.x)
	var spawn_x: float = -offset_x if facing_left else offset_x
	bullet.global_position = global_position + Vector2(spawn_x, muzzle.position.y)
	bullet.set_direction(-1.0 if facing_left else 1.0)
	animated_sprite.play("shoot")
	_lock_animation(0.2)

func heal(amount: int) -> void:
	health = min(health + amount, max_health)

func take_damage(amount: int = 1) -> void:
	if invincible or is_dead:
		return
	health -= amount
	if health <= 0:
		die()
	else:
		invincible = true
		animated_sprite.play("hurt")
		_lock_animation(invincibility_time)
		invincibility_timer.start(invincibility_time)

func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	animated_sprite.play("death")
	set_physics_process(false)
	death_timer.start(death_reload_delay)

func activate_burst_mode(burst_rate: float, duration: float) -> void:
	fire_rate = burst_rate
	burst_timer.start(duration)

# "signal" — BurstTimer(Timer).timeout -> _on_burst_timer_timeout()
func _on_burst_timer_timeout() -> void:
	fire_rate = normal_fire_rate

# "signal" — InvincibilityTimer(Timer).timeout -> _on_invincibility_timer_timeout()
func _on_invincibility_timer_timeout() -> void:
	invincible = false

# "signal" — ActionAnimTimer(Timer).timeout -> _on_action_anim_timer_timeout()
func _on_action_anim_timer_timeout() -> void:
	is_action_animating = false

# "signal" — FireRateTimer(Timer).timeout -> _on_fire_rate_timer_timeout()
func _on_fire_rate_timer_timeout() -> void:
	can_shoot = true

# "signal" — DeathTimer(Timer).timeout -> _on_death_timer_timeout()
func _on_death_timer_timeout() -> void:
	var level: Node = get_tree().current_scene
	if level and level.has_method("show_death_screen"):
		level.show_death_screen()
	else:
		GameManager.restart_current_scene()
