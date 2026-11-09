class_name AssistenteBlocos
extends RefCounted

## Ajuda o jogador a montar blocos no estilo do Grimório, com cada chave
## na sua própria linha:
##
##     se(condicao)
##     {
##         ...
##     }
##
## As palavras de cada idioma vêm do LinguagemDB (estruturas_bloco / tipos_funcao),
## então funciona igual em português e inglês.

## Analisa uma linha. Se for cabeçalho de bloco, retorna:
##   { "com_condicao": bool, "condicao": String, "abre_parenteses": int }
## Senão, retorna {}.
static func analisar_cabecalho(texto: String) -> Dictionary:
	var perfil = LinguagemDB.perfil()
	var t = _sem_comentario(texto).strip_edges()
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
			}

	# Declaração de função: <tipo> nome(parametros)
	regex.compile("^(" + "|".join(perfil["tipos_funcao"]) + ")\\s+[A-Za-z_][A-Za-z0-9_]*\\s*\\((.*)\\)$")
	if regex.search(t):
		return { "com_condicao": false, "condicao": "", "abre_parenteses": texto.find("(") }

	return {}

## Garante que o cabeçalho na linha `linha` tenha "{", corpo e "}" logo abaixo,
## e posiciona o cursor: nos parênteses se a condição estiver vazia, senão no corpo.
static func expandir_bloco(ce: CodeEdit, linha: int) -> void:
	var texto = ce.get_line(linha)
	var info = analisar_cabecalho(texto)
	if info.is_empty():
		return

	var ind = indentacao(texto)
	var abre = LinguagemDB.perfil()["abre_bloco"]
	var fecha = LinguagemDB.perfil()["fecha_bloco"]

	ce.begin_complex_operation()
	var linha_abre = linha + 1
	if linha_abre < ce.get_line_count() and ce.get_line(linha_abre).strip_edges() == abre:
		# A chave de abertura já existe: garante o corpo (e o fechamento, se faltar).
		var linha_corpo = linha_abre + 1
		var sem_corpo = linha_corpo >= ce.get_line_count() or ce.get_line(linha_corpo).strip_edges() == fecha
		if sem_corpo:
			var extra = "\n" + ind + "\t"
			if chaves_abertas(ce.text) > 0 and linha_corpo >= ce.get_line_count():
				extra += "\n" + ind + fecha
			ce.insert_text(extra, linha_abre, ce.get_line(linha_abre).length())
	else:
		ce.insert_text("\n" + ind + abre + "\n" + ind + "\t\n" + ind + fecha, linha, texto.length())
	ce.end_complex_operation()

	if info["com_condicao"] and info["condicao"] == "" and info["abre_parenteses"] >= 0:
		_mover_cursor(ce, linha, info["abre_parenteses"] + 1)
	else:
		_ir_para_corpo(ce, linha + 2)

## Trata o Enter. Retorna true se cuidou dele (o chamador deve consumir o evento).
static func ao_pressionar_enter(ce: CodeEdit) -> bool:
	if ce.get_caret_count() > 1 or ce.has_selection():
		return false

	var linha = ce.get_caret_line()
	var coluna = ce.get_caret_column()
	var texto = ce.get_line(linha)
	var antes = texto.substr(0, coluna)
	var depois = texto.substr(coluna)

	# 1) Enter num cabeçalho, no fim da linha ou dentro dos parênteses → bloco + corpo.
	var info = analisar_cabecalho(texto)
	if not info.is_empty() and antes.strip_edges() != "":
		var dentro_parenteses = info["abre_parenteses"] >= 0 and coluna > info["abre_parenteses"] and coluna <= texto.rfind(")")
		if _sem_comentario(depois).strip_edges() == "" or dentro_parenteses:
			# Condição vazia: o cursor fica nos parênteses; senão vai para o corpo.
			expandir_bloco(ce, linha)
			return true

	# 2) Enter numa "{" sozinha sem fechamento → corpo indentado + "}".
	var abre = LinguagemDB.perfil()["abre_bloco"]
	var fecha = LinguagemDB.perfil()["fecha_bloco"]
	if texto.strip_edges() == abre and depois.strip_edges() == "" and chaves_abertas(ce.text) > 0:
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

## Chamado logo depois de o jogador digitar "{". Se a linha for um cabeçalho
## ("se(x) {"), move a chave para a linha de baixo e monta o bloco.
static func ao_digitar_abre_chave(ce: CodeEdit) -> void:
	var abre = LinguagemDB.perfil()["abre_bloco"]
	var linha = ce.get_caret_line()
	var texto = ce.get_line(linha)
	var t = texto.strip_edges()
	if t == abre or not t.ends_with(abre) or ce.get_caret_column() != texto.length():
		return
	var sem_chave = texto.substr(0, texto.rfind(abre)).rstrip(" \t")
	if analisar_cabecalho(sem_chave).is_empty():
		return
	ce.begin_complex_operation()
	ce.set_line(linha, sem_chave)
	ce.end_complex_operation()
	expandir_bloco(ce, linha)

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
