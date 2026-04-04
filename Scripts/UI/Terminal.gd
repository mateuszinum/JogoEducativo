extends PanelContainer

@onready var code_edit = %CodeEdit
@onready var botao_executar = %BotaoExecutar 

@onready var interpretador = %InterpretadorServico
@onready var viewport = %SubViewport

@onready var botao_debug = %BotaoDebug 

var modo_atual: String = "vilarejo"
var erros_sintaxe_ativos: Dictionary = {}

var tooltip_erro: Label

func _ready() -> void:
	add_to_group("Terminal") 
	
	if not botao_executar.pressed.is_connected(_on_botao_executar_pressed):
		botao_executar.pressed.connect(_on_botao_executar_pressed)
		
	if botao_debug:
		botao_debug.visible = Constantes.MODO_DEV
		if Constantes.MODO_DEV and not botao_debug.pressed.is_connected(_on_botao_debug_pressed):
			botao_debug.pressed.connect(_on_botao_debug_pressed)
			botao_debug.focus_mode = Control.FOCUS_NONE
	
	botao_executar.focus_mode = Control.FOCUS_NONE
	code_edit.focus_mode = Control.FOCUS_CLICK
	configurar_cores_do_codigo()
	
	code_edit.code_completion_enabled = true
	code_edit.text_changed.connect(_on_text_changed)
	code_edit.code_completion_requested.connect(_on_code_completion_requested)
	
	tooltip_erro = Label.new()
	
	tooltip_erro.autowrap_mode = TextServer.AUTOWRAP_WORD
	tooltip_erro.custom_minimum_size = Vector2(280, 0)
	tooltip_erro.add_theme_font_size_override("font_size", 13)
	
	var estilo = StyleBoxFlat.new()
	estilo.bg_color = Color(0.12, 0.1, 0.1, 0.98) 
	estilo.border_color = Color(0.8, 0.2, 0.2, 0.9) 
	estilo.set_border_width_all(2)
	estilo.corner_radius_top_left = 6
	estilo.corner_radius_top_right = 6
	estilo.corner_radius_bottom_left = 6
	estilo.corner_radius_bottom_right = 6
	estilo.content_margin_left = 12
	estilo.content_margin_right = 12
	estilo.content_margin_top = 8
	estilo.content_margin_bottom = 8
	
	tooltip_erro.add_theme_stylebox_override("normal", estilo)
	
	tooltip_erro.top_level = true 
	tooltip_erro.z_index = 100 
	tooltip_erro.visible = false
	
	code_edit.add_child(tooltip_erro)
	
	code_edit.gui_input.connect(_on_code_edit_gui_input)
	code_edit.mouse_exited.connect(func(): tooltip_erro.visible = false)
	code_edit.text_changed.connect(limpar_erros_de_sintaxe)


func _on_code_edit_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var pos_texto = code_edit.get_line_column_at_pos(Vector2i(event.position))
		var linha_hover = pos_texto.y
		
		if erros_sintaxe_ativos.has(linha_hover):
			tooltip_erro.text = "⚠️ " + erros_sintaxe_ativos[linha_hover]
			tooltip_erro.visible = true
			tooltip_erro.global_position = code_edit.get_global_mouse_position() + Vector2(15, 15)
		else:
			tooltip_erro.visible = false


func mostrar_erros_de_sintaxe(lista_erros: Array):
	limpar_erros_de_sintaxe()
	for erro in lista_erros:
		var linha = erro["linha"]
		var msg = erro["mensagem"]
		erros_sintaxe_ativos[linha] = msg
		code_edit.set_line_background_color(linha, Color(0.8, 0.1, 0.1, 0.3))
	
	if modo_atual == "vilarejo":
		botao_executar.text = "Existem Erros!"


func limpar_erros_de_sintaxe():
	if erros_sintaxe_ativos.is_empty(): return
	erros_sintaxe_ativos.clear()
	for i in range(code_edit.get_line_count()):
		code_edit.set_line_background_color(i, Color(0, 0, 0, 0))
	tooltip_erro.visible = false
	if modo_atual == "vilarejo":
		botao_executar.text = "Rodar Código"


func mostrar_erro_runtime(mensagem: String):
	var dialog = AcceptDialog.new()
	dialog.title = "Erro Fatal da Engine!"
	dialog.dialog_text = "Algo inesperado quebrou a conexão:\n\n" + mensagem
	add_child(dialog)
	dialog.popup_centered()
	if modo_atual == "vilarejo": botao_executar.text = "Rodar Código"
	else: botao_executar.text = "Parar e Escapar"


