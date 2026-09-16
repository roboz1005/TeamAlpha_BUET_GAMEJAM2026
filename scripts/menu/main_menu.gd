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
@onready var reset_button: Button = $HBoxContainer/VBoxContainer2/ResetButton
@onready var reset_confirm_dialog: ConfirmationDialog = $ResetConfirmDialog

func _ready() -> void:
	MusicController.bgm_play()
	moon_button.disabled = not GameManager.unlocked_maps["moon"]
	mars_button.disabled = not GameManager.unlocked_maps["mars"]
	moon_lock_icon.visible = moon_button.disabled
	mars_lock_icon.visible = mars_button.disabled
	_update_difficulty_button()

func _update_difficulty_button() -> void:
	var label: String = "Hard" if GameManager.difficulty == "hard" else "Easy"
	difficulty_button.text = "%s" % label

# "signal" — DifficultyButton(Button).pressed -> _on_difficulty_button_pressed()
func _on_difficulty_button_pressed() -> void:
	GameManager.difficulty = "hard" if GameManager.difficulty == "easy" else "easy"
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

# "signal" — ResetButton(Button).pressed -> _on_reset_button_pressed()
func _on_reset_button_pressed() -> void:
	reset_confirm_dialog.popup_centered()

# "signal" — ResetConfirmDialog(ConfirmationDialog).confirmed -> _on_reset_confirm_dialog_confirmed()
func _on_reset_confirm_dialog_confirmed() -> void:
	GameManager.reset_all_progress()
	get_tree().reload_current_scene()
