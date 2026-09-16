extends Area2D
class_name MaterialPickup

@export_enum("scrap_metal", "fuel_cell", "electronics") var material_id: String = "scrap_metal"
@export var amount: int = 1
@export var texture_2d = Texture2D

var collected: bool = false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var pickup_sound: AudioStreamPlayer2D = $PickupSound

func _process(delta: float) -> void:
	$Sprite2D.texture = texture_2d
	scale = Vector2(0.3, 0.3)

# "signal" — MaterialPickup(Area2D).body_entered -> _on_body_entered(body)
func _on_body_entered(body: Node) -> void:
	if collected or not body.is_in_group("player"):
		return
	collected = true

	var level: Node = get_tree().current_scene
	if level and level.has_method("add_material"):
		level.add_material(material_id, amount)

	collision_shape.set_deferred("disabled", true)
	if pickup_sound.stream:
		pickup_sound.play()
	queue_free()
