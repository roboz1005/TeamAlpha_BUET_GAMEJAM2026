extends CharacterBody2D
class_name Enemy

@export var aggro_radius: float = 120.0
@export var speed: float = 70.0

var health: int = 2

func _ready() -> void:
	call_deferred("add_to_group", "enemies")

func _physics_process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if player and global_position.distance_to(player.global_position) < aggro_radius:
		velocity = (player.global_position - global_position).normalized() * speed
		move_and_slide()

# "signal" — select the HurtboxArea CHILD node, Node dock > Signals >
# body_entered, and in the Connect dialog pick the Enemy (root) node as the
# target — not HurtboxArea itself — so the connection lands on this function.
func _on_body_entered(body: Node) -> void:
	if body is Player:
		body.take_hit(1)
	elif body is Doppelganger:
		body.take_hit(1, false)

func take_hit(amount: int) -> void:
	health -= amount
	if health <= 0:
		Events.enemy_killed.emit(self)
		GameManager.add_xp(1)
		VFX.spawn(VFX.DEATH_POOF, global_position)
		_drop_loot()
		queue_free()

func _drop_loot() -> void:
	if randf() < 0.5:
		var drop := preload("res://scenes/entities/drop.tscn").instantiate()
		var roll := randf()
		if roll < 0.6:
			drop.kind = "coin"
		elif roll < 0.85:
			drop.kind = "health"
		else:
			var temp_kinds := ["temp_firerate", "temp_speed", "temp_defense"]
			drop.kind = temp_kinds[randi() % temp_kinds.size()]
		get_tree().current_scene.add_child(drop)
		drop.global_position = global_position
