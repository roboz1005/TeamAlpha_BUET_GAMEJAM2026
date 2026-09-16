extends Area2D
class_name Bullet

@export var speed: float = 800
@export var damage: int = 1
@export var lifetime: float = 1.5

var direction: float = 1.0

@onready var lifetime_timer: Timer = $LifetimeTimer

func _ready() -> void:
	lifetime_timer.start(lifetime)
	MusicController.bullet_music_play()

func set_direction(dir: float) -> void:
	direction = dir
	scale.x = dir

func _physics_process(delta: float) -> void:
	position.x += direction * speed * delta

# "signal" — Bullet(Area2D).body_entered -> _on_body_entered(body)
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemy") and body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()

# "signal" — LifetimeTimer(Timer).timeout -> _on_lifetime_timer_timeout()
func _on_lifetime_timer_timeout() -> void:
	queue_free()
