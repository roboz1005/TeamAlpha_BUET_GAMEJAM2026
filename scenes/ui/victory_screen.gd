extends Control
class_name VictoryScreen

@onready var stats_label: Label = $VBox/StatsLabel

func _ready() -> void:
	stats_label.text = "Rounds cleared: %d\nCoins collected: %d" % [GameManager.current_round, GameManager.player_currency]

# "signal" — connect ReplayButton's own "pressed" signal to this function.
func _on_replay_button_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/ui/main_menu.tscn")
