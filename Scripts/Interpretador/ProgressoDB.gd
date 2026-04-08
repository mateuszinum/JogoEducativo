extends Node

signal progresso_alterado 

var produtos_desbloqueados: Dictionary = {}

func desbloquear(nome_produto: String, nivel: int = 1) -> void:
	var limpo = nome_produto.to_lower().strip_edges()
	produtos_desbloqueados[limpo] = nivel
	progresso_alterado.emit() 

func tem_desbloqueado(nome_produto: String) -> bool:
	if Constantes.TUDO_DESBLOQUEADO: 
		return true 
		
	if nome_produto == "": return true 
	var limpo = nome_produto.to_lower().strip_edges()
	return produtos_desbloqueados.has(limpo) and produtos_desbloqueados[limpo] > 0

func get_nivel(nome_produto: String) -> int:
	var limpo = nome_produto.to_lower().strip_edges()
	if produtos_desbloqueados.has(limpo):
		return produtos_desbloqueados[limpo]
	return 0
