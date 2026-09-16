extends AnimatableBody2D
class_name MovingPlatform

@export var point_b_offset: Vector2 = Vector2(200, 0)   # (X, 0) = horizontal, (0, Y) = vertical, set per instance
@export var move_speed: float = 60.0
@export var pause_at_ends: float = 0.5

var point_a: Vector2
var point_b: Vector2
var moving_to_b: bool = true
var is_paused: bool = false

@onready var pause_timer: Timer = $PauseTimer

func _ready() -> void:
	point_a = global_position
	point_b = global_position + point_b_offset

func _physics_process(delta: float) -> void:
	if is_paused:
		return
	var target: Vector2 = point_b if moving_to_b else point_a
	var to_target: Vector2 = target - global_position
	if to_target.length() <= move_speed * delta:
		global_position = target
		moving_to_b = not moving_to_b
		is_paused = true
		pause_timer.start(pause_at_ends)
	else:
		global_position += to_target.normalized() * move_speed * delta

# "signal" — PauseTimer(Timer).timeout -> _on_pause_timer_timeout()
func _on_pause_timer_timeout() -> void:
	is_paused = false
