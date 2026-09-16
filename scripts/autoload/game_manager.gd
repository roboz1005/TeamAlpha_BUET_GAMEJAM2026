extends Node

# ============================================================
#  GameManager — global game state. Autoloaded as "GameManager".
#  Per-level material counts are NOT here anymore — see earth_level.gd
#  (Section 10.1). Only true meta-progress lives in this Autoload.
# ============================================================

const MATERIAL_SCRAP := "scrap_metal"
const MATERIAL_FUEL := "fuel_cell"
const MATERIAL_ELECTRONICS := "electronics"
const MATERIAL_TYPES := [MATERIAL_SCRAP, MATERIAL_FUEL, MATERIAL_ELECTRONICS]

const EARTH_LEVEL_COUNT := 3
const EARTH_TIMER_LIMIT_EASY := 480.0    # 8 minutes
const EARTH_TIMER_LIMIT_HARD := 300.0    # 5 minutes
const EARTH_RUST_BONUS_TIME := 90.0

const EARTH_LEVEL_SCENES := [
	"res://scenes/levels/earth/earth_level_01.tscn",
	"res://scenes/levels/earth/earth_level_02.tscn",
	"res://scenes/levels/earth/earth_level_03.tscn",
]
const EARTH_BONUS_SCENE := "res://scenes/levels/earth/earth_bonus_rust.tscn"
const EARTH_ROCKET_BUILDER_SCENE := "res://scenes/rocket/rocket_builder.tscn"
const MAIN_MENU_SCENE := "res://scenes/menu/main_menu.tscn"
const EARTH_LEVEL_SELECT_SCENE := "res://scenes/menu/earth_level_select.tscn"
const SHOP_SCENE := "res://scenes/menu/shop.tscn"

const BULLET_CATALOG := {
	"default": {"name": "Standard Bolt", "cost": 0, "scene": "res://scenes/entities/bullet.tscn"},
	"fast": {"name": "Fast Round", "cost": 50, "scene": "res://scenes/entities/bullet_fast.tscn"},
	"row": {"name": "2 Bullet", "cost": 100, "scene": "res://scenes/entities/bullet_row.tscn"},
}
const POTION_COST := 200

# ---------- Persisted state ----------
var difficulty: String = "easy"    # "easy" or "hard"
var unlocked_maps: Dictionary = {"earth": true, "moon": false, "mars": false}
var map_completed: Dictionary = {"earth": false, "moon": false, "mars": false}

var coins: int = 0
var max_health_bonus: int = 0
var unlocked_bullets: Array[String] = ["default"]
var equipped_bullet: String = "default"

var earth_progress: Dictionary = {
	"easy": make_default_earth_progress("easy"),
	"hard": make_default_earth_progress("hard"),
}

func make_default_earth_progress(diff: String) -> Dictionary:
	return {
		"current_level": 0,
		"levels_cleared": [],
		"timer_remaining": EARTH_TIMER_LIMIT_HARD if diff == "hard" else EARTH_TIMER_LIMIT_EASY,
		"is_rusted": false,
		"pre_rust_level": 0,
		"rust_return_scene": "",
		"map_completed": false,
	}

var earth_current_level: int:
	get:
		return earth_progress[difficulty]["current_level"]
	set(value):
		earth_progress[difficulty]["current_level"] = value

var earth_levels_cleared: Array:
	get:
		return earth_progress[difficulty]["levels_cleared"]
	set(value):
		earth_progress[difficulty]["levels_cleared"] = value

var earth_timer_remaining: float:
	get:
		return earth_progress[difficulty]["timer_remaining"]
	set(value):
		earth_progress[difficulty]["timer_remaining"] = value

var earth_is_rusted: bool:
	get:
		return earth_progress[difficulty]["is_rusted"]
	set(value):
		earth_progress[difficulty]["is_rusted"] = value

var earth_pre_rust_level: int:
	get:
		return earth_progress[difficulty]["pre_rust_level"]
	set(value):
		earth_progress[difficulty]["pre_rust_level"] = value

