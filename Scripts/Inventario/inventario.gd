extends Node

# Nosso dicionário vai guardar o Resource do item como Chave, e a quantidade como Valor
var itens_coletados: Dictionary = {}
# Dicionário que você vai preencher no Inspetor (Nome -> ProdutoLoja)
# Sinal que vai gritar para a UI atualizar toda vez que pegarmos algo
signal inventario_atualizado


func adicionar_item(item: ItemData, quantidade: int):
	# Se o item já existe no dicionário, soma a quantidade. Se não, cria ele.
	if itens_coletados.has(item):
		itens_coletados[item] += quantidade # Soma a quantidade sorteada
	else:
		itens_coletados[item] = quantidade # Cria com a quantidade sorteada
		
		
	# Avisa a tela do jogo que os números mudaram
	inventario_atualizado.emit()
