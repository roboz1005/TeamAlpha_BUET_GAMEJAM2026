extends Node

const SAVE_FILE_NAME := "sojourner_save.json"
const SAVE_PATH := "user://" + SAVE_FILE_NAME

func save_game() -> void:
	var data := {
		"difficulty": GameManager.difficulty,
		"unlocked_maps": GameManager.unlocked_maps,
		"map_completed": GameManager.map_completed,
		"earth_progress": GameManager.earth_progress,
		"coins": GameManager.coins,
		"unlocked_bullets": GameManager.unlocked_bullets,
		"equipped_bullet": GameManager.equipped_bullet,
		"max_health_bonus": GameManager.max_health_bonus,
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
	GameManager.coins = int(data.get("coins", 0))
	GameManager.equipped_bullet = data.get("equipped_bullet", "default")
	GameManager.max_health_bonus = int(data.get("max_health_bonus", 0))

	var unlocked_raw: Array = data.get("unlocked_bullets", ["default"])
	var unlocked: Array[String] = []
	for v in unlocked_raw:
		unlocked.append(str(v))
	GameManager.unlocked_bullets = unlocked

	# earth_progress is nested per difficulty, so rebuild each slot explicitly —
	# JSON always returns numbers as float, so every int field is cast back.
	var progress_raw: Dictionary = data.get("earth_progress", {})
	for diff in ["easy", "hard"]:
		var saved: Dictionary = progress_raw.get(diff, {})
		var clean: Dictionary = GameManager.make_default_earth_progress(diff)
		clean["current_level"] = int(saved.get("current_level", clean["current_level"]))
		clean["timer_remaining"] = float(saved.get("timer_remaining", clean["timer_remaining"]))
		clean["is_rusted"] = saved.get("is_rusted", clean["is_rusted"])
		clean["pre_rust_level"] = int(saved.get("pre_rust_level", clean["pre_rust_level"]))
		clean["rust_return_scene"] = saved.get("rust_return_scene", clean["rust_return_scene"])
		clean["map_completed"] = saved.get("map_completed", clean["map_completed"])
		var cleared_raw: Array = saved.get("levels_cleared", [])
		var cleared: Array = []
		for v in cleared_raw:
			cleared.append(int(v))
		clean["levels_cleared"] = cleared
		GameManager.earth_progress[diff] = clean

# Optional — not wired to any UI. Call from the Debugger's "Execute" panel
# during testing to wipe progress and start over.
func reset_save() -> void:
	var dir := DirAccess.open("user://")
	if dir and dir.file_exists(SAVE_FILE_NAME):
		dir.remove(SAVE_FILE_NAME)
