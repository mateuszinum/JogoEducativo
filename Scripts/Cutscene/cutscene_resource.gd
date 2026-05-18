extends Resource
class_name CutsceneResource

@export var nome: String = ""

@export_group("Trilha Sonora")
@export var musica_tema: AudioStream
@export var volume_musica_db: float = 0.0
@export var usar_fade_in_audio: bool = true

@export_group("Configurações Iniciais")
@export var delay_inicial: float = 1.0
@export var tempo_fade_inicial: float = 1.0
@export var tempo_auto_avanco: float = 4.0

@export_group("Páginas")
@export var paginas: Array[CutscenePage] = []
