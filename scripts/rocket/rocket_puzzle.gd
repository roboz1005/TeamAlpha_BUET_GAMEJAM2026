extends Control
class_name RocketPuzzle

@export var rocket_image: Texture2D
@export var grid_size: int = 4
@export var piece_display_size: int = 128

var pieces: Array[TextureButton] = []
var tile_order: Array[int] = []
var blank_index: int = 0
var solved: bool = false

@onready var grid: GridContainer = $PuzzleGrid
@onready var preview: TextureRect = $PreviewTextureRect
@onready var win_label: Label = $WinLabel
@onready var win_timer: Timer = $WinTimer

func _ready() -> void:
	win_label.visible = false

	if rocket_image == null:
		push_error("RocketPuzzle: 'Rocket Image' is not assigned in the Inspector!")
		return

	preview.texture = rocket_image
	grid.columns = grid_size
	_build_pieces()
	_shuffle()
	_render()

func _build_pieces() -> void:
	var total: int = grid_size * grid_size
	var piece_w: int = rocket_image.get_width() / grid_size
	var piece_h: int = rocket_image.get_height() / grid_size

	for i in total:
		var col: int = i % grid_size
		var row: int = i / grid_size
		var button := TextureButton.new()
		button.custom_minimum_size = Vector2(piece_display_size, piece_display_size)
		button.ignore_texture_size = true
		button.stretch_mode = TextureButton.STRETCH_SCALE

		if i < total - 1:
			var atlas := AtlasTexture.new()
			atlas.atlas = rocket_image
			atlas.region = Rect2(col * piece_w, row * piece_h, piece_w, piece_h)
			button.texture_normal = atlas
		else:
			button.disabled = true
			button.modulate = Color(0, 0, 0, 0)

		# This button exists only at runtime — there is no node in the editor
		# to hand-wire a signal on, so this is the one necessary .connect().
		button.pressed.connect(_on_piece_pressed.bind(i))

		pieces.append(button)
		grid.add_child(button)
		tile_order.append(i)

	blank_index = total - 1

func _get_neighbors(index: int) -> Array[int]:
	var neighbors: Array[int] = []
	var col: int = index % grid_size
	var row: int = index / grid_size
	if col > 0:
		neighbors.append(index - 1)
	if col < grid_size - 1:
		neighbors.append(index + 1)
	if row > 0:
		neighbors.append(index - grid_size)
	if row < grid_size - 1:
		neighbors.append(index + grid_size)
	return neighbors

func _swap(slot_a: int, slot_b: int) -> void:
	var tmp: int = tile_order[slot_a]
	tile_order[slot_a] = tile_order[slot_b]
	tile_order[slot_b] = tmp
	if tile_order[slot_a] == pieces.size() - 1:
		blank_index = slot_a
	elif tile_order[slot_b] == pieces.size() - 1:
		blank_index = slot_b

func _shuffle() -> void:
	randomize()
	for i in 200:
		var neighbors: Array[int] = _get_neighbors(blank_index)
		var pick: int = neighbors[randi() % neighbors.size()]
		_swap(pick, blank_index)

func _render() -> void:
	for slot in tile_order.size():
		var piece_id: int = tile_order[slot]
		grid.move_child(pieces[piece_id], slot)

func _on_piece_pressed(piece_id: int) -> void:
	if solved:
		return
	var slot: int = tile_order.find(piece_id)
	if slot in _get_neighbors(blank_index):
		_swap(slot, blank_index)
		_render()
		_check_solved()

func _check_solved() -> void:
	for i in tile_order.size():
		if tile_order[i] != i:
			return
	solved = true
	win_label.visible = true
	win_timer.start()

# "signal" — WinTimer(Timer).timeout -> _on_win_timer_timeout()
func _on_win_timer_timeout() -> void:
	GameManager.complete_earth_map()
