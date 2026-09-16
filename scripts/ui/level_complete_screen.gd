extends CanvasLayer
class_name LevelCompleteScreen

@onready var continue_button: Button = $Control/VBoxContainer/ContinueButton
@onready var main_menu_button: Button = $Control/VBoxContainer/MainMenuButton


# "signal" — ContinueButton(Button).pressed -> _on_continue_button_pressed()
func _on_continue_button_pressed() -> void:
	get_tree().paused = false
	GameManager.set_earth_timer_active(false)
	get_tree().change_scene_to_file(GameManager.EARTH_LEVEL_SELECT_SCENE)

# "signal" — MainMenuButton(Button).pressed -> _on_main_menu_button_pressed()
func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	GameManager.set_earth_timer_active(false)
	SaveManager.save_game()
	get_tree().change_scene_to_file(GameManager.MAIN_MENU_SCENE)
