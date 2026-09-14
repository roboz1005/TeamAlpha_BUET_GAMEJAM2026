extends Node2D

var _radius: float = 4.0
var _alpha: float = 1.0

func _ready() -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "_radius", 22.0, 0.35)
	tween.tween_property(self, "_alpha", 0.0, 0.35)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, _radius, Color(0.6, 0.6, 0.6, _alpha))
	draw_arc(Vector2.ZERO, _radius * 0.6, 0, TAU, 16, Color(0.9, 0.9, 0.9, _alpha), 2.0)
