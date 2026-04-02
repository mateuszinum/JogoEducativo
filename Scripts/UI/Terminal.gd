extends PanelContainer

@onready var code_edit = %CodeEdit
@onready var botao_executar = %BotaoExecutar 

@onready var interpretador = %InterpretadorServico
@onready var viewport = %SubViewport

var modo_atual: String = "vilarejo"

func _ready() -> void:
	add_to_group("Terminal") 
	
	# ==========================================
	# FIX À PROVA DE BALAS: Força a conexão do botão via código!
	# Isso garante que ele vai funcionar mesmo se o editor bugar.
	# ==========================================
	if not botao_executar.pressed.is_connected(_on_botao_executar_pressed):
		botao_executar.pressed.connect(_on_botao_executar_pressed)
		print("[DEBUG] Botão de Executar foi conectado com sucesso via código.")
	
	botao_executar.focus_mode = Control.FOCUS_NONE
	code_edit.focus_mode = Control.FOCUS_CLICK
	configurar_cores_do_codigo()

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
	var palavras_tipo = ["int", "float", "bool", "string", "Verdadeiro", "Falso"]
	for palavra in palavras_tipo: highlighter.add_keyword_color(palavra, cor_tipo)
		
	var cor_funcao = Color("#dcdcaa")
	var funcoes_nativas = [
		"mover", "atacar", "inimigoMaisProximo", "podeMover", 
		"getTempo", "getVidaAtual", "escapar", "escanearArea",
		"posicaoX", "posicaoY", "tesouroX", "tesouroY", "arena", "comprar"
	]
	for func_nativa in funcoes_nativas: highlighter.add_keyword_color(func_nativa, cor_funcao)
		
	var cor_objeto = Color("#9cdcfe")
	var objetos = ["cinto", "mochila", "usarItem", "colocarItem"]
	for obj in objetos: highlighter.add_keyword_color(obj, cor_objeto)

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
# O BOTÃO COM DEBUG EXTREMO
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
		# ATENÇÃO: Passamos 'self' como personagem só pra preencher espaço. O C# agora usa FuncoesNativas!
		interpretador.ExecutarCodigoDoJogador(codigo_digitado, self)
		print("[DEBUG TERMINAL] 5. Sinal enviado pro C# com sucesso!")
		
	elif modo_atual == "arena":
		print("[DEBUG TERMINAL] 3. Acionando Kill Switch no C#...")
		if interpretador.has_method("PararExecucao"):
			interpretador.PararExecucao()
			
		print("[DEBUG TERMINAL] 4. Escapando da Arena...")
		FuncoesNativas.escapar()
