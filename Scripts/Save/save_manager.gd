extends Node

var dados_em_cache: Dictionary = {}
var slot_save_atual: int = 0
# Nos métodos Get, trocar o void por Dictionary

func GetSkillTree() -> Dictionary:
	return dados_em_cache.get("skill_tree", {})
	
func GetAtributosBruxa() -> Dictionary:
	return dados_em_cache.get("atributos", {})

func GetInventario() -> Dictionary:
	var valor_padrao = {
		"inventario_escolha": 0, 
		"cinto": {
			"0": "",
			"1": ""
		},
		"mochila": {
			"0": "",
			"1": "",
			"2": "",
			"3": ""
		}
	}
	
	return dados_em_cache.get("inventario", valor_padrao)
	
func GetRecursos() -> Dictionary:
	return {}

func GetCodigo() -> Dictionary:
	return {}
	
func GetConfig() -> Dictionary:
	return {}
