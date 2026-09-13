extends Area2D
class_name Drop

@export var kind: String = "coin"   # "coin" | "health" | "temp_firerate" | "temp_speed" | "temp_defense"

func _ready() -> void:
	add_to_group("drops")

# "signal" — connect this Drop's own body_entered to this function.
func _on_body_entered(body: Node) -> void:
	if body is Player or body is Doppelganger:
		collect(body)

func collect(who: Node) -> void:
	match kind:
		"coin":
			if who is Player:
				GameManager.player_currency += 1
			# a doppelganger picking up a coin just denies it to the player
		"health":
			if who.has_method("heal"):
				who.heal(1)
		"temp_firerate", "temp_speed", "temp_defense":
			# Temp skills are player-only — a doppelganger walking over one
			# just consumes it, same as a coin.
			if who is Player:
				who.apply_temp_skill(kind)
	queue_free()
