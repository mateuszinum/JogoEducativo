extends Node

signal progresso_alterado 
signal progresso_inicio_alterado

var produtos_desbloqueados: Dictionary = {}

func desbloquear(nome_produto: String, nivel: int = 1) -> void:
	var limpo = nome_produto.to_lower().strip_edges()
	produtos_desbloqueados[limpo] = nivel
	progresso_alterado.emit() 
	if limpo == "início":
		progresso_inicio_alterado.emit()
		
	if Constantes.DEBUG: print(produtos_desbloqueados)
	SaveMaster.salvar_dado()

	checar_skill_tree_completa()

func passou_do_tutorial() -> bool:
	if Constantes.PULAR_TUTORIAL: 
		return true 
	return tem_desbloqueado("Tutorial", true)

func tem_desbloqueado(nome_produto: String, burlar_constante: bool = false) -> bool:
	if Constantes.TUDO_DESBLOQUEADO and !burlar_constante: 
		return true 
		
	if nome_produto == "": return true 
	var limpo = nome_produto.to_lower().strip_edges()
	return produtos_desbloqueados.has(limpo) and produtos_desbloqueados[limpo] > 0

func get_nivel(nome_produto: String) -> int:
	var limpo = nome_produto.to_lower().strip_edges()
	if produtos_desbloqueados.has(limpo):
		return produtos_desbloqueados[limpo]
	return 0

func checar_skill_tree_completa() -> void:
	var contagem_arvore = 0

	var ignorar = ["tutorial", "início", "magovelho", "localização", "itens"]
	
	for produto in produtos_desbloqueados.keys():
		if not produto in ignorar:
			contagem_arvore += 1
			
	if contagem_arvore >= Constantes.TOTAL_ITENS_SKILL_TREE:
		if has_node("/root/AchievementsManager"):
			AchievementsManager.unlock_achievement("COMPLETE_SKILL_TREE")
