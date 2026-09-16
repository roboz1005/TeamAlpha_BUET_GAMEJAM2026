extends Node

const SAVE_FILE_NAME := "sojourner_save.json"
const SAVE_PATH := "user://" + SAVE_FILE_NAME

func save_game() -> void:
	var data := {
		"difficulty": GameManager.difficulty,
		"unlocked_maps": GameManager.unlocked_maps,
		"map_completed": GameManager.map_completed,
		"earth_current_level": GameManager.earth_current_level,
		"earth_levels_cleared": GameManager.earth_levels_cleared,
		"earth_timer_remaining": GameManager.earth_timer_remaining,
		"earth_is_rusted": GameManager.earth_is_rusted,
		"earth_pre_rust_level": GameManager.earth_pre_rust_level,
		"coins": GameManager.coins,
		"unlocked_bullets": GameManager.unlocked_bullets,
		"equipped_bullet": GameManager.equipped_bullet,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var text := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var data: Dictionary = parsed

	GameManager.difficulty = data.get("difficulty", "easy")
	GameManager.unlocked_maps = data.get("unlocked_maps", GameManager.unlocked_maps)
	GameManager.map_completed = data.get("map_completed", GameManager.map_completed)

	# JSON always returns numbers as float — cast every int field back explicitly.
	GameManager.earth_current_level = int(data.get("earth_current_level", 0))
	GameManager.earth_pre_rust_level = int(data.get("earth_pre_rust_level", 0))
	GameManager.earth_is_rusted = data.get("earth_is_rusted", false)
	GameManager.earth_timer_remaining = float(data.get("earth_timer_remaining", GameManager.get_earth_timer_limit()))
	GameManager.coins = int(data.get("coins", 0))
	GameManager.equipped_bullet = data.get("equipped_bullet", "default")
	var unlocked_raw: Array = data.get("unlocked_bullets", ["default"])
	var unlocked: Array[String] = []
	for v in unlocked_raw:
		unlocked.append(str(v))
	GameManager.unlocked_bullets = unlocked
	
	var cleared_raw: Array = data.get("earth_levels_cleared", [])
	var cleared: Array = []
	for v in cleared_raw:
		cleared.append(int(v))
	GameManager.earth_levels_cleared = cleared

# Optional — not wired to any UI. Call from the Debugger's "Execute" panel
# during testing to wipe progress and start over.
func reset_save() -> void:
	var dir := DirAccess.open("user://")
	if dir and dir.file_exists(SAVE_FILE_NAME):
		dir.remove(SAVE_FILE_NAME)
