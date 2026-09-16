extends CanvasLayer
class_name BossIntro

@onready var fight_button: Button = $Control/VBoxContainer/FightButton
@onready var main_menu_button: Button = $Control/VBoxContainer/MainMenuButton

# "signal" — FightButton(Button).pressed -> _on_fight_button_pressed()
func _on_fight_button_pressed() -> void:
	get_tree().paused = false
	visible = false
	var boss: Node = get_tree().get_first_node_in_group("boss")
	if boss:
		boss.start_fight()

# "signal" — MainMenuButton(Button).pressed -> _on_main_menu_button_pressed()
func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	GameManager.set_earth_timer_active(false)
	SaveManager.save_game()
	get_tree().change_scene_to_file(GameManager.MAIN_MENU_SCENE)
