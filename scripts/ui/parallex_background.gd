extends Node2D
class_name ParallaxSceneBackground

@export var layers: Array[Texture2D] = []
@export var back_layer_scroll_scale: float = 0.1
@export var front_layer_scroll_scale: float = 0.6
@export var repeat_times: int = 3
@export var sprite_centered: bool = false

func _ready() -> void:
	for i in layers.size():
		var texture: Texture2D = layers[i]
		if texture == null:
			continue

		var depth: float = 0.0 if layers.size() <= 1 else float(i) / float(layers.size() - 1)
		var scroll_scale: float = lerp(back_layer_scroll_scale, front_layer_scroll_scale, depth)

		var parallax := Parallax2D.new()
		parallax.scroll_scale = Vector2(scroll_scale, scroll_scale)
		parallax.repeat_size = Vector2(texture.get_width(), 0)
		parallax.repeat_times = repeat_times

		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.centered = sprite_centered
		

		parallax.add_child(sprite)
		add_child(parallax)
