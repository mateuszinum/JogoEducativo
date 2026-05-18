extends Node

@export var lista_de_cutscenes: Array[CutsceneResource] = []

func get_cutscene(nome_procurado: String) -> CutsceneResource:
	var nome_limpo = nome_procurado.to_lower().strip_edges()
	
	for cutscene in lista_de_cutscenes:
		if cutscene != null and cutscene.nome.to_lower().strip_edges() == nome_limpo:
			return cutscene
			
	if Constantes.DEBUG: print("A cutscene ", nome_procurado, " não foi encontrada no CutscenesDB")
	return null

func existe_cutscene(nome_procurado: String) -> bool:
	return get_cutscene(nome_procurado) != null
