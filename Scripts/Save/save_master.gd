extends Node

func obter_diretorio_save() -> String:
	var caminho_completo = ""
	var sistema = OS.get_name()
	
	if sistema == "Windows":
		caminho_completo = OS.get_environment("USERPROFILE") + "/AppData/LocalLow/Grimorio"
		
	elif sistema == "Linux" or sistema == "FreeBSD":
		caminho_completo = OS.get_environment("HOME") + "/.local/share/Grimorio"
	
	else:
		caminho_completo = "user://Grimorio"

	if not DirAccess.dir_exists_absolute(caminho_completo):
		var erro = DirAccess.make_dir_recursive_absolute(caminho_completo)
		
		if erro == OK:
			print("Pasta de saves criada com sucesso em: ", caminho_completo)
		
		else:
			print("Erro ao criar pasta de saves. Código do erro: ", erro)
			
	return caminho_completo


func obter_caminho_slot() -> String:
	return obter_diretorio_save() + "/slot" + str(SaveManager.slot_save_atual) + ".txt"


func checar_existe_save() -> bool:
	var diretorio = obter_diretorio_save()
	var pastas = DirAccess.get_files_at(diretorio)
	
	for arquivo in pastas:
		if arquivo.begins_with("slot") and arquivo.ends_with(".txt"):
			return true
	
	return false


func salvar_dado():
	var dados_para_salvar = compilar_dados_salvamento()
	var caminho = obter_caminho_slot()
	
	salvar_arquivo_json(caminho, dados_para_salvar)


func salvar_dado_config():
	var dados_config = ConfigManager.listarConfig()
	var caminho = obter_diretorio_save() + "/config.txt"
	
	print(dados_config)
	salvar_arquivo_json(caminho, dados_config)


func salvar_arquivo_json(caminho: String, dados: Dictionary) -> void:
	# pra encriptar, usar o método .open_encrypted_with_pass
	var arquivo = FileAccess.open(caminho, FileAccess.WRITE)
	
	if arquivo:
		var json_string = JSON.stringify(dados, "\t")
			
		arquivo.store_string(json_string)
		arquivo.close()
		print("Salvo com sucesso em: ", caminho)
		
	else:
		print("Erro ao criar o arquivo em: ", caminho)


func compilar_inventario() -> Dictionary:
	var tipo_inventario = 0
	var inventario = Inventario.get_lista_ativa()
	
	var inventario_cinto = {"slot_0": null, "slot_1": null}
	var inventario_mochila = {"slot_0": null, "slot_1": null, "slot_2": null, "slot_3": null}
	
	if Inventario.inventario_ativo == Inventario.TipoInventario.CINTO:
		tipo_inventario = 1
		for i in range(inventario.size()):
			if inventario[i] != null:
				inventario_cinto["slot_" + str(i)] = inventario[i].nome
			else:
				inventario_cinto["slot_" + str(i)] = null
			
	else:
		tipo_inventario = 0
		for i in range(inventario.size()):
			if inventario[i] != null:
				inventario_mochila["slot_" + str(i)] = inventario[i].nome
			else:
				inventario_mochila["slot_" + str(i)] = null
			
	var dados_finais = {
		"inventario_escolha": tipo_inventario,
		"cinto": inventario_cinto,
		"mochila": inventario_mochila
	}
	
	return dados_finais


func compilar_recursos():
	var recursos_salvos = {}
	var recursos_atuais = RecursosManager.listarRecursos()
	
	for item_data in recursos_atuais:
		var nome_recurso = item_data.nome
		recursos_salvos[nome_recurso] = recursos_atuais[item_data]
	
	return recursos_salvos


func compilar_codigo():
	var terminal = get_tree().get_first_node_in_group("Terminal")
	
	if terminal:
		var dados_finais = {
			"espaco_codigo_atual": terminal.slot_atual_idx,
		}
		
		for i in range(terminal.slots_codigo.size()):
			var codigo_atual = terminal.get_codigo_slot(i)
			
			if codigo_atual == null:
				codigo_atual = ""
			
			dados_finais["espaco_codigo_" + str(i)] = codigo_atual

		return dados_finais
	
	else:
		return SaveManager.GetCodigo()


func compilar_dados_salvamento() -> Dictionary:
	var dados_inventario = compilar_inventario()
	var dados_recursos = compilar_recursos()
	var dados_codigo = compilar_codigo()
	
	var dados_completos = {
		"produtos": ProgressoDB.produtos_desbloqueados,
		"inventario": dados_inventario,
		"recursos": dados_recursos,
		"codigos": dados_codigo,
	}
	
	return dados_completos


func carregar_config():
	var caminho = obter_diretorio_save() + "/config.txt"
	
	if not FileAccess.file_exists(caminho):
		print("Primeira vez rodando, arquivo config.txt não encontrado. Utilizando configurações padrão.")
		return

	var arquivo = FileAccess.open(caminho, FileAccess.READ)
	var json_string = arquivo.get_as_text()
	arquivo.close()
	
	var json = JSON.new()
	var erro = json.parse(json_string)
	
	if not erro:
		var dados_config = json.data
		ConfigManager.setConfig(dados_config)
		
	else:
		print("Erro de formatação no JSON do config: ", json.get_error_message())


func carregar_slot():
	var caminho = obter_caminho_slot()
	
	if not FileAccess.file_exists(caminho):
		SaveManager.dados_em_cache = {}
		return
		
	var arquivo = FileAccess.open(caminho, FileAccess.READ)
	var json_string = arquivo.get_as_text()
	arquivo.close()
	
	var json = JSON.new()
	var erro = json.parse(json_string)
	
	if not erro:
		SaveManager.dados_em_cache = json.data
		print("Save carregado direto na memória do SaveManager!")
		print(SaveManager.dados_em_cache)
		preenche_dados_in_game()
	else:
		print("Erro de formatação no JSON do save: ", json.get_error_message())
		SaveManager.dados_em_cache = {}


func preenche_dados_in_game():
	SaveManager.CarregarInventario()
	SaveManager.CarregarProdutos()
	SaveManager.CarregarRecursos()
	SaveManager.CarregarCodigo()
