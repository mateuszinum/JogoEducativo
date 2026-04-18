extends Resource
class_name BibliotecaTexto

enum TipoBloco { 
	TEXTO_NORMAL, 
	TITULO, 
	SUBTITULO, 
	BLOCO_CODIGO, 
	LINKS_VERDES 
}
@export var tipo: TipoBloco = TipoBloco.TEXTO_NORMAL

@export_multiline var texto: String = ""