func configurar_cores_do_codigo() -> void:
	var highlighter = CodeHighlighter.new()
	highlighter.number_color = Color("#b5cea8") 
	highlighter.symbol_color = Color("#d4d4d4") 
	highlighter.function_color = Color("#dcdcaa") 
	
	highlighter.member_variable_color = Color("#9cdcfe")
	
	highlighter.add_color_region('"', '"', Color("#ce9178"), false) 
	highlighter.add_color_region('#', '', Color("#6a9955"), true)   
	
	var cor_controle = Color("#c586c0")
	var palavras_controle = ["se", "senao", "fim", "enquanto"]
	for palavra in palavras_controle: highlighter.add_keyword_color(palavra, cor_controle)
		
	var cor_tipo = Color("#569cd6")
	var palavras_tipo = ["int", "float", "bool", "string", "Verdadeiro", "Falso", "Inimigo", "Arena", "Ataque", "Direcao", "cinto", "mochila"]
	for palavra in palavras_tipo: highlighter.add_keyword_color(palavra, cor_tipo)
	
	var cor_constante = Color("#4ec9b0") 
	var constantes_jogo = [
		"Cima", "Baixo", "Direita", "Esquerda",
		"EsferaAzul", "EsferaVermelha", "Agua", "Gelo", "Fogo", "ExplosaoFogo", "ExplosaoGelo", "Alho",
		"Moeda", "Osso", "Couro", "Magma", "Cristal", "Plasma", "Sangue", "Safira", "Esmeralda", "Diamante",
		"Goblin", "Esqueleto", "SlimeDeFogo", "SlimeDeGelo", "Lobisomem", "Orc", "Fantasma", "Vampiro",
		"Campos", "Floresta", "Labirinto",
	]
	for constante in constantes_jogo: highlighter.add_keyword_color(constante, cor_constante)
		
	var cor_funcao = Color("#dcdcaa")
	var funcoes_nativas = [
		"mover", "atacar", "inimigoMaisProximo", "podeMover", 
		"getTempo", "getVidaAtual", "escapar", "escanearArea",
		"posicaoX", "posicaoY", "tesouroX", "tesouroY", "arena", "comprar"
	]
	for func_nativa in funcoes_nativas: highlighter.add_keyword_color(func_nativa, cor_funcao)
	
	var funcoes_membro = ["usarItem", "colocarItem"]
	for func_membro in funcoes_membro: 
		highlighter.add_member_keyword_color(func_membro, cor_funcao)
		
	code_edit.syntax_highlighter = highlighter


func ativar_modo_vilarejo():
	modo_atual = "vilarejo"
	code_edit.editable = true
	botao_executar.visible = true
	botao_executar.text = "Rodar Código"


func ativar_modo_arena():
	modo_atual = "arena"
	code_edit.editable = false 
	botao_executar.visible = true
	botao_executar.text = "Parar e Escapar"
	code_edit.release_focus() 


func _on_botao_executar_pressed() -> void:
	if modo_atual == "vilarejo":
		var codigo_digitado = code_edit.text
		if codigo_digitado.strip_edges() == "": return
		interpretador.ExecutarCodigoDoJogador(codigo_digitado, self)
	elif modo_atual == "arena":
		if interpretador.has_method("PararExecucao"):
			interpretador.PararExecucao()
		FuncoesNativas.escapar()


func _on_botao_debug_pressed() -> void:
	var codigo_teste = """arena(Campos)
Direcao dir = Esquerda

enquanto(Verdadeiro):

	se(podeMover(Esquerda) == Falso):
		dir = Direita
	fim se
	se(podeMover(Direita) == Falso):
		dir = Esquerda
	fim se
	mover(dir)
	
	Inimigo alvo = inimigoMaisProximo()
	se(nomeInimigo(alvo) == SlimeDeFogo):
		atacar(alvo, Gelo)
	senao:
		se(nomeInimigo(alvo) == SlimeDeGelo):
			atacar(alvo, Fogo)
		senao:
			atacar(alvo, EsferaAzul)
		fim se
	fim se
	
fim enquanto
"""
	code_edit.text = codigo_teste


func _on_text_changed() -> void:
	code_edit.request_code_completion(true)


func _on_code_completion_requested() -> void:
	var current_line = code_edit.get_caret_line()
	var current_col = code_edit.get_caret_column()
	var line_text = code_edit.get_line(current_line).substr(0, current_col)

	var regex = RegEx.new()
	regex.compile("[a-zA-Z0-9_\\.]+$") 
	var match = regex.search(line_text)

	if not match:
		code_edit.cancel_code_completion()
		return

	var prefixo_digitado = match.get_string()
	var sugestoes_encontradas = 0

	for termo in AutocompleteDB.termos.keys():
		if termo.to_lower().begins_with(prefixo_digitado.to_lower()) and termo != prefixo_digitado:
			var tipo_icone = CodeEdit.KIND_PLAIN_TEXT
			if termo.contains("()"): tipo_icone = CodeEdit.KIND_FUNCTION
			code_edit.add_code_completion_option(tipo_icone, termo, termo)
			sugestoes_encontradas += 1
		if sugestoes_encontradas >= 5: break

	if sugestoes_encontradas > 0: code_edit.update_code_completion_options(true)
	else: code_edit.cancel_code_completion()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_text_completion_accept") or event.is_action_pressed("ui_accept"):
		if code_edit.has_focus():
			call_deferred("_verificar_cursor_pos_autocomplete")


func _verificar_cursor_pos_autocomplete() -> void:
	var linha = code_edit.get_caret_line()
	var col = code_edit.get_caret_column()
	var texto_linha = code_edit.get_line(linha).substr(0, col)
	
	for termo in AutocompleteDB.termos.keys():
		if texto_linha.ends_with(termo):
			var recuo = AutocompleteDB.termos[termo] 
			if recuo > 0: code_edit.set_caret_column(col - recuo)
			break
