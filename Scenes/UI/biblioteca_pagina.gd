extends Control
@onready var texto_artigo = $ScrollContainer/VBoxContainer/RichTextLabel

@export var pagina_para_testar: BibliotecaResource

func _ready():
	texto_artigo.meta_clicked.connect(_on_link_clicado)
	if pagina_para_testar != null:
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
				var formatacao = "[font_size=22][color=white]" + bloco.texto + "[/color][/font_size]"
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

func _on_link_clicado(meta):
	# 'meta' contém o valor do link clicado (ex: "External Editor")
	print("O link clicado foi: ", meta)
	
	# A partir daqui você insere a lógica para mudar de página.
	# Como você já tem a função carregar_pagina(), o fluxo seria algo como:
	# var caminho_do_resource = "res://Pasta/Da/Biblioteca/" + str(meta) + ".tres"
	# var nova_pagina = load(caminho_do_resource)
	# if nova_pagina:
	#     carregar_pagina(nova_pagina)
