extends Resource
class_name StageData

@export var stage_name : String
@export var spawn_events : Array[SpawnEvent] = []

@export_group("Audio")
@export var stage_music : AudioStream
@export var music_volume : float = 0.0
