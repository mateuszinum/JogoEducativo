extends Node

const DIR_PT: String = "res://Resources/Biblioteca/pt-br"
const DIR_EN: String = "res://Resources/Biblioteca/en"

const PASTAS_IGNORADAS: PackedStringArray = ["UI"]

const PAGINAS_AVULSAS: PackedStringArray = [
	"res://Resources/Biblioteca/PaginaInicial.tres",
]

var paginas_pt: Array[BibliotecaResource] = []
var paginas_en: Array[BibliotecaResource] = []

var _mapa_nome_para_pagina: Dictionary = {}

func _ready():
	paginas_pt = _carregar_pasta(DIR_PT)
	paginas_en = _carregar_pasta(DIR_EN)
	_adicionar_paginas_avulsas()
	_indexar_paginas()

func _adicionar_paginas_avulsas():
	for caminho in PAGINAS_AVULSAS:
		var res := load(caminho)
		if res is BibliotecaResource:
			paginas_pt.append(res)
			paginas_en.append(res)
		else:
			push_warning("BibliotecaDB: pagina avulsa '%s' nao encontrada ou invalida." % caminho)

func _carregar_pasta(caminho_raiz: String) -> Array[BibliotecaResource]:
	var caminhos: Array[String] = []
	var pilha: Array[String] = [caminho_raiz]

	while not pilha.is_empty():
		var dir_atual: String = pilha.pop_back()
		var dir := DirAccess.open(dir_atual)
		if dir == null:
			push_warning("BibliotecaDB: não consegui abrir a pasta '%s'" % dir_atual)
			continue

		dir.list_dir_begin()
		var nome := dir.get_next()
		while nome != "":
			var caminho := dir_atual.path_join(nome)
			if dir.current_is_dir():
				if not PASTAS_IGNORADAS.has(nome):
					pilha.push_back(caminho)
			else:
				var limpo := nome.trim_suffix(".remap")
				if limpo.get_extension() == "tres":
					caminhos.append(dir_atual.path_join(limpo))
			nome = dir.get_next()
		dir.list_dir_end()

	caminhos.sort()

	var resultado: Array[BibliotecaResource] = []
	for caminho in caminhos:
		var res := load(caminho)
		if res is BibliotecaResource:
			resultado.append(res)
		else:
			push_warning("BibliotecaDB: '%s' não é um BibliotecaResource, ignorado." % caminho)

	return resultado

func _indexar_paginas():
	_mapa_nome_para_pagina.clear()

	var paginas_ativas: Array[BibliotecaResource] = []
	if Constantes.JOGO_EN == 1:
		paginas_ativas = paginas_en
	elif Constantes.JOGO_EN == 0:
		paginas_ativas = paginas_pt

	for pagina in paginas_ativas:
		if pagina and pagina.nome.strip_edges() != "":
			if _mapa_nome_para_pagina.has(pagina.nome):
				push_warning("BibliotecaDB: nome de página duplicado '%s'." % pagina.nome)
			_mapa_nome_para_pagina[pagina.nome] = pagina
		else:
			push_warning("BibliotecaDB: página sem nome foi ignorada na database.")

func get_pagina_por_nome(nome: String) -> BibliotecaResource:
	return _mapa_nome_para_pagina.get(nome, null)
