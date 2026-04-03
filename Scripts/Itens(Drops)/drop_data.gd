@tool # Permite que o script rode dentro do editor do Godot
extends Resource
class_name DropData

@export var item: ItemData
@export_range(0.0, 100.0) var chance_de_drop: float = 100

@export var quantidade_minima: int = 1:
	set(valor_novo):
		# Impede números negativos e garante que o min nunca supere o max
		quantidade_minima = max(0, valor_novo)
		if quantidade_maxima < quantidade_minima:
			quantidade_maxima = quantidade_minima
		notify_property_list_changed() # Atualiza visualmente o Inspetor

@export var quantidade_maxima: int = 1:
	set(valor_novo):
		# Garante que o max nunca seja menor que o min atual
		quantidade_maxima = max(valor_novo, quantidade_minima)
		notify_property_list_changed()
