extends Node

var achievements_desbloqueados: Dictionary = {}

func unlock_achievement(id: String) -> void:
	if achievements_desbloqueados.has(id) and achievements_desbloqueados[id]:
		return
		
	print("[Steam API] Desbloqueando: ", id)
	achievements_desbloqueados[id] = true
