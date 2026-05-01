extends PointLight2D

func _ready() -> void:
	if not Constantes.GRÁFICO_HIGH:
		queue_free()
		return
