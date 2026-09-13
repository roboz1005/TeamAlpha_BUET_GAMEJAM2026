extends Resource
class_name RoundRecording

@export var round_number: int = 0
@export var positions: PackedVector2Array = PackedVector2Array()
@export var rotations: PackedFloat32Array = PackedFloat32Array()
@export var actions: Array[Dictionary] = []       # e.g. {frame:int, type:"shoot", dir:float}
@export var death_hazard_id: String = ""          # "" if the round was completed, not died
@export var death_frame: int = -1
@export var skills_snapshot: SkillSet
