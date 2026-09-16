extends Control
class_name MainMenu

@onready var difficulty_button: Button = $HBoxContainer/VBoxContainer2/DifficultyButton
@onready var earth_button: Button = $HBoxContainer/VBoxContainer/EarthButton
@onready var moon_button: Button = $HBoxContainer/VBoxContainer/MoonButton
@onready var mars_button: Button = $HBoxContainer/VBoxContainer/MarsButton
@onready var moon_lock_icon: TextureRect = $HBoxContainer/VBoxContainer/MoonButton/LockIcon
@onready var mars_lock_icon: TextureRect = $HBoxContainer/VBoxContainer/MarsButton/LockIcon
@onready var quit_button: Button = $HBoxContainer/VBoxContainer2/QuitButton
@onready var store_button: Button = $HBoxContainer/VBoxContainer2/StoreButton

func _ready() -> void:
	moon_button.disabled = not GameManager.unlocked_maps["moon"]
	mars_button.disabled = not GameManager.unlocked_maps["mars"]
	moon_lock_icon.visible = moon_button.disabled
	mars_lock_icon.visible = mars_button.disabled
	_update_difficulty_button()

func _is_difficulty_locked() -> bool:
	return GameManager.earth_current_level > 0 or not GameManager.earth_levels_cleared.is_empty()

func _update_difficulty_button() -> void:
	var locked: bool = _is_difficulty_locked()
	difficulty_button.disabled = locked
	var label: String = "Hard" if GameManager.difficulty == "Hard" else "Easy"
	difficulty_button.text = "Difficulty: %s%s" % [label, " (locked)" if locked else ""]

# "signal" — DifficultyButton(Button).pressed -> _on_difficulty_button_pressed()
func _on_difficulty_button_pressed() -> void:
	if _is_difficulty_locked():
		return
	GameManager.difficulty = "Hard" if GameManager.difficulty == "Easy" else "Easy"
	GameManager.earth_timer_remaining = GameManager.get_earth_timer_limit()
	SaveManager.save_game()
	_update_difficulty_button()

# "signal" — EarthButton(Button).pressed -> _on_earth_button_pressed()
func _on_earth_button_pressed() -> void:
	get_tree().change_scene_to_file(GameManager.EARTH_LEVEL_SELECT_SCENE)

# "signal" — MoonButton(Button).pressed -> _on_moon_button_pressed()
func _on_moon_button_pressed() -> void:
	pass  # Moon map is built in Part 2 of this guide.

# "signal" — MarsButton(Button).pressed -> _on_mars_button_pressed()
func _on_mars_button_pressed() -> void:
	pass  # Mars map is built in Part 2 of this guide.

# "signal" — QuitButton(Button).pressed -> _on_quit_button_pressed()
func _on_quit_button_pressed() -> void:
	SaveManager.save_game()
	get_tree().quit()


# "signal" — StoreButton(Button).pressed -> _on_store_button_pressed()
func _on_store_button_pressed() -> void:
	get_tree().change_scene_to_file(GameManager.SHOP_SCENE)
