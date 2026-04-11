extends Control
class_name BaseLoja

signal fechou_loja

@onready var label_titulo = %TituloLoja
@onready var overlay_dialogo = %OverlayDialogo

func _ready() -> void:
	pass

func _on_botao_voltar_pressed() -> void:
	fechou_loja.emit()
	hide()
