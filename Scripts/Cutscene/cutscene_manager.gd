extends Node

func tocar_cutscene(nome_cutscene: String) -> void:
	var recurso = CutscenesDB.get_cutscene(nome_cutscene)
	
	if recurso == null:
		return
		
	var jogo = get_tree().get_first_node_in_group("Jogo")
	if jogo and jogo.has_method("tocar_cutscene"):
		jogo.tocar_cutscene(recurso)
