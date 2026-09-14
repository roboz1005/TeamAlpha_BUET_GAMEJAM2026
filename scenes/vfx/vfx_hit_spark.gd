extends Node2D

var _radius: float = 2.0
var _alpha: float = 1.0

func _ready() -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "_radius", 14.0, 0.25)
	tween.tween_property(self, "_alpha", 0.0, 0.25)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, _radius, Color(1, 0.9, 0.3, _alpha))
