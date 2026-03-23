class_name StageData extends Resource

@export var stage_name : String

@export_group("Trilha Sonora")
@export var stage_music : AudioStream
@export var music_volume : float = 0.0

@export_group("Spawn de Inimigos")
@export var spawn_events : Array[SpawnEvent] = []

@export_group("Outras configurações")
@export var map_width: int = 50
@export var map_height: int = 50
@export var raio_seguro_spawn: float = 5.0

@export_category("Tiles")
@export var stage_tileset: TileSet
@export_group("Chão")
@export var ground_source_ids: Array[int]

@export_group("Barreiras")
@export var spawn_rules: Array[GenRule] = []
