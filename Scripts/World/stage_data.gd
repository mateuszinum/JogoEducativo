class_name StageData extends Resource

@export var stage_name : String
@export var spawn_events : Array[SpawnEvent] = []

@export_group("Audio")
@export var stage_music : AudioStream
@export var music_volume : float = 0.0

@export_category("Tamanho")
@export var map_width: int = 50
@export var map_height: int = 50

@export_category("Chão Padrão")
@export var source_id_chao_padrao: int = 0
@export var chao_padrao_atlas: Vector2i = Vector2i(0, 0)

@export_category("Regras do Mapa")
@export var regras_de_geracao: Array[GenRule]

@export_category("Configurações de Spawn")
@export var raio_seguro_spawn: float = 5.0
