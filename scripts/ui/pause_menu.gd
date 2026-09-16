extends CanvasLayer
class_name PauseMenu

@onready var resume_button: Button = $Control/VBoxContainer/ResumeButton
@onready var restart_button: Button = $Control/VBoxContainer/RestartButton
@onready var main_menu_button: Button = $Control/VBoxContainer/MainMenuButton

# "signal" — ResumeButton(Button).pressed -> _on_resume_button_pressed()
func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	visible = false

# "signal" — RestartButton(Button).pressed -> _on_restart_button_pressed()
func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	visible = false
	GameManager.restart_current_scene()

# "signal" — MainMenuButton(Button).pressed -> _on_main_menu_button_pressed()
func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	visible = false
	GameManager.set_earth_timer_active(false)
	SaveManager.save_game()
	get_tree().change_scene_to_file(GameManager.MAIN_MENU_SCENE)
