extends PanelContainer

@onready var code_edit = %CodeEdit
@onready var botao_executar = %BotaoExecutar 
@onready var interpretador = %InterpretadorServico
@onready var viewport = %SubViewport

@onready var seletor_slot = %SeletorSlotCodigo

@export_group("Requisitos dos Slots de Código")
@export var requisito_slot_0: String = ""
@export var requisito_slot_1: String = ""
@export var requisito_slot_2: String = ""
@export var requisito_slot_3: String = ""
@export var requisito_slot_4: String = ""

@export_group("Customização do Botão")
@export var icone_rodar: Texture2D
@export var icone_parar: Texture2D
@export var icone_escapar: Texture2D
@export var tempo_cooldown: float = 1.0

@export_group("Fontes do Terminal")
@export var fontes_disponiveis: Array[Font] = []

@export_group("Animação de Destaque de Código")
@export var cor_destaque_linha: Color = Color(1.0, 1.0, 1.0, 0.4)
@export var tempo_fade_destaque: float = 0.35
@export_subgroup("Filtros de Destaque")
@export var hl_declaracao_var: bool = true # Ex: int a = 0
@export var hl_leitura_var: bool = true # Ex: a + 1
@export var hl_origem_var: bool = true # A linha lá em cima onde a variável 'a' nasceu
@export var hl_atribuicao: bool = true # Ex: a = 2
@export var hl_se_senao: bool = true # Ex: se, senao se, senao
@export var hl_fim_se: bool = true # Ex: fim se
@export var hl_enquanto: bool = true # Ex: enquanto()
@export var hl_fim_enquanto: bool = true # Ex: fim enquanto
@export var hl_chamada_funcao: bool = true # Ex: mover(), getDirecao()
@export var hl_corpo_funcao: bool = true # Ex: A declaração da função lá no topo
@export var hl_fim_funcao: bool = true # Ex: fim funcao
@export var hl_retorna: bool = true # Ex: retorna

var modo_atual: String = "vilarejo"
var codigo_rodando: bool = false
var erros_sintaxe_ativos: Dictionary = {}
var tooltip_erro: Label
var _timer_cooldown: SceneTreeTimer

var _tweens_destaque: Dictionary = {}

var slots_codigo: Array = [
	{"nome": "Código A", "codigo": ""},
	{"nome": "Código B", "codigo": ""},
	{"nome": "Código C", "codigo": ""},
	{"nome": "Código D", "codigo": ""},
	{"nome": "Código E", "codigo": ""}
]

var slot_atual_idx: int = 0

func _ready() -> void:
	add_to_group("Terminal") 
	
	if not botao_executar.pressed.is_connected(_on_botao_executar_pressed):
		botao_executar.pressed.connect(_on_botao_executar_pressed)
	
	botao_executar.focus_mode = Control.FOCUS_NONE
	code_edit.focus_mode = Control.FOCUS_CLICK
	
	configurar_cores_do_codigo()
	aplicar_fonte()
	
	code_edit.code_completion_enabled = true
	code_edit.text_changed.connect(_on_text_changed)
	code_edit.code_completion_requested.connect(_on_code_completion_requested)
	
	_configurar_tooltip_erro()
	atualizar_estado_botao()
	
	if seletor_slot:
		seletor_slot.item_selected.connect(_on_seletor_slot_item_selected)
		
	ProgressoDB.progresso_alterado.connect(_atualizar_seletor_slots)
	_atualizar_seletor_slots()

func aplicar_fonte() -> void:
	var indice = Constantes.FONTE_TERMINAL
	if indice >= 0 and indice < fontes_disponiveis.size():
		var fonte_escolhida = fontes_disponiveis[indice]
		if fonte_escolhida != null:
			code_edit.add_theme_font_override("font", fonte_escolhida)

func _configurar_tooltip_erro() -> void:
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

func atualizar_estado_botao() -> void:
	if modo_atual == "vilarejo" or modo_atual == "tutorial":
		if codigo_rodando:
			botao_executar.text = "PARAR CÓDIGO"
			if icone_parar: botao_executar.icon = icone_parar
		else:
			botao_executar.text = "RODAR CÓDIGO"
			if icone_rodar: botao_executar.icon = icone_rodar
	elif modo_atual == "arena":
		botao_executar.text = "PARAR E ESCAPAR"
		if icone_escapar: botao_executar.icon = icone_escapar

func iniciar_cooldown_seguranca() -> void:
	botao_executar.disabled = true
	
	if _timer_cooldown:
		_timer_cooldown.disconnect("timeout", _liberar_botao)
		
	_timer_cooldown = get_tree().create_timer(tempo_cooldown)
	_timer_cooldown.connect("timeout", _liberar_botao)

