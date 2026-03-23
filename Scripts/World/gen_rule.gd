class_name GenRule extends Resource

@export var nome_obstaculo: String = "Novo Obstaculo"

@export_category("Tiles (Variações)")
@export var source_id: int = 0
@export var atlas_coords: Array[Vector2i]

@export_category("Configuração do Ruído")
@export var ruido: NoiseTexture2D 
@export var valor_minimo: float = 0.5
@export var valor_maximo: float = 1.0
