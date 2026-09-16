extends Area2D
class_name EnemyProjectile

@export var speed: float = 220.0
@export var damage: int = 1
@export var lifetime: float = 2.0

var direction: Vector2 = Vector2.RIGHT

@onready var lifetime_timer: Timer = $LifetimeTimer

func _ready() -> void:
	lifetime_timer.start(lifetime)

func set_direction_vector(dir: Vector2) -> void:
	if dir.length() < 0.01:
		dir = Vector2.RIGHT
	direction = dir.normalized()
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

# "signal" — EnemyProjectile(Area2D).body_entered -> _on_body_entered(body)
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()

# "signal" — LifetimeTimer(Timer).timeout -> _on_lifetime_timer_timeout()
func _on_lifetime_timer_timeout() -> void:
	queue_free()
