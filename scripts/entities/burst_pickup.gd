extends Area2D
class_name BurstPickup

@export var burst_fire_rate: float = 0.05
@export var burst_duration: float = 5.0

# "signal" — BurstPickup(Area2D).body_entered -> _on_body_entered(body)
func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if body.has_method("activate_burst_mode"):
		body.activate_burst_mode(burst_fire_rate, burst_duration)
	queue_free()
