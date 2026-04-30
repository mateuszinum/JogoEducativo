class_name GenRule extends Resource

var eh_barreira: bool = true

@export var nome_obstaculo: String = "Barreira"
@export var source_ids: Array[int]

@export_category("Configuração")
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
