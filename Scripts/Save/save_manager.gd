extends Node

var dados_em_cache: Dictionary = {}
var slot_save_atual: int = 0

#------ Métodos Carregar ------

func CarregarProdutos():
	var dados = GetProdutos()
	
	ProgressoDB.produtos_desbloqueados.clear()
	
	for chave in dados:
		ProgressoDB.produtos_desbloqueados[chave] = int(dados[chave])
		
	ProgressoDB.progresso_alterado.emit()
	print("Progresso carregado: ", ProgressoDB.produtos_desbloqueados)
	
	
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


func CarregarRecursos():
	var dados = GetRecursos()
	var recursos = {}
	
	if dados != null:
		for nome_recurso in dados:
			var item_data = RecursosDB.get_recurso(nome_recurso)
			
			if item_data != null:
				recursos[item_data] = int(dados[nome_recurso])
	
	RecursosManager.aplicarListaRecursos(recursos)

func CarregarCodigo():
	var dados_codigo = GetCodigo()
	var terminal = get_tree().get_first_node_in_group("Terminal")

	if terminal and dados_codigo != null:
		terminal.slot_atual_idx = int(dados_codigo.get("espaco_codigo_atual", 0))
		
		for slot in range(terminal.slots_codigo.size()):
			var chave_json = "espaco_codigo_" + str(slot)
			var codigo_terminal = dados_codigo.get(chave_json, "")
			
			terminal.definir_codigo_slot(slot, codigo_terminal)


#------ Métodos Get ------

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
	
func GetProdutos() -> Dictionary:
	return dados_em_cache.get("produtos", {})

func GetRecursos() -> Dictionary:
	return dados_em_cache.get("recursos", {})

func GetCodigo() -> Dictionary:
	return dados_em_cache.get("codigos", {})
