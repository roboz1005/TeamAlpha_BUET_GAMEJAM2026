extends Area2D
class_name Hazard

@export var hazard_id: String = "hazard_pit_01"   # unique per placed instance

func _ready() -> void:
	add_to_group(hazard_id)     # lets a doppelganger recall "the hazard that killed me"
	add_to_group("hazards")

# "signal" — connect this Hazard's own body_entered to this function.
func _on_body_entered(body: Node) -> void:
	if body is Player:
		body.die(hazard_id)
	elif body is Doppelganger:
		body.take_hit(999, false)   # false = not player-caused
