extends CanvasLayer
class_name HUD

@onready var health_label: Label = $Margin/VBox/HealthLabel
@onready var round_label: Label = $Margin/VBox/RoundLabel
@onready var doppel_label: Label = $Margin/VBox/DoppelLabel
@onready var currency_label: Label = $Margin/VBox/CurrencyLabel

# NOTE: all three connections below MUST be code, not the editor — see
# Section 4. GameManager and Events are autoloads with no home in this
# scene's node tree, and Player is found dynamically by group rather than a
# fixed slot, so none of them can be picked through the Node dock here.
func _ready() -> void:
	GameManager.round_started.connect(_on_round_started)
	Events.skill_unlocked.connect(_on_skill_unlocked)
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.health_changed.connect(_on_health_changed)
		_on_health_changed(player.health, 3)

func _on_round_started(round_number: int, doppelganger_count: int) -> void:
	round_label.text = "Round %d" % round_number
	doppel_label.text = "Doppelgangers: %d" % doppelganger_count

func _on_health_changed(current: int, max_health: int) -> void:
	health_label.text = "HP: %d / %d" % [current, max_health]

func _on_skill_unlocked(skill_name: String) -> void:
	round_label.text = "Round %d  (unlocked: %s)" % [GameManager.current_round, skill_name]
	await get_tree().create_timer(1.5).timeout
	round_label.text = "Round %d" % GameManager.current_round

func _process(_delta: float) -> void:
	currency_label.text = "Coins: %d" % GameManager.player_currency
