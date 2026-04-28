extends Node

signal recursos_alterados
signal recurso_ganho(item: ItemData)
signal recurso_gasto(item: ItemData)
signal falha_pagamento(item: ItemData)

var meus_recursos: Dictionary = {}

func listarRecursos() -> Dictionary:
	return meus_recursos

func aplicarListaRecursos(listaDeRecursos: Dictionary) -> void:
	meus_recursos = listaDeRecursos.duplicate()
	recursos_alterados.emit()

func receberRecurso(recurso: String, quantidade: int) -> void:
	var item_data = RecursosDB.get_recurso(recurso)
	if item_data == null: return
		
	if meus_recursos.has(item_data):
		meus_recursos[item_data] += quantidade
	else:
		meus_recursos[item_data] = quantidade
		
	recursos_alterados.emit()
	recurso_ganho.emit(item_data)

func pagarRecurso(recurso: String, quantidade: int) -> bool:
	if Constantes.TUDO_GRATIS:
		return true

	var item_data = RecursosDB.get_recurso(recurso)
	if item_data == null: return false
		
	if meus_recursos.has(item_data) and meus_recursos[item_data] >= quantidade:
		meus_recursos[item_data] -= quantidade
		if meus_recursos[item_data] <= 0:
			meus_recursos.erase(item_data)
			
		recursos_alterados.emit()
		recurso_gasto.emit(item_data)
		return true
	
	falha_pagamento.emit(item_data)
	return false
