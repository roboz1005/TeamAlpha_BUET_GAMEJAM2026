extends Control
class_name EarthLevelSelect

@onready var level_01_button: Button = $Background/HBoxContainer/VBoxContainer/Level01Button
@onready var level_02_button: Button = $Background/HBoxContainer/VBoxContainer/Level02Button
@onready var level_03_button: Button = $Background/HBoxContainer/VBoxContainer/Level03Button
@onready var rocket_button: Button = $Background/HBoxContainer/VBoxContainer2/RocketButton
@onready var back_button: Button = $Background/HBoxContainer/VBoxContainer2/BackButton

func _ready() -> void:
	# "starting any level with 0 global timer triggers the rust boss" —
	# this is the single choke point every path into Earth's levels passes
	# through, so it's the only place this check needs to live.
	if GameManager.earth_is_rusted:
		get_tree().call_deferred("change_scene_to_file", (GameManager.EARTH_BONUS_SCENE))
		return

	var buttons: Array[Button] = [level_01_button, level_02_button, level_03_button]
	for i in buttons.size():
		var unlocked: bool = i == 0 or GameManager.earth_levels_cleared.has(i - 1) or GameManager.earth_levels_cleared.has(i)
		buttons[i].disabled = not unlocked

	var all_cleared: bool = GameManager.earth_levels_cleared.size() >= GameManager.EARTH_LEVEL_COUNT
	rocket_button.disabled = not all_cleared

# "signal" — Level1Button(Button).pressed -> _on_level_01_button_pressed()
func _on_level_01_button_pressed() -> void:
	_start_level(0)

# "signal" — Level2Button(Button).pressed -> _on_level2_button_pressed()
func _on_level_02_button_pressed() -> void:
	_start_level(1)

# "signal" — Level3Button(Button).pressed -> _on_level3_button_pressed()
func _on_level_03_button_pressed() -> void:
	_start_level(2)

func _start_level(index: int) -> void:
	if GameManager.earth_is_rusted:
		get_tree().change_scene_to_file(GameManager.EARTH_BONUS_SCENE)
		return
	GameManager.earth_current_level = index
	get_tree().change_scene_to_file(GameManager.EARTH_LEVEL_SCENES[index])

# "signal" — RocketButton(Button).pressed -> _on_rocket_button_pressed()
func _on_rocket_button_pressed() -> void:
	if GameManager.earth_is_rusted:
		get_tree().change_scene_to_file(GameManager.EARTH_BONUS_SCENE)
		return
	get_tree().change_scene_to_file(GameManager.EARTH_ROCKET_BUILDER_SCENE)

# "signal" — BackButton(Button).pressed -> _on_back_button_pressed()
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(GameManager.MAIN_MENU_SCENE)
