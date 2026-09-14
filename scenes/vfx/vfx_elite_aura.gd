extends Node2D

var _t: float = 0.0

func _process(delta: float) -> void:
	_t += delta
	queue_redraw()

func _draw() -> void:
	var pulse := 18.0 + sin(_t * 3.0) * 4.0
	draw_arc(Vector2.ZERO, pulse, 0, TAU, 24, Color(1.0, 0.85, 0.2, 0.5), 3.0)
