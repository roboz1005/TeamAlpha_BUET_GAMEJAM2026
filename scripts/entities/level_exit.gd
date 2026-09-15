extends Area2D
class_name LevelExit

# "signal" — LevelExit(Area2D).body_entered -> _on_body_entered(body)
func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	var level := get_tree().current_scene
	if level and level.has_method("try_finish_level"):
		level.try_finish_level()
