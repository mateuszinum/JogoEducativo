extends Control

@onready var texto_artigo = $VBoxContainer/ScrollContainer/VBoxContainer/RichTextLabel
@onready var btn_voltar = %BotaoVoltarBiblioteca
@onready var scroll_container = $VBoxContainer/ScrollContainer

@export var pagina_para_testar: BibliotecaResource

@onready var biblioteca_db = get_node("/root/BibliotecaDB")

var historico: Array[String] = []
var pagina_atual_nome: String = ""

func _ready():
	add_to_group("BibliotecaPagina")
	texto_artigo.meta_clicked.connect(_on_link_clicado)
	btn_voltar.hide()
	visibility_changed.connect(_ao_mudar_visibilidade)
	
	if pagina_para_testar != null and pagina_para_testar.nome != "":
		pagina_atual_nome = pagina_para_testar.nome
		carregar_pagina(pagina_para_testar)
		btn_voltar.visible = false
	elif pagina_para_testar != null:
		if Constantes.DEBUG: print("Aviso: A página de teste não tem nome definido. Ignorando.")

func filtrar_texto_por_progresso(texto: String) -> String:
	var regex = RegEx.new()
	regex.compile("(?s)\\[req=(.*?)\\](.*?)\\[/req\\]")
	
	var resultado = texto
	var match_data = regex.search(resultado)
	
	while match_data != null:
		var string_completa = match_data.get_string(0)
		var requisito = match_data.get_string(1)
		var conteudo = match_data.get_string(2)
		
		if ProgressoDB.tem_desbloqueado(requisito):
			resultado = resultado.replace(string_completa, conteudo)
		else:
			resultado = resultado.replace(string_completa, "")
			
		match_data = regex.search(resultado)
		
	return resultado

func carregar_pagina(pagina: BibliotecaResource):
	texto_artigo.text = ""
	
	for bloco in pagina.blocos_de_conteudo:
		var texto_filtrado = filtrar_texto_por_progresso(bloco.texto)
		
		if texto_filtrado.strip_edges() == "":
			continue

		texto_filtrado = texto_filtrado.strip_edges(false, true)

		match bloco.tipo:
			BibliotecaTexto.TipoBloco.TITULO:
				var formatacao = "[font_size=28][color=white]" + texto_filtrado + "[/color][/font_size]"
				texto_artigo.append_text(formatacao + "\n")
				
			BibliotecaTexto.TipoBloco.SUBTITULO:
				var formatacao = "[font_size=20][color=white]" + texto_filtrado + "[/color][/font_size]"
				texto_artigo.append_text(formatacao + "\n")
				
			BibliotecaTexto.TipoBloco.TEXTO_NORMAL:
				var formatacao = "[font_size=16][color=#cccccc]" + texto_filtrado + "[/color][/font_size]"
				texto_artigo.append_text(formatacao + "\n\n")
				
			BibliotecaTexto.TipoBloco.BLOCO_CODIGO:
				var codigo_colorido = aplicar_syntax_highlight(texto_filtrado)
				var formatacao = "[indent][font_size=16][color=#d4d4d4]" + codigo_colorido + "[/color][/font_size][/indent]"
				texto_artigo.append_text("\n" + formatacao + "\n\n")
				
			BibliotecaTexto.TipoBloco.LINKS_VERDES:
				var palavras = texto_filtrado.split(" ", false) 
				var linha_formatada = ""
				for palavra in palavras:
					linha_formatada += "[url=" + palavra + "][font_size=16][color=#a8ca58][b]" + palavra + "[/b][/color][/font_size][/url]   "
				texto_artigo.append_text(linha_formatada + "\n\n")

func _on_link_clicado(meta: String):
	ir_para_pagina_por_nome(meta, true)

func ir_para_pagina_por_nome(nome_pagina: String, empilhar: bool = true) -> void:
	var pagina = biblioteca_db.get_pagina_por_nome(nome_pagina)
	if pagina == null:
		if Constantes.DEBUG: print("Erro: Página '", nome_pagina, "' não encontrada na database.")
		return

	if empilhar and pagina_atual_nome != "":
		historico.append(pagina_atual_nome)
	
	pagina_atual_nome = nome_pagina
	carregar_pagina(pagina)
	scroll_container.scroll_vertical = 0

	btn_voltar.visible = historico.size() > 0