func _liberar_botao() -> void:
	botao_executar.disabled = false

func ativar_modo_vilarejo():
	modo_atual = "vilarejo"
	code_edit.editable = not codigo_rodando
	botao_executar.visible = true
	atualizar_estado_botao()
	atualizar_travas_da_interface()
	iniciar_cooldown_seguranca()

func ativar_modo_arena():
	modo_atual = "arena"
	code_edit.editable = false 
	botao_executar.visible = true
	atualizar_estado_botao()
	atualizar_travas_da_interface()
	code_edit.release_focus() 
	iniciar_cooldown_seguranca()

func desativar_botao_executar():
	botao_executar.disabled = true 

func abortar_arena():
	if interpretador.has_method("PararExecucao"):
		interpretador.PararExecucao()
			
	codigo_rodando = false
	limpar_erros_de_sintaxe() 
		
	botao_executar.disabled = true 
	ativar_modo_vilarejo()
		
	if FuncoesNativas.has_method("escapar"):
		FuncoesNativas.escapar()

func _on_botao_executar_pressed() -> void:
	if botao_executar.disabled: return 

	if (modo_atual == "vilarejo" or modo_atual == "tutorial") and not codigo_rodando:
		var codigo_digitado = code_edit.text
		if codigo_digitado.strip_edges() == "": return
		
		var erro_bloqueio = validar_codigo_bloqueado(codigo_digitado)
		if erro_bloqueio != "":
			mostrar_erro_runtime(erro_bloqueio)
			return
		
		codigo_rodando = true
		code_edit.editable = false
		atualizar_estado_botao()
		atualizar_travas_da_interface()
		interpretador.ExecutarCodigoDoJogador(codigo_digitado, self)
		iniciar_cooldown_seguranca()

	elif modo_atual == "vilarejo" and codigo_rodando:
		if interpretador.has_method("PararExecucao"):
			interpretador.PararExecucao()
			
		codigo_rodando = false
		code_edit.editable = true
		atualizar_estado_botao()
		atualizar_travas_da_interface()
		iniciar_cooldown_seguranca()

	elif modo_atual == "tutorial" and codigo_rodando:
		abortar_tutorial()

	elif modo_atual == "arena":
		abortar_arena()

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
	
	codigo_rodando = false
	code_edit.editable = true
	atualizar_travas_da_interface()
	if modo_atual == "vilarejo":
		botao_executar.text = "Existem Erros!"
	iniciar_cooldown_seguranca()

func limpar_erros_de_sintaxe():
	if erros_sintaxe_ativos.is_empty(): return
	erros_sintaxe_ativos.clear()
	for i in range(code_edit.get_line_count()):
		code_edit.set_line_background_color(i, Color(0, 0, 0, 0))
	tooltip_erro.visible = false
	atualizar_estado_botao()

func mostrar_erro_runtime(mensagem: String):
	codigo_rodando = false
	code_edit.editable = (modo_atual == "vilarejo")
	atualizar_estado_botao()
	atualizar_travas_da_interface()
	iniciar_cooldown_seguranca()
	
	var dialog = AcceptDialog.new()
	dialog.title = "Erro Fatal da Engine!"
	dialog.dialog_text = "Algo inesperado quebrou a conexão:\n\n" + mensagem
	add_child(dialog)
	dialog.popup_centered()

