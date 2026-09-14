extends Node2D

var _angle: float = 0.0
var _life: float = 0.6
var _alpha: float = 1.0

func _process(delta: float) -> void:
	_angle += delta * 10.0
	_life -= delta
	_alpha = clamp(_life / 0.6, 0.0, 1.0)
	if _life <= 0.0:
		queue_free()
		return
	queue_redraw()

func _draw() -> void:
	for i in 3:
		var a := _angle + i * (TAU / 3.0)
		var p := Vector2(cos(a), sin(a)) * 18.0
		draw_circle(p, 5.0, Color(0.4, 0.7, 1.0, _alpha))
