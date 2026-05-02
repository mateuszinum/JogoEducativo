extends Node

func _ready() -> void:
	if not Constantes.GRÁFICO_HIGH:
		queue_free()
		return
