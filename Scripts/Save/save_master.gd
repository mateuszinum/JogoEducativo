extends Node

func obter_diretorio_save() -> String:
	var caminho_completo = ""
	var sistema = OS.get_name()
	
	if sistema == "Windows":
		caminho_completo = OS.get_environment("USERPROFILE") + "/AppData/LocalLow/Grimorio"
		
	elif sistema == "Linux" or sistema == "FreeBSD":
		caminho_completo = OS.get_environment("HOME") + "/.local/share/Grimorio"

	if not DirAccess.dir_exists_absolute(caminho_completo):
		pass
		# cria pasta

			
	return caminho_completo


func obter_caminho_slot(slot_id: int) -> String:
	return obter_diretorio_save() + "/slot" + str(slot_id) + ".txt"


func salvar_dado(slot_id: int, dados_para_salvar: Dictionary):
	var caminho = obter_caminho_slot(slot_id)
	
	# pra encriptar, usar o método .open_encrypted_with_pass
	var arquivo = FileAccess.open(caminho, FileAccess.WRITE)
	
	if arquivo:
		var json_string = JSON.stringify(dados_para_salvar, "\t")
		
		arquivo.store_string(json_string)
		arquivo.close()
		print("Salvo com sucesso no slot ", slot_id, " em: ", caminho)
	else:
		print("Erro ao criar o arquivo em: ", caminho)


func carregar_dado(slot_id: int) -> Dictionary:
	var caminho = obter_caminho_slot(slot_id)
	
	if not FileAccess.file_exists(caminho):
		return {}
		
	var arquivo = FileAccess.open(caminho, FileAccess.READ)
	var json_string = arquivo.get_as_text()
	arquivo.close()
	
	var json = JSON.new()
	var erro = json.parse(json_string)
	
	if !erro:
		return json.data
	else:
		print("Erro de formatação no JSON do save: ", json.get_error_message())
		return {}
