extends Area2D
class_name EnemyProjectile

@export var speed: float = 220.0
@export var damage: int = 1
@export var lifetime: float = 3.0

var direction: float = 1.0

@onready var lifetime_timer: Timer = $LifetimeTimer

func _ready() -> void:
	lifetime_timer.start(lifetime)

func set_direction(dir: float) -> void:
	direction = dir
	scale.x = dir if dir != 0.0 else 1.0

func _physics_process(delta: float) -> void:
	position.x += direction * speed * delta

# "signal" — EnemyProjectile(Area2D).body_entered -> _on_body_entered(body)
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()

# "signal" — LifetimeTimer(Timer).timeout -> _on_lifetime_timer_timeout()
func _on_lifetime_timer_timeout() -> void:
	queue_free()
