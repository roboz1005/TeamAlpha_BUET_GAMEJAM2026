extends CanvasLayer
class_name BossHUD

var max_total_health: int = 0

@onready var health_bar: ProgressBar = $Control/BossHealthBar
@onready var hint_label: Label = $Control/HintLabel
@onready var pause_button: Button = $Control/PauseButton
@onready var hp_label: Label = $Control/HPLabel
@onready var pause_menu: PauseMenu = $PauseMenu
@onready var player: Player = $"../Player"


func _ready() -> void:
	hint_label.text = "Defeat the RustMan and grab the Rust Remover it drops!"
	for b in get_tree().get_nodes_in_group("boss"):
		max_total_health += b.max_health
	health_bar.max_value = max(max_total_health, 1)

func _process(_delta: float) -> void:
	var total: int = 0
	for b in get_tree().get_nodes_in_group("boss"):
		if is_instance_valid(b) and not b.is_dead:
			total += b.health
	health_bar.value = total
	hp_label.text = "HP: %d / %d" % [player.health, player.max_health]

# "signal" — PauseButton(Button).pressed -> _on_pause_button_pressed()
func _on_pause_button_pressed() -> void:
	get_tree().paused = true
	pause_menu.visible = true
