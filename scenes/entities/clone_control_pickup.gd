extends Area2D
class_name CloneControlPickup

func _ready() -> void:
	add_to_group("clone_control_pickups")

# "signal" — connect this node's own body_entered to this function.
func _on_body_entered(body: Node) -> void:
	if body is Player:
		body.held_clone_control_item = true
		queue_free()
