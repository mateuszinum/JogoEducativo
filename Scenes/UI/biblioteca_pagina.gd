extends Control
@onready var texto_artigo = $VBoxContainer/ScrollContainer/VBoxContainer/RichTextLabel
@onready var container_voltar = $VBoxContainer/ContainerBotao
@onready var btn_voltar = %BotaoVoltarBiblioteca
@onready var scroll_container = $VBoxContainer/ScrollContainer
@export var pagina_para_testar: BibliotecaResource

var historico: Array[String] = []
var pagina_atual_caminho: String = ""
var mapa_de_paginas = {}

func _ready():
	texto_artigo.meta_clicked.connect(_on_link_clicado)
	container_voltar.hide()
	
	mapear_todos_os_arquivos("res://Resources/Biblioteca/")
	
	if pagina_para_testar != null:
		pagina_atual_caminho = pagina_para_testar.resource_path
		carregar_pagina(pagina_para_testar)
	else:
		print("Faltou colocar um texto aqui")

func carregar_pagina(pagina: BibliotecaResource):
	texto_artigo.text = ""
	
	for bloco in pagina.blocos_de_conteudo:
		match bloco.tipo:
			BibliotecaTexto.TipoBloco.TITULO:
				# Títulos grandes e brancos (ex: "General Info", "For Loop")
				var formatacao = "[font_size=28][color=white]" + bloco.texto + "[/color][/font_size]"
				texto_artigo.append_text(formatacao + "\n\n")
				
			BibliotecaTexto.TipoBloco.SUBTITULO:
				# Títulos intermediários (ex: "Syntax", "Sequences")
				var formatacao = "[font_size=20][color=white]" + bloco.texto + "[/color][/font_size]"
				texto_artigo.append_text(formatacao + "\n\n")
				
			BibliotecaTexto.TipoBloco.TEXTO_NORMAL:
				# Texto corrido padrão, levemente acinzentado para leitura
				var formatacao = "[font_size=16][color=#cccccc]" + bloco.texto + "[/color][/font_size]"
				texto_artigo.append_text(formatacao + "\n\n")
				
			BibliotecaTexto.TipoBloco.BLOCO_CODIGO:
				# Trechos de código (ex: "for i in sequence:"). 
				# A tag [code] aplica fonte monoespaçada e [indent] dá o recuo.
				var formatacao = "[indent][code][font_size=16][color=white]" + bloco.texto + "[/color][/font_size][/code][/indent]"
				texto_artigo.append_text(formatacao + "\n\n")
				
			BibliotecaTexto.TipoBloco.LINKS_VERDES:
				# Separa o texto em um array de palavras, usando o espaço como divisor. 
				# O 'false' ignora espaços duplos acidentais.
				var palavras = bloco.texto.split(" ", false) 
				var linha_formatada = ""
				
				for palavra in palavras:
					# Monta a tag [url] para cada palavra individual e adiciona um espaçamento ("   ") entre elas
					linha_formatada += "[url=" + palavra + "][font_size=16][color=#a8ca58][b]" + palavra + "[/b][/color][/font_size][/url]   "
				
				# Adiciona a linha inteira de uma vez no painel, quebrando a linha apenas no final do bloco
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
				# Se for uma pasta, entra nela (ignora pastas invisíveis e de sistema)
				if not nome_arquivo.begins_with("."):
					mapear_todos_os_arquivos(caminho_da_pasta + nome_arquivo + "/")
			elif nome_arquivo.ends_with(".tres") or nome_arquivo.ends_with(".tres.remap"):
				# Remove o ".tres" para usar o nome do arquivo como chave
				var chave = nome_arquivo.replace(".tres.remap", "").replace(".tres", "")
				mapa_de_paginas[chave] = caminho_da_pasta + nome_arquivo
				
			nome_arquivo = dir.get_next()
			
# Adicione esta função ao seu script
func ir_para_pagina(caminho_do_arquivo: String) -> void:
	if pagina_atual_caminho != "":
		historico.append(pagina_atual_caminho)
		
	pagina_atual_caminho = caminho_do_arquivo
	
	var nova_pagina = load(caminho_do_arquivo)
	if nova_pagina != null:
		carregar_pagina(nova_pagina)
		
		scroll_container.scroll_vertical = 0
		
		container_voltar.visible = historico.size() > 0
	else:
		print("Erro: Não foi possível carregar -> ", caminho_do_arquivo)


func _on_botao_voltar_biblioteca_pressed() -> void:
	if historico.size() > 0:
		var caminho_anterior = historico.pop_back()
		
		pagina_atual_caminho = caminho_anterior
		
		var nova_pagina = load(caminho_anterior)
		carregar_pagina(nova_pagina)
		
		scroll_container.scroll_vertical = 0
		
		container_voltar.visible = historico.size() > 0
