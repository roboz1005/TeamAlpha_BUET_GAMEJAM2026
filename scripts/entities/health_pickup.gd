extends Area2D
class_name HealthPickup

@export var heal_amount: int = 1

# "signal" — HealthPickup(Area2D).body_entered -> _on_body_entered(body)
func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if body.has_method("heal"):
		body.heal(heal_amount)
	queue_free()
