extends Control
@onready var texto_artigo = $VBoxContainer/RichTextLabel

@export var pagina_para_testar: BibliotecaResource

func _ready():
	if pagina_para_testar != null:
		carregar_pagina(pagina_para_testar)
	else:
		print("Faltou colocar um texto aqui")

func carregar_pagina(pagina: BibliotecaResource):
	texto_artigo.text = ""
	
	for bloco in pagina.blocos_de_conteudo:
		
		match bloco.tipo:
			BibliotecaTexto.TipoBloco.TITULO:
				var formatacao = "[font_size=24][color=#a8ca58][b]" + bloco.texto + "[/b][/color][/font_size]"
				texto_artigo.append_text(formatacao + "\n\n")
				
			BibliotecaTexto.TipoBloco.TEXTO_NORMAL:
				texto_artigo.append_text(bloco.texto + "\n\n")
