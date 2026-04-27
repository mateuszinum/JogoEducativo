extends Node

signal recursos_alterados

var meus_recursos: Dictionary = {}

func listarRecursos() -> Dictionary:
	return meus_recursos

func aplicarListaRecursos(listaDeRecursos: Dictionary) -> void:
	meus_recursos = listaDeRecursos.duplicate()
	recursos_alterados.emit()

func receberRecurso(recurso: String, quantidade: int) -> void:
	var item_data = RecursosDB.get_recurso(recurso)
	
	if item_data == null:
		printerr("Erro no Manager: Recurso '" + recurso + "' não encontrado no banco de dados.")
		return
		
	if meus_recursos.has(item_data):
		meus_recursos[item_data] += quantidade
	else:
		meus_recursos[item_data] = quantidade
		
	recursos_alterados.emit()

func pagarRecurso(recurso: String, quantidade: int) -> bool:
	if Constantes.TUDO_GRATIS:
		return true

	var item_data = RecursosDB.get_recurso(recurso)
	
	if item_data == null:
		printerr("Erro no Manager: Recurso '" + recurso + "' não encontrado no banco de dados.")
		return false
		
	if meus_recursos.has(item_data) and meus_recursos[item_data] >= quantidade:
		meus_recursos[item_data] -= quantidade
		
		if meus_recursos[item_data] <= 0:
			meus_recursos.erase(item_data)
			
		recursos_alterados.emit()
		return true
		
	return false
