extends Control
class_name MainMenu

const MAPS := [
	{"name": "The Courtyard", "path": "res://scenes/maps/map_01.tscn"},
	# add one entry here per map you build — name shown on the button,
	# path pointing at that map's .tscn (see Section 6)
]

func _ready() -> void:
	var list := $VBox/MapList
	for map_data in MAPS:
		var button := Button.new()
		button.text = map_data["name"]
		# Buttons created in code have no home in any scene file, so their
		# signal can't be wired through the editor — same reasoning as the
		# autoload/Timer exceptions in Section 4 of the first guide.
		button.pressed.connect(_on_map_selected.bind(map_data["path"]))
		list.add_child(button)

func _on_map_selected(path: String) -> void:
	GameManager.selected_map_path = path
	GameManager.start_new_run()
