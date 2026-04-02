extends Node

# Agora é uma Lista simples de arquivos StageData!
@export var lista_de_arenas: Array[StageData] = []

func get_stage_data(nome_procurado: String) -> Resource:
	var nome_limpo = nome_procurado.to_lower().strip_edges()
	
	for arena in lista_de_arenas:
		# Verifica se o arquivo não é nulo e lê a variável 'stage_name' direto de dentro dele
		if arena != null and arena.stage_name.to_lower().strip_edges() == nome_limpo:
			return arena
			
	return null # Não achou nenhuma arena com esse nome
