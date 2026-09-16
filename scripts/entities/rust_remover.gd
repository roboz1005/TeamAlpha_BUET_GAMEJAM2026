extends Area2D
class_name RustRemover

# "signal" — RustRemover(Area2D).body_entered -> _on_body_entered(body)
func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	MusicController.pickup_music_play()
	GameManager.clear_earth_rust()
	queue_free()
