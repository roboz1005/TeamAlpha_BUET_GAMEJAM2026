extends Area2D
class_name KillZone

# "signal" — KillZone(Area2D).body_entered -> _on_body_entered(body)
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("die"):
		body.die()
