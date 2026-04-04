@tool 
extends Resource
class_name ProdutoLoja

enum TipoProduto { ITEM_UNICO, DESBLOQUEIO_UNICO, UPGRADE, DESBLOQUEIO_PROGRESSIVO }

@export var nome: String
@export var icone: Texture2D

@export var tipo: TipoProduto = TipoProduto.ITEM_UNICO:
	set(value):
		tipo = value
		notify_property_list_changed()

@export_multiline var descricao_simples: String
@export var custo_item_simples: ItemData
@export var custo_quantidade_simples: int = 1

@export_multiline var descricao_atual_base: String 
@export_multiline var descricao_upgrade_base: String 

@export_multiline var descricao_bloqueada: String 

@export var niveis: Array[NivelUpgrade] = []

func _validate_property(property: Dictionary) -> void:
	var is_simples = (tipo == TipoProduto.ITEM_UNICO or tipo == TipoProduto.DESBLOQUEIO_UNICO)
	var is_progressao = (tipo == TipoProduto.UPGRADE or tipo == TipoProduto.DESBLOQUEIO_PROGRESSIVO)
	
	if property.name in ["descricao_simples", "custo_item_simples", "custo_quantidade_simples"]:
		if not is_simples: property.usage = PROPERTY_USAGE_NO_EDITOR
			
	if property.name in ["descricao_atual_base", "descricao_upgrade_base"]:
		if tipo != TipoProduto.UPGRADE: property.usage = PROPERTY_USAGE_NO_EDITOR
		
	if property.name == "descricao_bloqueada":
		if tipo != TipoProduto.DESBLOQUEIO_PROGRESSIVO: property.usage = PROPERTY_USAGE_NO_EDITOR
		
	if property.name == "niveis":
		if not is_progressao: property.usage = PROPERTY_USAGE_NO_EDITOR
