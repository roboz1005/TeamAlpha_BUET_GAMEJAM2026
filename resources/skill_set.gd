extends Resource
class_name SkillSet

@export var damage_level: int = 0
@export var fire_rate_level: int = 0
@export var move_speed_level: int = 0
@export var max_health_level: int = 0
@export var has_clone_control: bool = false

func duplicate_skills() -> SkillSet:
	return self.duplicate(true)
