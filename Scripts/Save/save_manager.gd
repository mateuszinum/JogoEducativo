extends Node

var slot_save_atual: int = 0
# Nos métodos Get, trocar o void por Dictionary

func GetSkillTree() -> Dictionary:
	var produtos = ProgressoDB.produtos_desbloqueados
	var produtos_formatados = produtos.keys()
	return produtos_formatados
	
func GetAtributosBruxa() -> Dictionary:
	return {}

func GetInventario() -> Dictionary:
	return {}
	
func GetRecursos() -> Dictionary:
	return {}

func GetCodigo() -> Dictionary:
	return {}
	
func GetConfig() -> Dictionary:
	return {}
