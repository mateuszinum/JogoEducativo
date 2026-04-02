class_name GenRule extends Resource

@export var nome_obstaculo: String = "Novo Obstaculo"

@export_category("Tiles")
@export var source_ids: Array[int] 

@export_category("Configuração do Ruído")
@export var ruido: NoiseTexture2D 
@export var valor_minimo: float = 0.5
@export var valor_maximo: float = 1.0
