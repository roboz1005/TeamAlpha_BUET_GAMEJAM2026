extends CanvasLayer
class_name HUD

var required_scrap: int = 0
var required_fuel: int = 0
var required_electronics: int = 0

@onready var materials_label: Label = $Control/MaterialsLabel
@onready var timer_label: Label = $Control/TimerLabel
@onready var hint_label: Label = $Control/HintLabel
@onready var hint_timer: Timer = $Control/HintTimer
@onready var pause_button: Button = $Control/PauseButton
@onready var pause_menu: PauseMenu = $PauseMenu

func _ready() -> void:
	hint_label.visible = false

func setup(scrap: int, fuel: int, electronics: int) -> void:
	required_scrap = scrap
	required_fuel = fuel
	required_electronics = electronics

func _process(_delta: float) -> void:
	_update_materials_label()
	_update_timer_label()

func _update_materials_label() -> void:
	materials_label.text = "Scrap: %d/%d   Fuel Cell: %d/%d   Electronics: %d/%d" % [
		GameManager.get_material_count(GameManager.MATERIAL_SCRAP), required_scrap,
		GameManager.get_material_count(GameManager.MATERIAL_FUEL), required_fuel,
		GameManager.get_material_count(GameManager.MATERIAL_ELECTRONICS), required_electronics,
	]

func _update_timer_label() -> void:
	var t: float = max(GameManager.earth_timer_remaining, 0.0)
	var minutes: int = int(t) / 60
	var seconds: int = int(t) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]

func flash_missing_materials() -> void:
	hint_label.text = "Find everything here before you move on!"
	hint_label.visible = true
	hint_timer.start(2.0)

# "signal" — PauseButton(Button).pressed -> _on_pause_button_pressed()
func _on_pause_button_pressed() -> void:
	get_tree().paused = true
	pause_menu.visible = true

# "signal" — HintTimer(Timer).timeout -> _on_hint_timer_timeout()
func _on_hint_timer_timeout() -> void:
	hint_label.visible = false
