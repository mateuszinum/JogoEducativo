extends Node

@export var lista_de_recursos: Array[ItemData] = []

func get_recurso(nome_procurado: String) -> ItemData:
	var nome_limpo = nome_procurado.to_lower().strip_edges()
	
	for item in lista_de_recursos:
		if item != null and item.nome.to_lower().strip_edges() == nome_limpo:
			return item
			
	return null
