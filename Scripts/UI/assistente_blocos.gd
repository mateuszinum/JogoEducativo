class_name AssistenteBlocos
extends RefCounted

## Ajuda o jogador a montar blocos no estilo do editor do Grimório:
## a chave de abertura fica na linha do termo e a de fechamento sozinha no fim.
##
##     se(condicao) {
##         ...
##     }
##
## As palavras de cada idioma vêm do LinguagemDB (estruturas_bloco / tipos_funcao),
## então funciona igual em português e inglês.

## Analisa uma linha. Se for cabeçalho de bloco ("se(x)", "se(x) {", "senao", "vazio f()"...), retorna:
##   { "com_condicao": bool, "condicao": String, "abre_parenteses": int, "tem_chave": bool }
## Senão, retorna {}.
static func analisar_cabecalho(texto: String) -> Dictionary:
	var perfil = LinguagemDB.perfil()
	var abre: String = perfil["abre_bloco"]
	var t = _sem_comentario(texto).strip_edges()
	var tem_chave = t.ends_with(abre)
	if tem_chave:
		t = t.substr(0, t.length() - abre.length()).strip_edges()
	if t == "":
		return {}

	var regex = RegEx.new()
	for estrutura in perfil["estruturas_bloco"]:
		var com_condicao: bool = perfil["estruturas_bloco"][estrutura]
		var palavra = estrutura.replace(" ", "\\s+")
		if com_condicao:
			regex.compile("^" + palavra + "\\s*\\((.*)\\)$")
		else:
			regex.compile("^" + palavra + "$")
		var m = regex.search(t)
		if m:
			return {
				"com_condicao": com_condicao,
				"condicao": m.get_string(1).strip_edges() if com_condicao else "",
				"abre_parenteses": texto.find("("),
				"tem_chave": tem_chave,
			}

	# Declaração de função: <tipo> nome(parametros)
	regex.compile("^(" + "|".join(perfil["tipos_funcao"]) + ")\\s+[A-Za-z_][A-Za-z0-9_]*\\s*\\((.*)\\)$")
	if regex.search(t):
		return { "com_condicao": false, "condicao": "", "abre_parenteses": texto.find("("), "tem_chave": tem_chave }

	return {}

## Garante que o cabeçalho na linha `linha` termine com " {" e tenha corpo e "}" abaixo.
## Cursor: nos parênteses se a condição estiver vazia, senão no corpo.
static func expandir_bloco(ce: CodeEdit, linha: int) -> void:
	var texto = ce.get_line(linha)
	var info = analisar_cabecalho(texto)
	if info.is_empty():
		return

	var ind = indentacao(texto)
	var abre = LinguagemDB.perfil()["abre_bloco"]
	var fecha = LinguagemDB.perfil()["fecha_bloco"]
	var proxima = ce.get_line(linha + 1).strip_edges() if linha + 1 < ce.get_line_count() else ""
	var linha_corpo = linha + 1

	ce.begin_complex_operation()
	if info["tem_chave"]:
		if proxima == fecha:
			# Bloco existe mas está vazio: cria a linha do corpo.
			ce.insert_text("\n" + ind + "\t", linha, texto.length())
		elif chaves_abertas(ce.text) > 0:
			# Chave aberta sem fechamento: cria corpo e "}".
			ce.insert_text("\n" + ind + "\t\n" + ind + fecha, linha, texto.length())
	elif proxima == abre:
		# Código antigo com "{" na linha de baixo: respeita e só garante o corpo.
		linha_corpo = linha + 2
		var depois_abre = ce.get_line(linha + 2).strip_edges() if linha + 2 < ce.get_line_count() else ""
		if linha + 2 >= ce.get_line_count() or depois_abre == fecha:
			var extra = "\n" + ind + "\t"
			if chaves_abertas(ce.text) > 0 and linha + 2 >= ce.get_line_count():
				extra += "\n" + ind + fecha
			ce.insert_text(extra, linha + 1, ce.get_line(linha + 1).length())
	else:
		var base = texto.rstrip(" \t")
		ce.set_line(linha, base + " " + abre)
		ce.insert_text("\n" + ind + "\t\n" + ind + fecha, linha, ce.get_line(linha).length())
	ce.end_complex_operation()

	if info["com_condicao"] and info["condicao"] == "" and info["abre_parenteses"] >= 0:
		_mover_cursor(ce, linha, info["abre_parenteses"] + 1)
	else:
		_ir_para_corpo(ce, linha_corpo)