var earth_rust_return_scene: String:
	get:
		return earth_progress[difficulty]["rust_return_scene"]
	set(value):
		earth_progress[difficulty]["rust_return_scene"] = value

# ---------- Runtime-only state (NOT saved) ----------
var earth_timer_running: bool = false

func _ready() -> void:
	SaveManager.load_game()

func _process(delta: float) -> void:
	# Only runs while the tree is unpaused (GameManager's Process Mode is left
	# at the default "Pausable") — that's what makes pausing pause the timer.
	if earth_timer_running and not earth_is_rusted:
		earth_timer_remaining -= delta
		if earth_timer_remaining <= 0.0:
			earth_timer_remaining = 0.0
			_trigger_earth_rust()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		SaveManager.save_game()
		get_tree().quit()

func get_earth_timer_limit() -> float:
	return EARTH_TIMER_LIMIT_HARD if difficulty == "hard" else EARTH_TIMER_LIMIT_EASY

# Each gameplay scene (level, bonus level) calls this from _ready()/_exit_tree()
# so the timer only runs while an actual level is loaded. Menus, the puzzle's
# own exit, and the Launch Rocket level (by design — see Section 13) leave it off.
func set_earth_timer_active(active: bool) -> void:
	earth_timer_running = active and not earth_is_rusted

func complete_earth_level(level_index: int) -> void:
	if not earth_levels_cleared.has(level_index):
		earth_levels_cleared.append(level_index)
	SaveManager.save_game()

func restart_current_scene() -> void:
	get_tree().reload_current_scene()

func complete_earth_map() -> void:
	earth_progress[difficulty]["map_completed"] = true
	map_completed["earth"] = true
	unlocked_maps["moon"] = true
	earth_timer_running = false
	SaveManager.save_game()
	get_tree().change_scene_to_file(EARTH_LEVEL_SELECT_SCENE)

func _trigger_earth_rust() -> void:
	earth_is_rusted = true
	earth_timer_running = false
	earth_pre_rust_level = earth_current_level
	earth_rust_return_scene = get_tree().current_scene.scene_file_path
	SaveManager.save_game()
	get_tree().change_scene_to_file(EARTH_BONUS_SCENE)

func clear_earth_rust() -> void:
	earth_is_rusted = false
	earth_timer_remaining += EARTH_RUST_BONUS_TIME
	earth_current_level = earth_pre_rust_level
	var return_scene: String = earth_rust_return_scene
	if return_scene == "":
		return_scene = EARTH_LEVEL_SCENES[earth_current_level]
	SaveManager.save_game()
	get_tree().change_scene_to_file(return_scene)

func reset_all_progress() -> void:
	difficulty = "easy"
	unlocked_maps = {"earth": true, "moon": false, "mars": false}
	map_completed = {"earth": false, "moon": false, "mars": false}
	earth_progress = {
		"easy": make_default_earth_progress("easy"),
		"hard": make_default_earth_progress("hard"),
	}
	coins = 0
	unlocked_bullets = ["default"]
	equipped_bullet = "default"
	max_health_bonus = 0
	SaveManager.save_game()

func add_coins(amount: int) -> void:
	coins += amount
	SaveManager.save_game()

func unlock_bullet(bullet_id: String) -> bool:
	if unlocked_bullets.has(bullet_id):
		return false
	var info: Dictionary = BULLET_CATALOG.get(bullet_id, {})
	var cost: int = info.get("cost", 0)
	if coins < cost:
		return false
	coins -= cost
	unlocked_bullets.append(bullet_id)
	SaveManager.save_game()
	return true

func equip_bullet(bullet_id: String) -> void:
	if unlocked_bullets.has(bullet_id):
		equipped_bullet = bullet_id
		SaveManager.save_game()

func buy_potion() -> bool:
	if coins < POTION_COST:
		return false
	coins -= POTION_COST
	max_health_bonus += 1
	SaveManager.save_game()
	return true
