extends Node2D
class_name EarthBonusRust

@onready var boss_intro: BossIntro = $BossIntro
@onready var boss_hud: BossHUD = $BossHUD
@onready var death_screen: DeathScreen = $DeathScreen

func _ready() -> void:
	GameManager.set_earth_timer_active(false)
	death_screen.visible = false
	boss_intro.visible = true
	get_tree().paused = true

func show_death_screen() -> void:
	boss_hud.visible = false
	death_screen.visible = true
	get_tree().paused = true
