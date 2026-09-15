extends Node2D
class_name EarthLevel

@export var level_index: int = 0
@export var required_scrap: int = 0
@export var required_fuel: int = 0
@export var required_electronics: int = 0

@onready var hud: HUD = $HUD

func _ready() -> void:
	GameManager.set_earth_timer_active(true)
	hud.setup(required_scrap, required_fuel, required_electronics)

func _exit_tree() -> void:
	GameManager.set_earth_timer_active(false)

func materials_complete() -> bool:
	return GameManager.get_material_count(GameManager.MATERIAL_SCRAP) >= required_scrap \
		and GameManager.get_material_count(GameManager.MATERIAL_FUEL) >= required_fuel \
		and GameManager.get_material_count(GameManager.MATERIAL_ELECTRONICS) >= required_electronics

func try_finish_level() -> void:
	if materials_complete():
		GameManager.complete_earth_level(level_index)
	else:
		hud.flash_missing_materials()
