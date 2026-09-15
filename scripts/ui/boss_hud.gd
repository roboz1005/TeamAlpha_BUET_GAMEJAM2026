extends CanvasLayer
class_name BossHUD

var boss: Node = null

@onready var health_bar: ProgressBar = $Control/BossHealthBar
@onready var hint_label: Label = $Control/HintLabel
@onready var pause_button: Button = $Control/PauseButton
@onready var pause_menu: PauseMenu = $PauseMenu

func _ready() -> void:
	hint_label.text = "Defeat the Rust Boss and grab the Rust Remover it drops!"
	boss = get_tree().get_first_node_in_group("boss")
	if boss:
		health_bar.max_value = boss.max_health
		health_bar.value = boss.health

func _process(_delta: float) -> void:
	if is_instance_valid(boss):
		health_bar.value = boss.health
	else:
		health_bar.value = 0

# "signal" — PauseButton(Button).pressed -> _on_pause_button_pressed()
func _on_pause_button_pressed() -> void:
	get_tree().paused = true
	pause_menu.visible = true
