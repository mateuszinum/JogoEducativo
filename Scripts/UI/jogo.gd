extends Control

@onready var viewport = %SubViewport
@onready var terminal = %PainelTerminal
@onready var fade_tv = %FadeTV 
@onready var fade_rect = $FadeLayer/ColorRect 

const CENA_VILAREJO = preload("res://Scenes/UI/village_menu.tscn")
const CENA_ARENA = preload("res://Scenes/World/world.tscn")

var transicao_em_andamento: bool = false 
var codigo_pendente: String = "" # <-- NOVA VARIÁVEL: Guarda o código durante a viagem!

func _ready() -> void:
	limpar_viewport()
	var vilarejo = CENA_VILAREJO.instantiate()
	viewport.add_child(vilarejo)
	if terminal.has_method("ativar_modo_vilarejo"):
		terminal.ativar_modo_vilarejo()
		
	if fade_rect:
		$FadeLayer.show() 
		fade_rect.show()  
		fade_rect.modulate.a = 1.0
		
		var tween = create_tween()
		tween.tween_property(fade_rect, "modulate:a", 0.0, 1.5) 
		await tween.finished
		$FadeLayer.hide()

func fazer_transicao_tv(cena_preload, modo_terminal: String) -> void:
	if transicao_em_andamento: return
	transicao_em_andamento = true
	
	fade_tv.show()
	fade_tv.modulate.a = 0.0
	var tween_out = create_tween()
	tween_out.tween_property(fade_tv, "modulate:a", 1.0, 1.0) 
	
	if viewport.get_child_count() > 0:
		var cena_atual = viewport.get_child(0)
		if cena_atual.has_node("MusicaVilarejo"):
			var musica = cena_atual.get_node("MusicaVilarejo")
			var tween_som = create_tween()
			# Mudei de -40.0 para -80.0 para garantir o silêncio total!
			tween_som.tween_property(musica, "volume_db", -80.0, 1.0) 
			
	await tween_out.finished
	
	limpar_viewport()
	if cena_preload:
		var nova_cena = cena_preload.instantiate()
		viewport.add_child(nova_cena)
		
	if modo_terminal == "vilarejo" and terminal.has_method("ativar_modo_vilarejo"):
		terminal.ativar_modo_vilarejo()
	elif modo_terminal == "arena" and terminal.has_method("ativar_modo_arena"):
		terminal.ativar_modo_arena()
		
	var tween_in = create_tween()
	tween_in.tween_property(fade_tv, "modulate:a", 0.0, 1.0)
	await tween_in.finished
	
	fade_tv.hide()
	transicao_em_andamento = false
	
	# --- NOVO: O GATILHO DE EXECUÇÃO DO C# ---
	# Se a tela acabou de clarear na Arena e temos um código guardado...
	if codigo_pendente != "" and modo_terminal == "arena":
		var cena_atual = viewport.get_child(0)
		# Procura o boneco na Arena (certifique-se que o nome do nó é 'Player')
		var personagem = cena_atual.find_child("Player", true, false)
		
		if personagem:
			# Dispara o C# mandando o texto e o boneco!
			%InterpretadorServico.ExecutarCodigoDoJogador(codigo_pendente, personagem)
		else:
			print("Erro: A arena carregou, mas o nó 'Player' não foi encontrado!")
			
		codigo_pendente = "" # Limpa a memória para a próxima partida

func ir_para_vilarejo() -> void:
	fazer_transicao_tv(CENA_VILAREJO, "vilarejo")

func ir_para_arena() -> void:
	fazer_transicao_tv(CENA_ARENA, "arena")

func limpar_viewport() -> void:
	if viewport:
		for child in viewport.get_children():
			viewport.remove_child(child) 
			child.queue_free()

# --- NOVA FUNÇÃO DO BOTÃO ---
func _on_botao_executar_pressed() -> void:
	# Acessa as variáveis que já existem no seu script Terminal.gd
	if terminal.modo_atual == "vilarejo":
		var codigo_digitado = terminal.code_edit.text
		
		if codigo_digitado.strip_edges() == "":
			print("Erro: O código está vazio! Escreva um comando primeiro.")
			return
			
		print("Guardando o código e viajando para a Arena...")
		codigo_pendente = codigo_digitado
		ir_para_arena() # Escurece a tela e começa a viagem
		
	elif terminal.modo_atual == "arena":
		print("Parando execução e voltando ao Vilarejo...")
		# Futuramente podemos colocar aqui um comando para "matar" o C# caso ele esteja em loop
		ir_para_vilarejo()
