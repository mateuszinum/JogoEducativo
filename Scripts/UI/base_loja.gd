extends Control
class_name BaseLoja

signal fechou_loja

@onready var label_titulo = %TituloLoja
@onready var overlay_dialogo = %OverlayDialogo

@export var dialogo_personagem: DialogoResource

func _ready() -> void:
	pass

func _on_botao_voltar_pressed() -> void:
	fechou_loja.emit()
	hide()

func _on_personagem_pressed() -> void:
	if dialogo_personagem != null:
		overlay_dialogo.iniciar_dialogo(dialogo_personagem)


func _on_botao_trocar_inventario_pressed() -> void:
	if Inventario.inventario_ativo == Inventario.TipoInventario.CINTO:
		Inventario.trocar_inventario(Inventario.TipoInventario.MOCHILA)
	else:
		Inventario.trocar_inventario(Inventario.TipoInventario.CINTO)


func _on_vender_tudo_pressed() -> void:
	Inventario.vender_tudo()
