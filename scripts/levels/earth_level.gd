extends Node2D
class_name EarthLevel

@export var level_index: int = 0
@export var required_scrap: int = 0
@export var required_fuel: int = 0
@export var required_electronics: int = 0

var collected_materials: Dictionary = {}

@onready var hud: HUD = $EarthLevelTemplate/HUD
@onready var death_screen: DeathScreen = $EarthLevelTemplate/DeathScreen
@onready var level_complete_screen: LevelCompleteScreen = $EarthLevelTemplate/LevelCompleteScreen

func _ready() -> void:
	for m in GameManager.MATERIAL_TYPES:
		collected_materials[m] = 0
	GameManager.set_earth_timer_active(true)
	hud.setup(required_scrap, required_fuel, required_electronics)
	death_screen.visible = false
	level_complete_screen.visible = false

func _exit_tree() -> void:
	GameManager.set_earth_timer_active(false)

func add_material(material_id: String, amount: int = 1) -> void:
	collected_materials[material_id] = collected_materials.get(material_id, 0) + amount

func get_material_count(material_id: String) -> int:
	return collected_materials.get(material_id, 0)

func materials_complete() -> bool:
	return get_material_count(GameManager.MATERIAL_SCRAP) >= required_scrap \
		and get_material_count(GameManager.MATERIAL_FUEL) >= required_fuel \
		and get_material_count(GameManager.MATERIAL_ELECTRONICS) >= required_electronics

func try_finish_level() -> void:
	if materials_complete():
		GameManager.complete_earth_level(level_index)
		hud.visible = false
		level_complete_screen.visible = true
		get_tree().paused = true
	else:
		hud.flash_missing_materials()

func show_death_screen() -> void:
	hud.visible = false
	death_screen.visible = true
	get_tree().paused = true
