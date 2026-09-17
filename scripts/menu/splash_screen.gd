extends Control
class_name SplashScreen

@export var next_scene_path: String = "res://scenes/menu/main_menu.tscn"
@export var minimum_display_time: float = 4.0

var elapsed_time: float = 0.0
var resource_ready: bool = false

@onready var loading_bar: ProgressBar = $LoadingBar

func _ready() -> void:
	MusicController.bgm_play()
	loading_bar.min_value = 0.0
	loading_bar.max_value = 1.0
	loading_bar.value = 0.0
	var err: Error = ResourceLoader.load_threaded_request(next_scene_path)
	if err != OK:
		push_error("SplashScreen: could not start loading '%s' (error %d)" % [next_scene_path, err])
		set_process(false)

func _process(delta: float) -> void:
	elapsed_time += delta

	var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(next_scene_path)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		resource_ready = true
	elif status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		push_error("SplashScreen: failed to load '%s'" % next_scene_path)
		set_process(false)
		return

	# The bar's fill is just "how much of the minimum display time has
	# passed" — smooth and predictable no matter how fast the real load
	# finishes. We only leave once BOTH that time is up AND the resource
	# has actually finished loading in the background.
	loading_bar.value = clamp(elapsed_time / minimum_display_time, 0.0, 1.0)

	if resource_ready and elapsed_time >= minimum_display_time:
		_finish_loading()

func _finish_loading() -> void:
	set_process(false)
	var packed: PackedScene = ResourceLoader.load_threaded_get(next_scene_path)
	get_tree().change_scene_to_packed(packed)
