extends Node

# ============================================================
#  GameManager — global game state. Autoloaded as "GameManager".
#  Never instance this manually — it's a singleton.
# ============================================================

# ---------- Material types ----------
const MATERIAL_SCRAP := "scrap_metal"
const MATERIAL_FUEL := "fuel_cell"
const MATERIAL_ELECTRONICS := "electronics"
const MATERIAL_TYPES := [MATERIAL_SCRAP, MATERIAL_FUEL, MATERIAL_ELECTRONICS]

# ---------- Earth map configuration ----------
const EARTH_LEVEL_COUNT := 3
const EARTH_TIMER_LIMIT := 180.0     # 8 minutes of actual playtime — see Section 15
const EARTH_RUST_BONUS_TIME := 90.0  # seconds granted after clearing the bonus level

const EARTH_LEVEL_SCENES := [
	"res://scenes/levels/earth/earth_level_01.tscn",
	"res://scenes/levels/earth/earth_level_02.tscn",
	"res://scenes/levels/earth/earth_level_03.tscn",
]
const EARTH_BONUS_SCENE := "res://scenes/levels/earth/earth_bonus_rust.tscn"
const EARTH_ROCKET_BUILDER_SCENE := "res://scenes/rocket/rocket_builder.tscn"
const MAIN_MENU_SCENE := "res://scenes/menu/main_menu.tscn"
const EARTH_LEVEL_SELECT_SCENE := "res://scenes/menu/earth_level_select.tscn"

# ---------- Persisted state (saved/loaded by SaveManager) ----------
var unlocked_maps: Dictionary = {"earth": true, "moon": false, "mars": false}
var map_completed: Dictionary = {"earth": false, "moon": false, "mars": false}

var earth_current_level: int = 0
var earth_levels_cleared: Array = []
var earth_materials: Dictionary = {}
var earth_timer_remaining: float = EARTH_TIMER_LIMIT
var earth_is_rusted: bool = false
var earth_pre_rust_level: int = 0

# ---------- Runtime-only state (NOT saved) ----------
var earth_timer_running: bool = false

func _ready() -> void:
	for m in MATERIAL_TYPES:
		earth_materials[m] = 0
	SaveManager.load_game()

func _process(delta: float) -> void:
	# This only runs while the SceneTree is unpaused — GameManager's Process
	# Mode is left at the default "Pausable", so get_tree().paused = true
	# automatically stops this without any extra code. That's what makes
	# pausing pause the timer.
	if earth_timer_running and not earth_is_rusted:
		earth_timer_remaining -= delta
		if earth_timer_remaining <= 0.0:
			earth_timer_remaining = 0.0
			_trigger_earth_rust()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		SaveManager.save_game()
		get_tree().quit()

# ---------- Timer control ----------
# Each Earth level (and the bonus level) calls this from _ready()/_exit_tree()
# so the timer only ever runs while an actual gameplay level is loaded.
func set_earth_timer_active(active: bool) -> void:
	earth_timer_running = active and not earth_is_rusted

# ---------- Materials ----------
func add_material(material_id: String, amount: int = 1) -> void:
	earth_materials[material_id] = earth_materials.get(material_id, 0) + amount
	SaveManager.save_game()

func get_material_count(material_id: String) -> int:
	return earth_materials.get(material_id, 0)

# ---------- Level flow ----------
func complete_earth_level(level_index: int) -> void:
	if not earth_levels_cleared.has(level_index):
		earth_levels_cleared.append(level_index)

	if level_index + 1 < EARTH_LEVEL_COUNT:
		earth_current_level = level_index + 1
		SaveManager.save_game()
		get_tree().call_deferred("change_scene_to_file", EARTH_LEVEL_SCENES[earth_current_level])
	else:
		SaveManager.save_game()
		get_tree().call_deferred("change_scene_to_file", EARTH_ROCKET_BUILDER_SCENE)

func restart_current_earth_level() -> void:
	get_tree().reload_current_scene()

func complete_earth_map() -> void:
	map_completed["earth"] = true
	unlocked_maps["moon"] = true
	earth_timer_running = false
	SaveManager.save_game()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

# ---------- Rust / bonus-level flow ----------
func _trigger_earth_rust() -> void:
	earth_is_rusted = true
	earth_timer_running = false
	earth_pre_rust_level = earth_current_level
	SaveManager.save_game()
	get_tree().change_scene_to_file(EARTH_BONUS_SCENE)

func clear_earth_rust() -> void:
	earth_is_rusted = false
	earth_timer_remaining += EARTH_RUST_BONUS_TIME
	earth_current_level = earth_pre_rust_level
	SaveManager.save_game()
	get_tree().change_scene_to_file(EARTH_LEVEL_SCENES[earth_current_level])
