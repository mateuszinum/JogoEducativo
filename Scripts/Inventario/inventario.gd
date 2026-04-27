extends Node

# Nosso dicionário vai guardar o Resource do item como Chave, e a quantidade como Valor
var itens_coletados: Dictionary = {}
# Dicionário que você vai preencher no Inspetor (Nome -> ProdutoLoja)
# Sinal que vai gritar para a UI atualizar toda vez que pegarmos algo
signal inventario_atualizado
# Variável que você pediu para salvar os itens que foram comprados
var itens_comprados: Array = []

func adicionar_item(item: ItemData, quantidade: int):
	# Se o item já existe no dicionário, soma a quantidade. Se não, cria ele.
	if itens_coletados.has(item):
		itens_coletados[item] += quantidade # Soma a quantidade sorteada
	else:
		itens_coletados[item] = quantidade # Cria com a quantidade sorteada
		
		
	# Avisa a tela do jogo que os números mudaram
	inventario_atualizado.emit()


var capacidade_atual: int = 2 # Começa com o cinto (2 slots)
# Sinal para avisar a tela da loja que os slots mudaram
signal inventario_comprados_atualizado


enum TipoInventario { CINTO, MOCHILA }
var inventario_ativo: TipoInventario = TipoInventario.CINTO

# AGORA TEMOS DUAS LISTAS SEPARADAS
var itens_cinto: Array = [null, null]
var itens_mochila: Array = [null, null, null, null]

# Função auxiliar para pegar a lista que está em uso no momento
func get_lista_ativa() -> Array:
	if inventario_ativo == TipoInventario.CINTO:
		return itens_cinto
	return itens_mochila

func get_capacidade_maxima() -> int:
	return 2 if inventario_ativo == TipoInventario.CINTO else 4

# --- Lógica de Compra Atualizada ---
func tentar_comprar_via_botao(produto: ProdutoLoja) -> bool:
	var lista_atual = get_lista_ativa()

	var slot_livre = -1
	for i in range(lista_atual.size()):
		if lista_atual[i] == null:
			slot_livre = i
			break
	
	if slot_livre == -1:
		print("Ese compartimento está cheio!")
		return false

	var material_custo = produto.custo_item_simples
	var qtd_custo = produto.custo_quantidade_simples
	
	if itens_coletados.has(material_custo) and itens_coletados[material_custo] >= qtd_custo:
		itens_coletados[material_custo] -= qtd_custo
		if itens_coletados[material_custo] <= 0:
			itens_coletados.erase(material_custo)
			
		# Adiciona apenas na lista ativa (Cinto ou Mochila)
		lista_atual[slot_livre] = produto
		
		inventario_atualizado.emit() 
		inventario_comprados_atualizado.emit() 
		return true 
	return false

# --- Venda e Troca ---
func vender_item(index: int) -> void:
	var lista_atual = get_lista_ativa()
	if index < 0 or index >= lista_atual.size():
		return
	
	var produto_vendido = lista_atual[index]
	if produto_vendido == null:
		return
	
	var recurso = produto_vendido.custo_item_simples
	var qtd_reembolso = produto_vendido.custo_quantidade_simples

	if itens_coletados.has(recurso):
		itens_coletados[recurso] += qtd_reembolso
		
	else:
		itens_coletados[recurso] = qtd_reembolso
			
	lista_atual[index] = null
	inventario_atualizado.emit()
	inventario_comprados_atualizado.emit()
	
func trocar_inventario(novo_tipo: TipoInventario) -> void:
	# AGORA APENAS TROCA O MODO, SEM VENDER NADA
	inventario_ativo = novo_tipo
	inventario_comprados_atualizado.emit()
	

	
	inventario_ativo = novo_tipo
	if inventario_ativo == TipoInventario.CINTO:
		capacidade_atual = 2
	else:
		capacidade_atual = 4
		
func vender_tudo() -> void:
	# CASO FOR DELETAR ESSA FUNÇÃO, PASSAR ELA PARA FuncoesNativas.gd, na parte de vender_tudo
	var lista_atual = get_lista_ativa()
	for i in range(lista_atual.size()):
		vender_item(i)
	
	print("Venda em massa concluída para: ", "Cinto" if inventario_ativo == TipoInventario.CINTO else "Mochila")
	inventario_comprados_atualizado.emit()
