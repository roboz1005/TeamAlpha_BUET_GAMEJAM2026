extends Control
class_name RocketPuzzle

@export var rocket_images: Array[Texture2D] = []
@export var grid_size: int = 4
@export var piece_display_size: int = 128
@export var preview_duration: float = 30.0

var rocket_image: Texture2D
var total_tiles: int = 0
var blank_id: int = 0
var blank_slot: int = 0
var solved: bool = false
var puzzle_started: bool = false
var slot_buttons: Array[TextureButton] = []
var slot_piece_id: Array[int] = []
var piece_atlases: Array[AtlasTexture] = []

@onready var preview_layer: Control = $PreviewLayer
@onready var preview_image: TextureRect = $PreviewLayer/PreviewImage
@onready var preview_countdown_label: Label = $PreviewLayer/PreviewCountdownLabel
@onready var preview_timer: Timer = $PreviewTimer
@onready var puzzle_layer: Control = $PuzzleLayer
@onready var grid: GridContainer = $PuzzleLayer/PuzzleGrid
@onready var win_label: Label = $PuzzleLayer/WinLabel
@onready var win_timer: Timer = $WinTimer

func _ready() -> void:
	GameManager.set_earth_timer_active(true)
	win_label.visible = false
	puzzle_layer.visible = false
	preview_layer.visible = true

	if rocket_images.is_empty():
		push_error("RocketPuzzle: 'Rocket Images' is empty in the Inspector!")
		return

	rocket_image = rocket_images[randi() % rocket_images.size()]
	preview_image.texture = rocket_image
	grid.columns = grid_size
	total_tiles = grid_size * grid_size
	blank_id = total_tiles - 1

	_build_slots()
	_shuffle()
	_refresh_all_slots()
	preview_timer.start(preview_duration)

func _exit_tree() -> void:
	GameManager.set_earth_timer_active(false)

func _process(_delta: float) -> void:
	if preview_layer.visible:
		preview_countdown_label.text = "Starts in %d s" % int(ceil(preview_timer.time_left))

func _build_slots() -> void:
	var piece_w: int = rocket_image.get_width() / grid_size
	var piece_h: int = rocket_image.get_height() / grid_size

	for i in total_tiles:
		var col: int = i % grid_size
		var row: int = i / grid_size

		if i < blank_id:
			var atlas := AtlasTexture.new()
			atlas.atlas = rocket_image
			atlas.region = Rect2(col * piece_w, row * piece_h, piece_w, piece_h)
			piece_atlases.append(atlas)
		else:
			piece_atlases.append(null)

		var button := TextureButton.new()
		button.custom_minimum_size = Vector2(piece_display_size, piece_display_size)
		button.ignore_texture_size = true
		button.stretch_mode = TextureButton.STRETCH_SCALE

		# Each button stays at a FIXED grid position for its whole life — only
		# the texture it shows ever changes. Nodes are never reordered, which
		# removes any chance of the visual grid drifting out of sync with the
		# logical board.
		button.pressed.connect(_on_slot_pressed.bind(i))

		slot_buttons.append(button)
		grid.add_child(button)
		slot_piece_id.append(i)

	blank_slot = blank_id

func _refresh_all_slots() -> void:
	for i in slot_buttons.size():
		_refresh_slot(i)

func _refresh_slot(slot: int) -> void:
	var piece_id: int = slot_piece_id[slot]
	var button: TextureButton = slot_buttons[slot]
	if piece_id == blank_id:
		button.texture_normal = null
		button.disabled = true
		button.modulate = Color(0, 0, 0, 0)
	else:
		button.texture_normal = piece_atlases[piece_id]
		button.disabled = false
		button.modulate = Color(1, 1, 1, 1)

func _get_neighbors(slot: int) -> Array[int]:
	var neighbors: Array[int] = []
	var col: int = slot % grid_size
	var row: int = slot / grid_size
	if col > 0:
		neighbors.append(slot - 1)
	if col < grid_size - 1:
		neighbors.append(slot + 1)
	if row > 0:
		neighbors.append(slot - grid_size)
	if row < grid_size - 1:
		neighbors.append(slot + grid_size)
	return neighbors

func _swap_slots(slot_a: int, slot_b: int) -> void:
	var tmp: int = slot_piece_id[slot_a]
	slot_piece_id[slot_a] = slot_piece_id[slot_b]
	slot_piece_id[slot_b] = tmp
	if slot_piece_id[slot_a] == blank_id:
		blank_slot = slot_a
	elif slot_piece_id[slot_b] == blank_id:
		blank_slot = slot_b
	_refresh_slot(slot_a)
	_refresh_slot(slot_b)

func _shuffle() -> void:
	randomize()
	for i in 200:
		var neighbors: Array[int] = _get_neighbors(blank_slot)
		var pick: int = neighbors[randi() % neighbors.size()]
		_swap_slots(pick, blank_slot)

func _on_slot_pressed(slot: int) -> void:
	if solved or not puzzle_started:
		return
	if slot in _get_neighbors(blank_slot):
		_swap_slots(slot, blank_slot)
		_check_solved()

func _check_solved() -> void:
	for i in slot_piece_id.size():
		if slot_piece_id[i] != i:
			return
	solved = true
	win_label.visible = true
	win_timer.start()

# "signal" — PlayButton(Button).pressed -> _on_play_button_pressed()
func _on_play_button_pressed() -> void:
	_start_puzzle()

# "signal" — PreviewTimer(Timer).timeout -> _on_preview_timer_timeout()
func _on_preview_timer_timeout() -> void:
	_start_puzzle()

func _start_puzzle() -> void:
	if puzzle_started:
		return
	puzzle_started = true
	preview_timer.stop()
	preview_layer.visible = false
	puzzle_layer.visible = true

# "signal" — WinTimer(Timer).timeout -> _on_win_timer_timeout()
func _on_win_timer_timeout() -> void:
	GameManager.complete_earth_map()
