extends Resource
class_name StageData

@export var stage_name : String
@export var spawn_events : Array[SpawnEvent] = []

@export_group("Audio")
@export var stage_music : AudioStream
@export var music_volume : float = 0.0

@export_group("Geração de Mapa")
@export var map_width: int = 100
@export var map_height: int = 100

@export_group("Tiles do Mapa")
@export var source_id_chao: int = 1
@export var chao_atlas: Vector2i = Vector2i(0, 0)

@export var obstaculos_source_ids: Array[int] = []
@export var obstaculos_atlas: Array[Vector2i] = []
