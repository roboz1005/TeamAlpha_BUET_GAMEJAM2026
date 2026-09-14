extends Node2D

var _radius: float = 4.0
var _alpha: float = 1.0

func _ready() -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "_radius", 40.0, 0.3)
	tween.tween_property(self, "_alpha", 0.0, 0.3)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_arc(Vector2.ZERO, _radius, 0, TAU, 24, Color(1, 0.2, 0.2, _alpha), 4.0)
