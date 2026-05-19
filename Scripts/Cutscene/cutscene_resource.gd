extends Resource
class_name CutsceneResource

@export var nome: String = ""

@export_group("Configurações")
@export var usar_fade_in_audio: bool = true
@export var delay_inicial: float = 1.0
@export var tempo_fade_inicial: float = 1.0
@export var tempo_auto_avanco: float = 4.0

@export_group("Páginas")
@export var paginas: Array[CutscenePage] = []
