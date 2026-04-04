extends Resource
class_name Enemy

@export_group("Infos básicas")
@export var nome : String
@export var animations : SpriteFrames 
@export var tabela_de_drops: Array[DropData] = []

@export_group("Atributos")
@export var health : float = 3
@export var damage : float = 10
@export var speed : float = 10.0
@export var despawns : bool = true

@export_group("Fraquezas e Resistências")
@export var multiplicadores_de_ataque: Array[WeaknessData] = []
