extends Node

@export var paginas_pt: Array[BibliotecaResource] = []
@export var paginas_en: Array[BibliotecaResource] = []

var _mapa_nome_para_pagina: Dictionary = {}

func _ready():
	_indexar_paginas()

func _indexar_paginas():
	_mapa_nome_para_pagina.clear()
	
	var paginas_ativas: Array[BibliotecaResource] = []
	
	if Constantes.JOGO_EN == 1:
		paginas_ativas = paginas_en
	elif Constantes.JOGO_EN == 0:
		paginas_ativas = paginas_pt
		
	for pagina in paginas_ativas:
		if pagina and pagina.nome.strip_edges() != "":
			_mapa_nome_para_pagina[pagina.nome] = pagina
		else:
			print("Aviso: Página sem nome foi ignorada na database.")

func get_pagina_por_nome(nome: String) -> BibliotecaResource:
	return _mapa_nome_para_pagina.get(nome, null)
