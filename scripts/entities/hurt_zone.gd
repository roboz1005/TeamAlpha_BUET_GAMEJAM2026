extends Area2D
class_name HurtZone

@export var damage: int = 1
@export var collision_shape : Vector2 = Vector2(100, 20)

func _process(delta: float) -> void:
	$CollisionShape2D.shape.extents = collision_shape  

# "signal" — HurtZone(Area2D).body_entered -> _on_body_entered(body)
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
