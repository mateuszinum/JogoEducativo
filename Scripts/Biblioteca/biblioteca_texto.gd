extends Resource
class_name BibliotecaTexto

enum TipoBloco { TEXTO_NORMAL, TITULO }
@export var tipo: TipoBloco = TipoBloco.TEXTO_NORMAL

@export_multiline var texto: String = ""
