extends Area2D
class_name Bullet

@export var speed: float = 400.0
var direction: Vector2
var damage: int = 1
var _lifetime: float = 2.0

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	_lifetime -= delta
	if _lifetime <= 0:
		queue_free()

# "signal" — connect this Bullet's own body_entered to this function.
func _on_body_entered(body: Node) -> void:
	var source: String = get_meta("source", "")
	if source == "player" and (body.is_in_group("enemies") or body.is_in_group("doppelgangers")):
		body.take_hit(damage)
		queue_free()
	elif source == "doppelganger" and body.is_in_group("player"):
		body.take_hit(damage)
		queue_free()
	elif body.is_in_group("walls"):
		queue_free()

# "signal" — connect this Bullet's own area_entered to this function too.
# This is separate from body_entered because Hazard is itself an Area2D —
# Area-to-Area overlaps only ever fire area_entered, never body_entered, so
# a bullet could never have detected a hazard through body_entered alone.
func _on_area_entered(area: Area2D) -> void:
	if area is Hazard:
		queue_free()
