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

func salvar_dado():
	var dados_para_salvar = compilar_dados_salvamento()
	var caminho = obter_caminho_slot()
	
	# pra encriptar, usar o método .open_encrypted_with_pass
	var arquivo = FileAccess.open(caminho, FileAccess.WRITE)
	
	if arquivo:
		var json_string = JSON.stringify(dados_para_salvar, "\t")
		
		arquivo.store_string(json_string)
		arquivo.close()
		print("Salvo com sucesso no slot ", SaveManager.slot_save_atual, " em: ", caminho)
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
			inventario_cinto["slot_" + str(i)] = inventario[i]
			
	else:
		tipo_inventario = 0
		for i in range(inventario.size()):
			inventario_mochila["slot_" + str(i)] = inventario[i]
			
	var dados_finais = {
		"inventario_escolha": tipo_inventario,
		"cinto": inventario_cinto,
		"mochila": inventario_mochila
	}
	
	return dados_finais

func compilar_dados_salvamento() -> Dictionary:
	var dados_inventario = compilar_inventario()
	
	var dados_completos = {
		"skill-tree": SaveManager.GetSkillTree(),
		"atributos": SaveManager.GetAtributosBruxa(),
		"inventario_escolha": dados_inventario["inventario_escolha"],
		"cinto": dados_inventario["cinto"],
		"mochila": dados_inventario["mochila"],
		"recursos": SaveManager.GetRecursos(),
		"codigos": SaveManager.GetCodigo()
	}
	
	return dados_completos

func carregar_slot():
	var caminho = obter_caminho_slot()
	
	if not FileAccess.file_exists(caminho):
		# Se não tem save, garante que a memória comece limpa
		SaveManager.dados_em_cache = {}
		return
		
	var arquivo = FileAccess.open(caminho, FileAccess.READ)
	var json_string = arquivo.get_as_text()
	arquivo.close()
	
	var json = JSON.new()
	var erro = json.parse(json_string)
	
	if not erro:
		# Injeta os dados direto na memória do SaveManager
		SaveManager.dados_em_cache = json.data
		print("Save carregado direto na memória do SaveManager!")
	else:
		print("Erro de formatação no JSON do save: ", json.get_error_message())
		SaveManager.dados_em_cache = {}
