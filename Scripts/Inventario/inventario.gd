extends Node

signal inventario_atualizado
signal inventario_comprados_atualizado
var itens_comprados: Array = []

var capacidade_atual: int = 2 
enum TipoInventario { CINTO, MOCHILA }
var inventario_ativo: TipoInventario = TipoInventario.CINTO

var itens_cinto: Array = [null, null]
var itens_mochila: Array = [null, null, null, null]

func _ready() -> void:
	RecursosManager.recursos_alterados.connect(func(): inventario_atualizado.emit())

func adicionar_item(item: ItemData, quantidade: int):
	RecursosManager.receberRecurso(item.nome, quantidade)

func get_lista_ativa() -> Array:
	if inventario_ativo == TipoInventario.CINTO:
		return itens_cinto
	return itens_mochila

func get_capacidade_maxima() -> int:
	return 2 if inventario_ativo == TipoInventario.CINTO else 4

func tentar_comprar_via_botao(produto: ProdutoLoja) -> bool:
	var lista_atual = get_lista_ativa()

	var slot_livre = -1
	for i in range(lista_atual.size()):
		if lista_atual[i] == null:
			slot_livre = i
			break
	
	if slot_livre == -1:
		#print("Este compartimento está cheio!")
		return false

	if produto.tipo != ProdutoLoja.TipoProduto.ITEM_UNICO:
		printerr("Erro: Tentativa de colocar Upgrade no Inventário!")
		return false
		
	var nome_material = ""
	var qtd_custo = 0
	if produto.custo_item_simples != null:
		nome_material = produto.custo_item_simples.nome
		qtd_custo = produto.custo_quantidade_simples
	
	var pago = false
	if Constantes.TUDO_GRATIS or (nome_material == "" and qtd_custo <= 0):
		pago = true
	else:
		pago = RecursosManager.pagarRecurso(nome_material, qtd_custo)
		
	if pago:
		lista_atual[slot_livre] = produto
		inventario_atualizado.emit() 
		inventario_comprados_atualizado.emit() 
		return true 
		
	return false

func vender_item(index: int) -> void:
	var lista_atual = get_lista_ativa()
	if index < 0 or index >= lista_atual.size(): return
	
	var produto_vendido = lista_atual[index]
	if produto_vendido == null: return
	
	var nome_recurso = produto_vendido.custo_item_simples.nome
	var qtd_reembolso = produto_vendido.custo_quantidade_simples
	RecursosManager.receberRecurso(nome_recurso, qtd_reembolso)
	
	lista_atual[index] = null
	
	if inventario_ativo == TipoInventario.MOCHILA:
		var itens_restantes = []
		for item in lista_atual:
			if item != null:
				itens_restantes.append(item)
				
		for i in range(lista_atual.size()):
			if i < itens_restantes.size():
				lista_atual[i] = itens_restantes[i]
			else:
				lista_atual[i] = null
	
	inventario_atualizado.emit()
	inventario_comprados_atualizado.emit()
	
func trocar_inventario(novo_tipo: TipoInventario) -> void:
	if inventario_ativo == novo_tipo:
		return
		
	vender_tudo()
	
	inventario_ativo = novo_tipo
	
	if inventario_ativo == TipoInventario.CINTO:
		capacidade_atual = 2
	else:
		capacidade_atual = 4
		
	inventario_comprados_atualizado.emit()
		
func vender_tudo() -> void:
	var lista_atual = get_lista_ativa()
	for i in range(lista_atual.size() - 1, -1, -1):
		if lista_atual[i] != null:
			vender_item(i)
	
	inventario_comprados_atualizado.emit()
