extends Node
class_name RecordingComponent

var recording: RoundRecording
var _frame_count: int = 0

func _ready() -> void:
	recording = RoundRecording.new()

func _physics_process(_delta: float) -> void:
	var body := get_parent() as Node2D
	recording.positions.append(body.global_position)
	recording.rotations.append(body.rotation)
	_frame_count += 1

func log_action(type: String, extra: Dictionary = {}) -> void:
	var entry := {"frame": _frame_count, "type": type}
	entry.merge(extra)
	recording.actions.append(entry)

func mark_death(hazard_id: String) -> void:
	recording.death_hazard_id = hazard_id
	recording.death_frame = _frame_count
