extends PanelContainer

@onready var code_edit = %CodeEdit
@onready var botao_executar = %BotaoExecutar 

# Acedemos aos nós únicos da cena principal (jogo.tscn)
@onready var interpretador = %InterpretadorServico
@onready var viewport = %SubViewport

var modo_atual: String = "vilarejo"

func _ready() -> void:
	botao_executar.focus_mode = Control.FOCUS_NONE
	code_edit.focus_mode = Control.FOCUS_CLICK

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

func _on_botao_executar_pressed() -> void:
	if modo_atual == "vilarejo":
		var codigo_digitado = code_edit.text
		
		# Evita enviar texto vazio para o interpretador
		if codigo_digitado.strip_edges() == "":
			print("Erro: O código está vazio! Escreva um comando primeiro.")
			return
			
		# 1. Procura o personagem dentro da cena que está na "TV" (Viewport)
		var personagem = null
		if viewport.get_child_count() > 0:
			var cena_atual = viewport.get_child(0)
			# ATENÇÃO: Confirme se o nó do seu personagem se chama "Player" na sua cena de Arena
			personagem = cena_atual.get_node_or_null("Player") 
			
		# 2. Se o personagem existir, envia a ordem para o C#
		if personagem:
			print("Enviando código para o C#...")
			interpretador.ExecutarCodigoDoJogador(codigo_digitado, personagem)
		else:
			print("Aviso: Nenhum personagem 'Player' encontrado na tela.")
			
	elif modo_atual == "arena":
		# 1. (Futuro) Aqui poderá adicionar um comando para parar a execução do C# se ele estiver a correr um loop
		
		# 2. Interrompe o jogo e regressa ao vilarejo usando a função que já temos no jogo.gd
		var main_scene = get_node_or_null("/root/Jogo")
		if main_scene and main_scene.has_method("ir_para_vilarejo"):
			main_scene.ir_para_vilarejo()
