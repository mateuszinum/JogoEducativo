extends Resource
class_name ItemData

# Isso é a "ficha de cadastro" de qualquer item do jogo
@export var nome: String = "Novo Item"
@export var icone: Texture2D
@export var tipo_do_item: String = "material" # Pode ser "arma", "cura", etc.
@export var valor: int = 1
