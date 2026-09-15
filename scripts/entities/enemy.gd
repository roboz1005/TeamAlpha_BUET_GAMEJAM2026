extends CharacterBody2D
class_name Enemy

@export var speed: float = 70.0
@export var max_health: int = 2
@export var contact_damage: int = 1

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

func _ready() -> void:
	health = max_health
	add_to_group("enemy")

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
	damage_area.set_deferred("monitoring", false)
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
		body.take_damage(contact_damage)
