extends Node2D

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var coin: AudioStreamPlayer = $Coin
@onready var bullet: AudioStreamPlayer = $Bullet
@onready var power_up: AudioStreamPlayer = $PowerUP
@onready var jump: AudioStreamPlayer = $Jump
@onready var slide: AudioStreamPlayer = $Slide
@onready var click: AudioStreamPlayer = $Click
@onready var pickup: AudioStreamPlayer = $pickup
@onready var hurt: AudioStreamPlayer = $Hurt
@onready var reject: AudioStreamPlayer = $Reject
@onready var purchase: AudioStreamPlayer = $Purchase
@onready var fall: AudioStreamPlayer = $Fall


func bgm_play():
	audio_stream_player.stream = preload("res://assets/brackeys_platformer_assets/music/Grasslands_Theme.mp3")
	audio_stream_player.play()

func coin_music_play():
	coin.stream = preload("res://assets/brackeys_platformer_assets/sounds/coin.wav")
	coin.play()

func bullet_music_play():
	bullet.stream = preload("res://assets/brackeys_platformer_assets/sounds/hew-01.wav")
	bullet.play()

func pickup_music_play():
	power_up.stream = preload("res://assets/brackeys_platformer_assets/sounds/power_up.wav")
	power_up.play()

func jump_music_play():
	jump.stream = preload("res://assets/brackeys_platformer_assets/sounds/jump.mp3")
	jump.play()

func slide_music_play():
	slide.stream = preload("res://assets/brackeys_platformer_assets/sounds/slidepop.mp3")
	slide.play()

func click_music_play():
	click.stream = preload("res://assets/brackeys_platformer_assets/sounds/click.wav")
	click.play()

func pickup_material_music_play():
	pickup.stream = preload("res://assets/brackeys_platformer_assets/sounds/material_pickup.wav")
	pickup.play()
	
func hurt_music_play():
	hurt.stream = preload("res://assets/brackeys_platformer_assets/sounds/hurt.wav")
	hurt.play()

func reject_music_play():
	reject.stream = preload("res://assets/brackeys_platformer_assets/sounds/reject.ogg")
	reject.play()

func purchase_music_play():
	purchase.stream = preload("res://assets/brackeys_platformer_assets/sounds/purchase.ogg")
	purchase.play()

func fall_music_play():
	fall.stream = preload("res://assets/brackeys_platformer_assets/sounds/fall.ogg")
	fall.play()
