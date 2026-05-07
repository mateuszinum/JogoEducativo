extends Node

# Retorna as configurações atuais como um texto formatado exatamente como você pediu
func listarConfig() -> String:
	var texto = "config\n{\n"
	
	# Usamos str() para converter os números e booleanos em texto
	# Para os booleanos, usamos to_lower() para garantir que saia "true" e não "True"
	texto += "\tVOLUME_MASTER = " + str(Constantes.VOLUME_MASTER) + "\n"
	texto += "\tVOLUME_MUSICA = " + str(Constantes.VOLUME_MUSICA) + "\n"
	texto += "\tVOLUME_SFX = " + str(Constantes.VOLUME_SFX) + "\n"
	texto += "\tVOLUME_UI = " + str(Constantes.VOLUME_UI) + "\n"
	texto += "\tTELA_CHEIA = " + str(Constantes.TELA_CHEIA).to_lower() + "\n"
	texto += "\tUSAR_SHAKE = " + str(Constantes.USAR_SHAKE).to_lower() + "\n"
	texto += "\tGRÁFICO_HIGH = " + str(Constantes.GRÁFICO_HIGH).to_lower() + "\n"
	
	texto += "}"
	return texto

# Recebe o texto e aplica as variáveis de volta no Constantes.gd
func setConfig(config_texto: String) -> void:
	# 1. Validação de segurança: o texto deve começar com "config" e ter "{ }"
	if not config_texto.begins_with("config") or not "{" in config_texto or not "}" in config_texto:
		push_error("ERRO: O texto não possui a estrutura correta de configuração!")
		return
		
	# 2. Pega apenas o "recheio" do texto (o que está entre as chaves { })
	var inicio = config_texto.find("{") + 1
	var fim = config_texto.find("}")
	var conteudo = config_texto.substr(inicio, fim - inicio)
	
	# 3. Separa o texto linha por linha
	var linhas = conteudo.split("\n")
	
	for linha in linhas:
		# Remove espaços vazios ou "Tabs" (\t) do começo e do fim da linha
		linha = linha.strip_edges()
		
		# Ignora linhas em branco
		if linha == "":
			continue
			
		# Se a linha não tiver o sinal de igual, a estrutura está errada
		if not "=" in linha:
			push_error("ERRO: Linha mal formatada (falta o '='): " + linha)
			continue
			
		# 4. Separa quem é a Chave e quem é o Valor
		var partes = linha.split("=")
		var chave = partes[0].strip_edges()
		var valor_str = partes[1].strip_edges()
		
		# 5. Aplica de volta no Constantes.gd identificando cada chave
		match chave:
			"VOLUME_MASTER":
				Constantes.VOLUME_MASTER = valor_str.to_float()
			"VOLUME_MUSICA":
				Constantes.VOLUME_MUSICA = valor_str.to_float()
			"VOLUME_SFX":
				Constantes.VOLUME_SFX = valor_str.to_float()
			"VOLUME_UI":
				Constantes.VOLUME_UI = valor_str.to_float()
			"TELA_CHEIA":
				Constantes.TELA_CHEIA = (valor_str.to_lower() == "true")
			"USAR_SHAKE":
				Constantes.USAR_SHAKE = (valor_str.to_lower() == "true")
			"GRÁFICO_HIGH":
				Constantes.GRÁFICO_HIGH = (valor_str.to_lower() == "true")
			_:
				push_error("ERRO: Configuração desconhecida no texto: " + chave)
