extends Node2D

@export var data : StageData

func _ready() -> void:
	play_stage_music()

func play_stage_music():
	if data != null and data.stage_music != null:
		var music_player = AudioStreamPlayer.new()
		music_player.stream = data.stage_music
		music_player.volume_db = data.music_volume
		music_player.name = "StageMusicPlayer"
		add_child(music_player)
		music_player.play()
