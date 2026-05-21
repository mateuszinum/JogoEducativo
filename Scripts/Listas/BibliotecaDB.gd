extends Node

@export var paginas: Array[BibliotecaResource] = []

var _mapa_nome_para_pagina: Dictionary = {}

func _ready():
	_indexar_paginas()

func _indexar_paginas():
	_mapa_nome_para_pagina.clear()
	for pagina in paginas:
		if pagina and pagina.nome.strip_edges() != "":
			_mapa_nome_para_pagina[pagina.nome] = pagina
		else:
			print("Aviso: Página sem nome foi ignorada na database.")

func get_pagina_por_nome(nome: String) -> BibliotecaResource:
	return _mapa_nome_para_pagina.get(nome, null)
