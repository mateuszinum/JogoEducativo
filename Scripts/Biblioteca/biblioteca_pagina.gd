extends Control
@onready var texto_artigo = $VBoxContainer/ScrollContainer/VBoxContainer/RichTextLabel
@onready var btn_voltar = %BotaoVoltarBiblioteca
@onready var scroll_container = $VBoxContainer/ScrollContainer
@export var pagina_para_testar: BibliotecaResource

var historico: Array[String] = []
var pagina_atual_caminho: String = ""
var mapa_de_paginas = {}

func _ready():
	texto_artigo.meta_clicked.connect(_on_link_clicado)
	btn_voltar.hide()
	
	mapear_todos_os_arquivos("res://Resources/Biblioteca/")
	
	visibility_changed.connect(_ao_mudar_visibilidade)
	
	if pagina_para_testar != null:
		pagina_atual_caminho = pagina_para_testar.resource_path
		carregar_pagina(pagina_para_testar)
	else:
		print("Faltou colocar um texto aqui")

# ==========================================
# NOVO: FILTRO DINÂMICO DE PROGRESSÃO
# ==========================================
func filtrar_texto_por_progresso(texto: String) -> String:
	var regex = RegEx.new()
	# (?s) permite que a regex leia quebras de linha caso o texto do requisito seja longo
	regex.compile("(?s)\\[req=(.*?)\\](.*?)\\[/req\\]")
	
	var resultado = texto
	var match_data = regex.search(resultado)
	
	while match_data != null:
		var string_completa = match_data.get_string(0) # Ex: [req=Fogo]Magia...[/req]
		var requisito = match_data.get_string(1)       # Ex: Fogo
		var conteudo = match_data.get_string(2)        # Ex: Magia...
		
		if ProgressoDB.tem_desbloqueado(requisito):
			# Se possui a skill, remove a "casca" da tag e deixa o texto aparecer
			resultado = resultado.replace(string_completa, conteudo)
		else:
			# Se NÃO possui a skill, apaga tudo, ocultando o spoiler do jogador
			resultado = resultado.replace(string_completa, "")
			
		# Continua procurando outras tags na mesma string
		match_data = regex.search(resultado)
		
	return resultado

func carregar_pagina(pagina: BibliotecaResource):
	texto_artigo.text = ""
	
	for bloco in pagina.blocos_de_conteudo:
		# 1. Filtra os spoilers ANTES de aplicar as cores e tamanhos
		var texto_filtrado = filtrar_texto_por_progresso(bloco.texto)
		
		# 2. Se o bloco inteiro sumiu (era um parágrafo inteiro bloqueado), 
		# pula ele para não deixar um "buraco" de linhas em branco na tela.
		if texto_filtrado.strip_edges() == "":
			continue

		match bloco.tipo:
			BibliotecaTexto.TipoBloco.TITULO:
				var formatacao = "[font_size=28][color=white]" + texto_filtrado + "[/color][/font_size]"
				texto_artigo.append_text(formatacao + "\n")
				
			BibliotecaTexto.TipoBloco.SUBTITULO:
				var formatacao = "[font_size=20][color=white]" + texto_filtrado + "[/color][/font_size]"
				texto_artigo.append_text(formatacao + "\n")
				
			BibliotecaTexto.TipoBloco.TEXTO_NORMAL:
				var formatacao = "[font_size=16][color=#cccccc]" + texto_filtrado + "[/color][/font_size]"
				texto_artigo.append_text(formatacao + "\n")
				
			BibliotecaTexto.TipoBloco.BLOCO_CODIGO:
				var formatacao = "[indent][code][font_size=16][color=white]" + texto_filtrado + "[/color][/font_size][/code][/indent]"
				texto_artigo.append_text(formatacao + "\n")
				
			BibliotecaTexto.TipoBloco.LINKS_VERDES:
				# Como o texto filtrado já removeu links bloqueados, o split
				# ignorará perfeitamente os botões que o jogador não tem acesso.
				var palavras = texto_filtrado.split(" ", false) 
				var linha_formatada = ""
				
				for palavra in palavras:
					linha_formatada += "[url=" + palavra + "][font_size=16][color=#a8ca58][b]" + palavra + "[/b][/color][/font_size][/url]   "
				
				texto_artigo.append_text(linha_formatada + "\n\n")

func _on_link_clicado(meta: String):
	if mapa_de_paginas.has(meta):
		ir_para_pagina(mapa_de_paginas[meta])
	else:
		print("Erro: A página '", meta, "' não foi encontrada no mapa_de_paginas.")
		
func mapear_todos_os_arquivos(caminho_da_pasta: String):
	var dir = DirAccess.open(caminho_da_pasta)
	
	if dir:
		dir.list_dir_begin()
		var nome_arquivo = dir.get_next()
		
		while nome_arquivo != "":
			if dir.current_is_dir():
				if not nome_arquivo.begins_with("."):
					mapear_todos_os_arquivos(caminho_da_pasta + nome_arquivo + "/")
			elif nome_arquivo.ends_with(".tres") or nome_arquivo.ends_with(".tres.remap"):
				var chave = nome_arquivo.replace(".tres.remap", "").replace(".tres", "")
				mapa_de_paginas[chave] = caminho_da_pasta + nome_arquivo
				
			nome_arquivo = dir.get_next()
			
func ir_para_pagina(caminho_do_arquivo: String) -> void:
	if pagina_atual_caminho != "":
		historico.append(pagina_atual_caminho)
		
	pagina_atual_caminho = caminho_do_arquivo
	
	var nova_pagina = load(caminho_do_arquivo)
	if nova_pagina != null:
		carregar_pagina(nova_pagina)
		scroll_container.scroll_vertical = 0
		btn_voltar.visible = historico.size() > 0
	else:
		print("Erro: Não foi possível carregar -> ", caminho_do_arquivo)

func _on_botao_voltar_biblioteca_pressed() -> void:
	if historico.size() > 0:
		var caminho_anterior = historico.pop_back()
		pagina_atual_caminho = caminho_anterior
		
		var nova_pagina = load(caminho_anterior)
		carregar_pagina(nova_pagina)
		
		scroll_container.scroll_vertical = 0
		btn_voltar.visible = historico.size() > 0
		
func _ao_mudar_visibilidade() -> void:
	# Só recarrega se a biblioteca acabou de ficar visível na tela
	if visible and pagina_atual_caminho != "":
		var pagina_atual = load(pagina_atual_caminho)
		
		if pagina_atual != null:
			# Passa a página pelo filtro de novo para checar novos desbloqueios
			carregar_pagina(pagina_atual)
