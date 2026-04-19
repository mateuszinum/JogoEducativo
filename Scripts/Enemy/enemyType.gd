@tool
extends Resource
class_name Enemy

enum Comportamento { PADRAO, FANTASMA }

@export_group("Infos básicas")
@export var nome : String
@export var animations : SpriteFrames 
@export var tabela_de_drops: Array[DropData] = []

@export var comportamento_especial: Comportamento = Comportamento.PADRAO:
	set(value):
		comportamento_especial = value
		notify_property_list_changed()

@export_group("Configurações do Fantasma")
@export var fantasma_tempo_solido: float = 5.0
@export var fantasma_tempo_translucido: float = 5.0
@export var fantasma_alpha_solido: float = 1.0
@export var fantasma_alpha_translucido: float = 0.3

@export_group("Atributos")
@export var health : float = 3
@export var damage : float = 10
@export var speed : float = 10.0
@export var despawns : bool = true

@export_group("Fraquezas e Resistências")
@export var multiplicadores_de_ataque: Array[WeaknessData] = []

func _validate_property(property: Dictionary) -> void:
	if property.name.begins_with("fantasma_"):
		if comportamento_especial != Comportamento.FANTASMA:
			property.usage = PROPERTY_USAGE_NO_EDITOR
