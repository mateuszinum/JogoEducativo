class_name GenRule extends Resource

@export var nome_regra: String 
@export var layer_destino: int = 0

@export_category("Geração de Objetos")
@export var gerar_como_objeto: bool = false
@export var objetos_dados: Array[ObjetoMapaData]

@export_category("Configuração do Ruído")
@export var ruido: NoiseTexture2D 
@export var valor_minimo: float = -1.0
@export var valor_maximo: float = 1.0

@export_category("Dependências")
@export var exige_chao_livre: bool = false 
@export var evitar_area_segura: bool = false

@export_category("Tiles")
@export var source_ids: Array[int]
@export var atlas_coords: Array[Vector2i]
