extends Node

# ============================================================
#  SaveManager — reads/writes the JSON save file. Autoloaded as
#  "SaveManager". Called by GameManager whenever state changes.
# ============================================================

const SAVE_FILE_NAME := "sojourner_save.json"
const SAVE_PATH := "user://" + SAVE_FILE_NAME

func save_game() -> void:
	var data := {
		"unlocked_maps": GameManager.unlocked_maps,
		"map_completed": GameManager.map_completed,
		"earth_current_level": GameManager.earth_current_level,
		"earth_levels_cleared": GameManager.earth_levels_cleared,
		"earth_materials": GameManager.earth_materials,
		"earth_timer_remaining": GameManager.earth_timer_remaining,
		"earth_is_rusted": GameManager.earth_is_rusted,
		"earth_pre_rust_level": GameManager.earth_pre_rust_level,
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

	GameManager.unlocked_maps = data.get("unlocked_maps", GameManager.unlocked_maps)
	GameManager.map_completed = data.get("map_completed", GameManager.map_completed)

	# JSON always returns numbers as float — cast every int field back explicitly.
	GameManager.earth_current_level = int(data.get("earth_current_level", 0))
	GameManager.earth_pre_rust_level = int(data.get("earth_pre_rust_level", 0))
	GameManager.earth_is_rusted = data.get("earth_is_rusted", false)
	GameManager.earth_timer_remaining = float(data.get("earth_timer_remaining", GameManager.EARTH_TIMER_LIMIT))

	var cleared_raw: Array = data.get("earth_levels_cleared", [])
	var cleared: Array = []
	for v in cleared_raw:
		cleared.append(int(v))
	GameManager.earth_levels_cleared = cleared

	var materials_raw: Dictionary = data.get("earth_materials", {})
	for key in materials_raw.keys():
		GameManager.earth_materials[key] = int(materials_raw[key])

# Optional utility — not wired to any UI button. Call from the Debugger's
# "Execute" panel during testing if you want to wipe progress and start over.
func reset_save() -> void:
	var dir := DirAccess.open("user://")
	if dir and dir.file_exists(SAVE_FILE_NAME):
		dir.remove(SAVE_FILE_NAME)