func ir_para_pagina(caminho_do_arquivo: String) -> void:
	var nome = caminho_do_arquivo.get_file().replace(".tres", "").replace(".remap", "")
	ir_para_pagina_por_nome(nome, true)

func _on_botao_voltar_biblioteca_pressed() -> void:
	if historico.size() > 0:
		var nome_anterior = historico.pop_back()
		ir_para_pagina_por_nome(nome_anterior, false)
		
func _ao_mudar_visibilidade() -> void:
	if visible and pagina_atual_nome != "":
		var pagina = biblioteca_db.get_pagina_por_nome(pagina_atual_nome)
		if pagina != null:
			carregar_pagina(pagina)

func aplicar_syntax_highlight(codigo: String) -> String:
	var temp_codigo = codigo
	var comentarios = []
	var strings = []
	var count_com = 0
	var count_str = 0
	
	var regex_str_com = RegEx.new()
	regex_str_com.compile('(#.*)|(".*?")')
	var m = regex_str_com.search(temp_codigo)
	
	while m:
		var token = m.get_string()
		if token.begins_with("#"):
			comentarios.append(token)
			temp_codigo = temp_codigo.replace(token, "___COM" + str(count_com) + "___")
			count_com += 1
		else:
			strings.append(token)
			temp_codigo = temp_codigo.replace(token, "___STR" + str(count_str) + "___")
			count_str += 1
		m = regex_str_com.search(temp_codigo)
		
	var regex_palavra = RegEx.new()
	regex_palavra.compile("\\b\\d+(\\.\\d+)?\\b")
	temp_codigo = regex_palavra.sub(temp_codigo, "[color=#b5cea8]$0[/color]", true)
	
	var palavras_controle = ["se", "senao", "fim", "enquanto", "retorna", "funcao"]
	var palavras_tipo = ["int", "float", "bool", "string", "vazio", "Verdadeiro", "Falso", "Nulo", "Inimigo", "Arena", "Ataque", "Direcao", "cinto", "mochila"]
	var constantes_jogo = ["Cima", "Baixo", "Direita", "Esquerda", "EsferaAzul", "EsferaVermelha", "Raio", "Gelo", "Fogo", "ExplosaoFogo", "ExplosaoGelo", "Alho", "Moeda", "Osso", "Couro", "Magma", "Cristal", "Plasma", "Sangue", "Safira", "Esmeralda", "Diamante", "Goblin", "Esqueleto", "SlimeDeFogo", "SlimeDeGelo", "Lobisomem", "Orc", "Fantasma", "Vampiro", "Campos", "Floresta", "Labirinto"]
	var funcoes_nativas = ["mover", "atacar", "inimigoMaisProximo", "podeMover", "getTempo", "getVidaAtual", "escapar", "escanearArea", "posicaoX", "posicaoY", "tesouroX", "tesouroY", "arena", "comprar", "min", "max", "tamanho", "trunca", "aleatorio", "escreva", "usarItem", "colocarItem"]
	
	for p in palavras_controle:
		regex_palavra.compile("\\b" + p + "\\b")
		temp_codigo = regex_palavra.sub(temp_codigo, "[color=#c586c0]" + p + "[/color]", true)
		
	for p in palavras_tipo:
		regex_palavra.compile("\\b" + p + "\\b")
		temp_codigo = regex_palavra.sub(temp_codigo, "[color=#569cd6]" + p + "[/color]", true)
		
	for p in constantes_jogo:
		regex_palavra.compile("\\b" + p + "\\b")
		temp_codigo = regex_palavra.sub(temp_codigo, "[color=#4ec9b0]" + p + "[/color]", true)
		
	for p in funcoes_nativas:
		regex_palavra.compile("\\b" + p + "\\b")
		temp_codigo = regex_palavra.sub(temp_codigo, "[color=#dcdcaa]" + p + "[/color]", true)
		
	for i in range(strings.size()):
		temp_codigo = temp_codigo.replace("___STR" + str(i) + "___", "[color=#ce9178]" + strings[i] + "[/color]")
		
	for i in range(comentarios.size()):
		temp_codigo = temp_codigo.replace("___COM" + str(i) + "___", "[color=#6a9955]" + comentarios[i] + "[/color]")
		
	return temp_codigo

func abrir_pagina_por_nome(nome_pagina: String) -> void:
	if biblioteca_db:
		ir_para_pagina_por_nome(nome_pagina, true)