func configurar_cores_do_codigo() -> void:
	var highlighter = CodeHighlighter.new()
	highlighter.number_color = Color("#b5cea8") 
	highlighter.symbol_color = Color("#d4d4d4") 
	highlighter.function_color = Color("#dcdcaa") 
	highlighter.member_variable_color = Color("#9cdcfe")
	
	highlighter.add_color_region('"', '"', Color("#ce9178"), false) 
	highlighter.add_color_region('#', '', Color("#6a9955"), true)   
	
	var cor_controle = Color("#c586c0")
	var palavras_controle = ["se", "senao", "fim", "enquanto", "retorna", "funcao"]
	for palavra in palavras_controle: highlighter.add_keyword_color(palavra, cor_controle)
		
	var cor_tipo = Color("#569cd6")
	var palavras_tipo = ["int", "float", "bool", "string", "vazio", "Verdadeiro", "Falso", "Inimigo", "Arena", "Ataque", "Direcao", "cinto", "mochila"]
	for palavra in palavras_tipo: highlighter.add_keyword_color(palavra, cor_tipo)
	
	var cor_constante = Color("#4ec9b0") 
	var constantes_jogo = ["Cima", "Baixo", "Direita", "Esquerda", "EsferaAzul", "EsferaVermelha", "Raio", "Gelo", "Fogo", "ExplosaoFogo", "ExplosaoGelo", "Alho", "Moeda", "Osso", "Couro", "Magma", "Cristal", "Plasma", "Sangue", "Safira", "Esmeralda", "Diamante", "Goblin", "Esqueleto", "SlimeDeFogo", "SlimeDeGelo", "Lobisomem", "Orc", "Fantasma", "Vampiro", "Campos", "Floresta", "Labirinto"]
	for constante in constantes_jogo: highlighter.add_keyword_color(constante, cor_constante)
		
	var cor_funcao = Color("#dcdcaa")
	var funcoes_nativas = ["mover", "atacar", "inimigoMaisProximo", "podeMover", "getTempo", "getVidaAtual", "escapar", "escanearArea", "posicaoX", "posicaoY", "tesouroX", "tesouroY", "arena", "comprar", "min", "max", "tamanho", "trunca", "aleatorio", "escreva"]
	for func_nativa in funcoes_nativas: highlighter.add_keyword_color(func_nativa, cor_funcao)

	var funcoes_membro = ["usarItem", "colocarItem"]
	for func_membro in funcoes_membro: 
		highlighter.add_member_keyword_color(func_membro, cor_funcao)

	code_edit.syntax_highlighter = highlighter

func _on_text_changed() -> void:
	slots_codigo[slot_atual_idx]["codigo"] = code_edit.text
	
	code_edit.request_code_completion(true)

func _on_code_completion_requested() -> void:
	var current_line = code_edit.get_caret_line()
	var current_col = code_edit.get_caret_column()
	var line_text = code_edit.get_line(current_line).substr(0, current_col)

	var texto_limpo = line_text.strip_edges()
	if texto_limpo.ends_with("fim enquanto") or texto_limpo.ends_with("fim se") or texto_limpo.ends_with("fim funcao"):
		code_edit.cancel_code_completion()
		return

	var regex = RegEx.new()
	regex.compile("[a-zA-Z0-9_\\.]+$") 
	var match = regex.search(line_text)

	if not match:
		code_edit.cancel_code_completion()
		return

	var prefixo_digitado = match.get_string()
	var sugestoes_encontradas = 0

	for termo in AutocompleteDB.termos.keys():
		var dados = AutocompleteDB.termos[termo]
		var requisito = dados[1] 
		
		if not ProgressoDB.tem_desbloqueado(requisito):
			continue
			
		var match_encontrado = false
		var texto_insercao = termo
		
		if prefixo_digitado.contains("."):
			var partes = prefixo_digitado.rsplit(".", true, 1)
			var sufixo = partes[1]
			
			if termo.begins_with("."):
				if termo.to_lower().begins_with("." + sufixo.to_lower()) and "." + sufixo != termo:
					match_encontrado = true
					texto_insercao = termo.substr(1) 
					
			elif termo.to_lower().begins_with(prefixo_digitado.to_lower()) and prefixo_digitado != termo:
				match_encontrado = true
				var termo_partes = termo.rsplit(".", true, 1)
				if termo_partes.size() > 1:
					texto_insercao = termo_partes[1] 

		else:
			if termo.to_lower().begins_with(prefixo_digitado.to_lower()) and termo != prefixo_digitado:
				if not termo.begins_with("."):
					match_encontrado = true

		if match_encontrado:
			var tipo_icone = CodeEdit.KIND_PLAIN_TEXT
			if termo.contains("()"): tipo_icone = CodeEdit.KIND_FUNCTION
			
			code_edit.add_code_completion_option(tipo_icone, termo, texto_insercao)
			sugestoes_encontradas += 1
			
		if sugestoes_encontradas >= 5: break

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
			var recuo = AutocompleteDB.termos[termo][0]
			if recuo > 0: code_edit.set_caret_column(col - recuo)
			break
			
func validar_codigo_bloqueado(codigo: String) -> String:
	for termo in AutocompleteDB.termos.keys():
		var requisito = AutocompleteDB.termos[termo][1]
		if not ProgressoDB.tem_desbloqueado(requisito):
			var termo_limpo = termo.replace("():", "").replace("()", "").replace(":", "").strip_edges()
			var regex = RegEx.new()
			regex.compile("\\b" + termo_limpo.replace(".", "\\.") + "\\b")
			if regex.search(codigo):
				return "Acesso Negado!\nDesbloqueie o conhecimento '" + requisito + "' na Árvore de Habilidades para usar o comando: " + termo_limpo
	return ""

