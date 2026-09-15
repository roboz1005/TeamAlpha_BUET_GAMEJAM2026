extends Area2D
class_name MaterialPickup

@export_enum("scrap_metal", "fuel_cell", "electronics") var material_id: String = "scrap_metal"
@export var amount: int = 1

var collected: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var pickup_sound: AudioStreamPlayer2D = $PickupSound

# "signal" — MaterialPickup(Area2D).body_entered -> _on_body_entered(body)
func _on_body_entered(body: Node) -> void:
	if collected or not body.is_in_group("player"):
		return
	collected = true
	GameManager.add_material(material_id, amount)
	collision_shape.set_deferred("disabled", true)
	if pickup_sound.stream:
		pickup_sound.play()
	animated_sprite.play("pickup")

# "signal" — AnimatedSprite2D.animation_finished -> _on_animated_sprite_2d_animation_finished()
func _on_animated_sprite_2d_animation_finished() -> void:
	if collected:
		queue_free()
