extends PanelContainer

@onready var code_edit = %CodeEdit
@onready var botao_executar = %BotaoExecutar 

@onready var interpretador = %InterpretadorServico
@onready var viewport = %SubViewport

@onready var botao_debug = %BotaoDebug 

# determina se o botao de inserir código de teste vai aparecer ou não
const MODO_DEBUG_ATIVO = true

var modo_atual: String = "vilarejo"

func _ready() -> void:
	add_to_group("Terminal") 
	
	if not botao_executar.pressed.is_connected(_on_botao_executar_pressed):
		botao_executar.pressed.connect(_on_botao_executar_pressed)
		
	if botao_debug:
		botao_debug.visible = MODO_DEBUG_ATIVO
		if MODO_DEBUG_ATIVO and not botao_debug.pressed.is_connected(_on_botao_debug_pressed):
			botao_debug.pressed.connect(_on_botao_debug_pressed)
			botao_debug.focus_mode = Control.FOCUS_NONE
	
	botao_executar.focus_mode = Control.FOCUS_NONE
	code_edit.focus_mode = Control.FOCUS_CLICK
	configurar_cores_do_codigo()
	
	# ==========================================
	# ATIVAÇÃO DO AUTOCOMPLETE "LIVE"
	# ==========================================
	code_edit.code_completion_enabled = true
	
	# Avisa o Godot para disparar a checagem toda vez que você apertar qualquer tecla
	code_edit.text_changed.connect(_on_text_changed)
	code_edit.code_completion_requested.connect(_on_code_completion_requested)

# ==========================================
# FEEDBACK DE ERRO VISUAL (O Popup)
# ==========================================
func mostrar_erro(mensagem: String):
	print("[DEBUG TERMINAL] Mostrando popup de erro para o jogador.")
	var dialog = AcceptDialog.new()
	dialog.title = "Erro de Sintaxe!"
	dialog.dialog_text = "O Interpretador encontrou um problema no seu código:\n\n" + mensagem
	add_child(dialog)
	dialog.popup_centered()
	
	if modo_atual == "vilarejo":
		botao_executar.text = "Rodar Código"
	else:
		botao_executar.text = "Parar e Escapar"

func configurar_cores_do_codigo() -> void:
	var highlighter = CodeHighlighter.new()
	highlighter.number_color = Color("#b5cea8") 
	highlighter.symbol_color = Color("#d4d4d4") 
	highlighter.function_color = Color("#dcdcaa") 
	highlighter.add_color_region('"', '"', Color("#ce9178"), false) 
	highlighter.add_color_region('#', '', Color("#6a9955"), true)   
	
	var cor_controle = Color("#c586c0")
	var palavras_controle = ["se", "senao", "fim", "enquanto"]
	for palavra in palavras_controle: highlighter.add_keyword_color(palavra, cor_controle)
		
	var cor_tipo = Color("#569cd6")
	var palavras_tipo = ["int", "float", "bool", "string", "Verdadeiro", "Falso", "Inimigo", "Arena", "Ataque", "Direcao"]
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
		"posicaoX", "posicaoY", "tesouroX", "tesouroY", "arena", "comprar",
		"cinto", "mochila", "usarItem", "colocarItem"
	]
	for func_nativa in funcoes_nativas: highlighter.add_keyword_color(func_nativa, cor_funcao)
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

# ==========================================
# O BOTÃO DE EXECUTAR / ESCAPAR
# ==========================================
func _on_botao_executar_pressed() -> void:
	print("\n--- INICIANDO FLUXO DE EXECUÇÃO ---")
	print("[DEBUG TERMINAL] 1. Clique detectado no botão!")
	print("[DEBUG TERMINAL] 2. Modo atual é: ", modo_atual)

	if modo_atual == "vilarejo":
		var codigo_digitado = code_edit.text
		print("[DEBUG TERMINAL] 3. Lendo código:\n", codigo_digitado)
		
		if codigo_digitado.strip_edges() == "":
			print("[DEBUG TERMINAL] ERRO: Código está vazio. Cancelando.")
			return
			
		print("[DEBUG TERMINAL] 4. Enviando código para o C#...")
		interpretador.ExecutarCodigoDoJogador(codigo_digitado, self)
		print("[DEBUG TERMINAL] 5. Sinal enviado pro C# com sucesso!")
		
	elif modo_atual == "arena":
		print("[DEBUG TERMINAL] 3. Acionando Kill Switch no C#...")
		if interpretador.has_method("PararExecucao"):
			interpretador.PararExecucao()
			
		print("[DEBUG TERMINAL] 4. Escapando da Arena...")
		FuncoesNativas.escapar()
		
# ==========================================
# FERRAMENTA DE DEBUG - INJEÇÃO DE CÓDIGO
# ==========================================
func _on_botao_debug_pressed() -> void:
	var codigo_teste = """arena(Floresta)
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
	se(nomeInimigo(alvo) == Goblin):
		atacar(alvo, Fogo)
	senao:
		atacar(alvo, Gelo)
	fim se

fim enquanto
"""
	code_edit.text = codigo_teste
	print("[DEBUG TERMINAL] Código de teste injetado com sucesso!")


# ==========================================
# LÓGICA DO AUTOCOMPLETE LIVE E PARÊNTESES
# ==========================================
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
			if termo.contains("()"):
				tipo_icone = CodeEdit.KIND_FUNCTION
				
			code_edit.add_code_completion_option(tipo_icone, termo, termo)
			sugestoes_encontradas += 1

		if sugestoes_encontradas >= 5:
			break

	if sugestoes_encontradas > 0:
		code_edit.update_code_completion_options(true)
	else:
		code_edit.cancel_code_completion()


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
			
			if recuo > 0:
				code_edit.set_caret_column(col - recuo)
				
			break
