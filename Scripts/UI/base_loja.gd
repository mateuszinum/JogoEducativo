extends Control
class_name BaseLoja

# Sinal emitido quando o jogador clica em voltar
signal fechou_loja

@onready var label_titulo = %TituloLoja
@onready var texture_personagem = %PersonagemImagem

var fila_de_dialogos: Array[String] = []

func _ready() -> void:
	pass

func _on_botao_voltar_pressed() -> void:
	fechou_loja.emit()
	hide()