## Trata o Enter. Retorna true se cuidou dele (o chamador deve consumir o evento).
static func ao_pressionar_enter(ce: CodeEdit) -> bool:
	if ce.get_caret_count() > 1 or ce.has_selection():
		return false

	var linha = ce.get_caret_line()
	var coluna = ce.get_caret_column()
	var texto = ce.get_line(linha)
	var antes = texto.substr(0, coluna)
	var depois = _sem_comentario(texto.substr(coluna)).strip_edges()
	var abre = LinguagemDB.perfil()["abre_bloco"]
	var fecha = LinguagemDB.perfil()["fecha_bloco"]

	# 1) Enter num cabeçalho (fim da linha, antes do "{" ou dentro dos parênteses).
	var info = analisar_cabecalho(texto)
	if not info.is_empty() and antes.strip_edges() != "":
		var dentro_parenteses = info["abre_parenteses"] >= 0 and coluna > info["abre_parenteses"] and coluna <= texto.rfind(")")
		var condicao_vazia = info["com_condicao"] and info["condicao"] == ""
		if depois == "" and info["tem_chave"] and chaves_abertas(ce.text) <= 0 and not condicao_vazia:
			return false # bloco já fechado: quebra de linha normal (o Terminal indenta)
		if depois == "" or depois == abre or dentro_parenteses:
			expandir_bloco(ce, linha)
			return true

	# 2) Enter numa "{" sozinha sem fechamento → corpo indentado + "}".
	if texto.strip_edges() == abre and depois == "" and chaves_abertas(ce.text) > 0:
		var ind = indentacao(texto)
		var proxima = ce.get_line(linha + 1).strip_edges() if linha + 1 < ce.get_line_count() else ""
		ce.begin_complex_operation()
		if proxima == fecha:
			ce.insert_text("\n" + ind + "\t", linha, texto.length())
		else:
			ce.insert_text("\n" + ind + "\t\n" + ind + fecha, linha, texto.length())
		ce.end_complex_operation()
		_ir_para_corpo(ce, linha + 1)
		return true

	return false

## Quantas chaves estão abertas sem fechamento no texto (ignora strings e comentários).
static func chaves_abertas(texto: String) -> int:
	var abre = LinguagemDB.perfil()["abre_bloco"]
	var fecha = LinguagemDB.perfil()["fecha_bloco"]
	var saldo = 0
	for l in texto.split("\n"):
		var em_string = false
		for ch in l:
			if ch == "\"":
				em_string = not em_string
			elif not em_string:
				if ch == "#":
					break
				if ch == abre:
					saldo += 1
				elif ch == fecha:
					saldo -= 1
	return saldo

static func indentacao(texto: String) -> String:
	var ind = ""
	for ch in texto:
		if ch == "\t" or ch == " ":
			ind += ch
		else:
			break
	return ind

static func _sem_comentario(texto: String) -> String:
	var em_string = false
	for i in texto.length():
		var ch = texto[i]
		if ch == "\"":
			em_string = not em_string
		elif ch == "#" and not em_string:
			return texto.substr(0, i)
	return texto

static func _ir_para_corpo(ce: CodeEdit, linha: int) -> void:
	if linha >= ce.get_line_count():
		return
	_mover_cursor(ce, linha, ce.get_line(linha).length())

static func _mover_cursor(ce: CodeEdit, linha: int, coluna: int) -> void:
	ce.set_caret_line(linha)
	ce.set_caret_column(coluna)