func _atualizar_seletor_slots() -> void:
	if not seletor_slot: return
	
	var qtd_desbloqueada = 0
	
	var requisitos = [
		requisito_slot_0, 
		requisito_slot_1, 
		requisito_slot_2, 
		requisito_slot_3, 
		requisito_slot_4
	]
	
	for i in range(5):
		var req = requisitos[i]
		
		if ProgressoDB.tem_desbloqueado(req):
			qtd_desbloqueada += 1
		else:
			break 
			
	if qtd_desbloqueada == 0:
		qtd_desbloqueada = 1
	
	seletor_slot.visible = (qtd_desbloqueada > 1)
	
	seletor_slot.clear()
	for i in range(qtd_desbloqueada):
		seletor_slot.add_item(slots_codigo[i]["nome"], i)

	if slot_atual_idx >= qtd_desbloqueada:
		_on_seletor_slot_item_selected(0)
	else:
		seletor_slot.select(slot_atual_idx)

func _on_seletor_slot_item_selected(index: int) -> void:
	slots_codigo[slot_atual_idx]["codigo"] = code_edit.text
	
	slot_atual_idx = index
	
	code_edit.text = slots_codigo[slot_atual_idx]["codigo"]
	
	limpar_erros_de_sintaxe()
	
func atualizar_travas_da_interface() -> void:
	if seletor_slot:
		var pode_editar = (modo_atual == "vilarejo") and not codigo_rodando
		seletor_slot.disabled = not pode_editar
	
func definir_codigo_slot(indice: int, codigo: String) -> void:
	if indice < 0 or indice >= slots_codigo.size():
		return
		
	slots_codigo[indice]["codigo"] = codigo
	
	if indice == slot_atual_idx:
		code_edit.text = codigo
		limpar_erros_de_sintaxe()

func get_codigo_slot(indice: int) -> String:
	if indice < 0 or indice >= slots_codigo.size():
		return ""
		
	return slots_codigo[indice]["codigo"]

func destacar_linha_execucao(linha_raw: int, categoria: String = "") -> void:
	match categoria:
		"declaracao_var": if not hl_declaracao_var: return
		"leitura_var": if not hl_leitura_var: return
		"origem_var": if not hl_origem_var: return
		"atribuicao": if not hl_atribuicao: return
		"se_senao": if not hl_se_senao: return
		"fim_se": if not hl_fim_se: return
		"enquanto": if not hl_enquanto: return
		"fim_enquanto": if not hl_fim_enquanto: return
		"chamada_funcao": if not hl_chamada_funcao: return
		"corpo_funcao": if not hl_corpo_funcao: return
		"fim_funcao": if not hl_fim_funcao: return
		"retorna": if not hl_retorna: return
		
	var linha = linha_raw - 1 
	
	if _tweens_destaque.has(linha) and _tweens_destaque[linha] and _tweens_destaque[linha].is_valid():
		_tweens_destaque[linha].kill()
		
	var tween = create_tween()
	_tweens_destaque[linha] = tween
	
	var cor_transparente = Color(cor_destaque_linha.r, cor_destaque_linha.g, cor_destaque_linha.b, 0.0)
	
	tween.tween_method(
		func(cor_atual: Color): code_edit.set_line_background_color(linha, cor_atual),
		cor_destaque_linha, 
		cor_transparente, 
		tempo_fade_destaque
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func(): _tweens_destaque.erase(linha))

func limpar_destaque_execucao() -> void:
	for linha in _tweens_destaque.keys():
		if _tweens_destaque[linha] and _tweens_destaque[linha].is_valid():
			_tweens_destaque[linha].kill()
		code_edit.set_line_background_color(linha, Color(0, 0, 0, 0))
		
	_tweens_destaque.clear()

func ativar_modo_tutorial():
	modo_atual = "tutorial"
	codigo_rodando = false
	code_edit.editable = true 
	botao_executar.visible = true
	atualizar_estado_botao()
	atualizar_travas_da_interface()
	iniciar_cooldown_seguranca()

func abortar_tutorial():
	if interpretador.has_method("PararExecucao"):
		interpretador.PararExecucao()
		
	codigo_rodando = false
	limpar_erros_de_sintaxe() 
	code_edit.editable = true
	
	atualizar_estado_botao()
	atualizar_travas_da_interface()
	iniciar_cooldown_seguranca()
	
	get_tree().call_group("MundoTutorial", "resetar_player")

func limpar_codigo() -> void:
	if code_edit:
		code_edit.text = ""
	limpar_destaque_execucao()
