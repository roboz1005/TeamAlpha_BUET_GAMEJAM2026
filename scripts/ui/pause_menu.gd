extends CanvasLayer
class_name PauseMenu

@onready var resume_button: Button = $Control/VBoxContainer/ResumeButton
@onready var quit_button: Button = $Control/VBoxContainer/QuitButton

# "signal" — ResumeButton(Button).pressed -> _on_resume_button_pressed()
func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	visible = false

# "signal" — QuitButton(Button).pressed -> _on_quit_button_pressed()
func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	visible = false
	GameManager.set_earth_timer_active(false)
	SaveManager.save_game()
	get_tree().change_scene_to_file(GameManager.MAIN_MENU_SCENE)
