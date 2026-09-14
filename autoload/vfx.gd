extends Node

const HIT_SPARK := preload("res://scenes/vfx/vfx_hit_spark.tscn")
const DEATH_POOF := preload("res://scenes/vfx/vfx_death_poof.tscn")
const POSSESSION_SWIRL := preload("res://scenes/vfx/vfx_possession_swirl.tscn")
const SABOTAGE_BURST := preload("res://scenes/vfx/vfx_sabotage_burst.tscn")

func spawn(scene: PackedScene, pos: Vector2) -> void:
	var fx := scene.instantiate()
	Engine.get_main_loop().current_scene.add_child(fx)
	fx.global_position = pos
