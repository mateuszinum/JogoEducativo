@tool
class_name GenRule extends Resource

var eh_barreira: bool = true

@export var nome_obstaculo: String = "Barreira"

@export var usa_autotile: bool = false:
	set(value):
		usa_autotile = value
		notify_property_list_changed()

@export var terrain_set: int = 0
@export var terrain_id: int = 0

@export var source_ids: Array[int]

@export_category("Configuração de Spawn")
@export_range(0.0, 1.0) var frequencia: float = 0.1

## Define a distância MÍNIMA (em blocos) entre o núcleo de um cluster e outro.
## Impede que grupos de árvores ou pedras nasçam grudados.
@export var distancia_minima_clusters: int = 10

## Define o tamanho EXATO do cluster (em blocos). Sorteia um número inteiro entre o Min e Max.
@export var cluster_min: int = 1
@export var cluster_max: int = 5

## Se ativado, o cluster cresce em formato de bola/círculo denso.
## Se desativado, o cluster cresce como uma "cobra" ou "ameba" (orgânico), mas SEMPRE 100% conectado.
@export var cluster_redondo: bool = true

@export var afastar_obstaculos: Array[String] = []


func _validate_property(property: Dictionary):
	if usa_autotile:
		if property.name == "source_ids":
			property.usage = PROPERTY_USAGE_NO_EDITOR
			
	else:
		if property.name in ["terrain_set", "terrain_id"]:
			property.usage = PROPERTY_USAGE_NO_EDITOR
