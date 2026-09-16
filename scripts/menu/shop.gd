extends Control
class_name Shop

@onready var coins_label: Label = $CoinsLabel
@onready var bullet_list: VBoxContainer = $BulletList
@onready var back_button: Button = $BackButton

func _ready() -> void:
	_refresh()

func _refresh() -> void:
	for child in bullet_list.get_children():
		child.queue_free()
	coins_label.text = "Coins: %d" % GameManager.coins
	for bullet_id in GameManager.BULLET_CATALOG.keys():
		_add_bullet_row(bullet_id)

func _add_bullet_row(bullet_id: String) -> void:
	var info: Dictionary = GameManager.BULLET_CATALOG[bullet_id]
	var row := HBoxContainer.new()

	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(48, 48)
	var bullet_scene: PackedScene = load(info["scene"])
	var preview: Node = bullet_scene.instantiate()
	if preview.has_node("AnimatedSprite2D"):
		var sprite: AnimatedSprite2D = preview.get_node("AnimatedSprite2D")
		icon.texture = sprite.sprite_frames.get_frame_texture(sprite.animation, 0)
	elif preview.has_node("Sprite2D"):
		icon.texture = preview.get_node("Sprite2D").texture
	preview.queue_free()
	row.add_child(icon)

	var name_label := Label.new()
	name_label.text = info["name"]
	row.add_child(name_label)

	var action_button := Button.new()
	if GameManager.unlocked_bullets.has(bullet_id):
		action_button.text = "Equipped" if GameManager.equipped_bullet == bullet_id else "Equip"
		action_button.disabled = GameManager.equipped_bullet == bullet_id
	else:
		action_button.text = "Buy (%d coins)" % info["cost"]
		action_button.disabled = GameManager.coins < info["cost"]
	# These rows (icon/label/button) are built entirely in code, one per
	# catalog entry, so — same exception as the puzzle tiles in Part 2 —
	# there's no node in the editor to hand-wire this signal on.
	action_button.pressed.connect(_on_bullet_button_pressed.bind(bullet_id))
	row.add_child(action_button)

	bullet_list.add_child(row)

func _on_bullet_button_pressed(bullet_id: String) -> void:
	if GameManager.unlocked_bullets.has(bullet_id):
		GameManager.equip_bullet(bullet_id)
	else:
		GameManager.unlock_bullet(bullet_id)
	_refresh()

# "signal" — BackButton(Button).pressed -> _on_back_button_pressed()
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(GameManager.MAIN_MENU_SCENE)
