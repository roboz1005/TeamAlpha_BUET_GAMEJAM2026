extends Area2D
class_name Bush

var compromised: bool = false

func _ready() -> void:
	add_to_group("bushes")

func hides(pos: Vector2) -> bool:
	return not compromised and global_position.distance_to(pos) < 40

func compromise() -> void:
	compromised = true
	modulate = Color(1, 0.6, 0.6)   # visual tell the hideout is blown
