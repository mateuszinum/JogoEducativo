extends Node

var dados_em_cache: Dictionary = {}
var slot_save_atual: int = 0
# Nos métodos Get, trocar o void por Dictionary

func CarregarProdutos():
	var dados = GetProdutos()
	
	ProgressoDB.produtos_desbloqueados.clear()
	
	for chave in dados:
		ProgressoDB.produtos_desbloqueados[chave] = int(dados[chave])
		
	ProgressoDB.progresso_alterado.emit()
	print("Progresso carregado: ", ProgressoDB.produtos_desbloqueados)
	

func GetProdutos() -> Dictionary:
	
	return dados_em_cache.get("produtos", {})
	
func CarregarInventario():
	var dados = GetInventario()
	
	if dados["inventario_escolha"] == 1:
		Inventario.inventario_ativo = Inventario.TipoInventario.CINTO
		Inventario.capacidade_atual = 2
	else:
		Inventario.inventario_ativo = Inventario.TipoInventario.MOCHILA
		Inventario.capacidade_atual = 4
	
	var dict_cinto = dados["cinto"]
	for i in range(Inventario.itens_cinto.size()):
		var nome_item = dict_cinto.get("slot_" + str(i))
		if nome_item != null:
			var produto = ProdutosDB.get_produto(nome_item)
			print("Tentando carregar item: ", nome_item, " | Resultado: ", produto)
			Inventario.itens_cinto[i] = produto
		else:
			Inventario.itens_cinto[i] = null
		
	var dict_mochila = dados["mochila"]
	for i in range(Inventario.itens_mochila.size()):
		var nome_item = dict_mochila.get("slot_" + str(i))
		if nome_item != null:
			var produto = ProdutosDB.get_produto(nome_item)
			print("Tentando carregar item: ", nome_item, " | Resultado: ", produto)
			Inventario.itens_mochila[i] = produto
		else:
			Inventario.itens_mochila[i] = null
		
	Inventario.inventario_atualizado.emit()
	Inventario.inventario_comprados_atualizado.emit()
	print("Inventário reconstruído com sucesso!")

func GetInventario() -> Dictionary:
	var valor_padrao = {
		"inventario_escolha": 0, 
		"cinto": {
			"slot_0": null,
			"slot_1": null
		},
		"mochila": {
			"slot_0": null,
			"slot_1": null,
			"slot_2": null,
			"slot_3": null
		}
	}
	return dados_em_cache.get("inventario", valor_padrao)
	
func GetRecursos() -> Dictionary:
	return {}

func GetCodigo() -> Dictionary:
	return {}
	
func GetConfig() -> Dictionary:
	return {}
