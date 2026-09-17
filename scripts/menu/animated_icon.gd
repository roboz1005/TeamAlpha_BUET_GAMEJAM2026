extends TextureRect
class_name AnimatedIcon

var sprite_frames: SpriteFrames
var animation_name: StringName = &"default"
var frame_index: int = 0
var frame_timer: float = 0.0

func setup(frames: SpriteFrames, anim: StringName) -> void:
	sprite_frames = frames
	animation_name = anim
	frame_index = 0
	frame_timer = 0.0
	if sprite_frames and sprite_frames.has_animation(animation_name):
		texture = sprite_frames.get_frame_texture(animation_name, 0)

func _process(delta: float) -> void:
	if not sprite_frames or not sprite_frames.has_animation(animation_name):
		return
	var frame_count: int = sprite_frames.get_frame_count(animation_name)
	if frame_count <= 1:
		return
	var fps: float = sprite_frames.get_animation_speed(animation_name)
	if fps <= 0.0:
		return
	frame_timer += delta
	var frame_duration: float = 1.0 / fps
	while frame_timer >= frame_duration:
		frame_timer -= frame_duration
		frame_index = (frame_index + 1) % frame_count
		texture = sprite_frames.get_frame_texture(animation_name, frame_index)
