extends Node

# Lista que vai aparecer no Inspector para você arrastar os arquivos Weapon (.tres)
@export var lista_de_ataques: Array[Weapon] = []

func get_ataque(nome_procurado: String) -> Weapon:
	var nome_limpo = nome_procurado.to_lower().strip_edges()
	
	for ataque in lista_de_ataques:
		if ataque != null and ataque.nome.to_lower().strip_edges() == nome_limpo:
			return ataque
			
	return null
