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
var itens_cinto: Array = []
var itens_mochila: Array = []

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
	
	if lista_atual.size() >= get_capacidade_maxima():
		print("Este compartimento está cheio!")
		return false

	var material_custo = produto.custo_item_simples
	var qtd_custo = produto.custo_quantidade_simples
	
	if itens_coletados.has(material_custo) and itens_coletados[material_custo] >= qtd_custo:
		itens_coletados[material_custo] -= qtd_custo
		if itens_coletados[material_custo] <= 0:
			itens_coletados.erase(material_custo)
			
		# Adiciona apenas na lista ativa (Cinto ou Mochila)
		lista_atual.push_front(produto)
		
		inventario_atualizado.emit() 
		inventario_comprados_atualizado.emit() 
		return true 
	return false

# --- Venda e Troca ---
func vender_item(index: int) -> void:
	var lista_atual = get_lista_ativa()
	if index < 0 or index >= lista_atual.size(): return
	
	var produto_vendido = lista_atual[index]
	var recurso = produto_vendido.custo_item_simples
	var qtd_reembolso = produto_vendido.custo_quantidade_simples

	# Verifica se a chave existe no dicionário
	if itens_coletados.has(recurso):
		itens_coletados[recurso] += qtd_reembolso # Se sim, apenas soma
	else:
		itens_coletados[recurso] = qtd_reembolso  # Se não, recria a chave com o valor devolvido
			
	# Estas linhas devem rodar SEMPRE, por isso ficam alinhadas na esquerda (fora do if/else)
	lista_atual.remove_at(index)
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
	# 1. Identificamos qual a lista que deve ser limpa (Cinto ou Mochila)
	var lista_atual = get_lista_ativa()
	
	# 2. Loop Reverso: Começamos do último índice para o primeiro.
	# Isso é vital porque, ao remover o último, os índices dos anteriores não mudam.
	for i in range(lista_atual.size() - 1, -1, -1):
		vender_item(i)
	
	# 3. Garantimos que a UI sabe que tudo foi vendido
	inventario_comprados_atualizado.emit()
	print("Venda em massa concluída para: ", "Cinto" if inventario_ativo == TipoInventario.CINTO else "Mochila")
		
	inventario_comprados_atualizado.emit()
