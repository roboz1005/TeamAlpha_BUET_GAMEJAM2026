extends Area2D
class_name Coin

@export var value: int = 5

# "signal" — Coin(Area2D).body_entered -> _on_body_entered(body)
func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	GameManager.add_coins(value)
	queue_free()
