extends Control
class_name EarthLevelSelect

@onready var level_01_button: Button = $Background/VBoxContainer/Level01Button
@onready var level_02_button: Button = $Background/VBoxContainer/Level02Button
@onready var level_03_button: Button = $Background/VBoxContainer/Level03Button
@onready var back_button: Button = $Background/VBoxContainer/BackButton

func _ready() -> void:
	var buttons: Array[Button] = [level_01_button, level_02_button, level_03_button]
	for i in buttons.size():
		var unlocked: bool = i <= GameManager.earth_current_level or GameManager.earth_levels_cleared.has(i)
		buttons[i].disabled = not unlocked

# "signal" — Level1Button(Button).pressed -> _on_level_01_button_pressed()
func _on_level_01_button_pressed() -> void:
	_start_level(0)

# "signal" — Level2Button(Button).pressed -> _on_level_02_button_pressed()
func _on_level_02_button_pressed() -> void:
	_start_level(1)

# "signal" — Level3Button(Button).pressed -> _on_level_03_button_pressed()
func _on_level_03_button_pressed() -> void:
	_start_level(2)

func _start_level(index: int) -> void:
	GameManager.earth_current_level = index
	get_tree().change_scene_to_file(GameManager.EARTH_LEVEL_SCENES[index])

# "signal" — BackButton(Button).pressed -> _on_back_button_pressed()
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(GameManager.MAIN_MENU_SCENE)
