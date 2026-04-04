extends Node

# Lista que vai aparecer no Inspector para você arrastar os arquivos Enemy (.tres)
@export var lista_de_inimigos: Array[Enemy] = []

func get_inimigo(nome_procurado: String) -> Enemy:
	var nome_limpo = nome_procurado.to_lower().strip_edges()
	
	for inimigo in lista_de_inimigos:
		if inimigo != null and inimigo.nome.to_lower().strip_edges() == nome_limpo:
			return inimigo
			
	return null
