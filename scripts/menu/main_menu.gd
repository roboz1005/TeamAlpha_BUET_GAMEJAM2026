extends Control
class_name MainMenu

@onready var earth_button: Button = $VBoxContainer/EarthButton
@onready var moon_button: Button = $VBoxContainer/MoonButton
@onready var mars_button: Button = $VBoxContainer/MarsButton
@onready var moon_lock_icon: TextureRect = $VBoxContainer/MoonButton/LockIcon
@onready var mars_lock_icon: TextureRect = $VBoxContainer/MarsButton/LockIcon
@onready var quit_button: Button = $VBoxContainer/QuitButton

func _ready() -> void:
	moon_button.disabled = not GameManager.unlocked_maps["moon"]
	mars_button.disabled = not GameManager.unlocked_maps["mars"]
	moon_lock_icon.visible = moon_button.disabled
	mars_lock_icon.visible = mars_button.disabled

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
