extends Camera2D
class_name CameraRig

var follow_target: Node2D

func _process(_delta: float) -> void:
	if is_instance_valid(follow_target):
		global_position = global_position.lerp(follow_target.global_position, 0.15)
