extends PanelContainer



@onready var code_edit = %CodeEdit
@onready var botao_executar = %BotaoExecutar 
@onready var player = get_tree().get_first_node_in_group("Player")

@onready var botao_cabecalho = %BotaoCabecalho
@onready var conteudo_terminal = %ConteudoTerminal
# Variável que controla se o código está rodando no momento
var rodando: bool = false 

func _ready() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("abrir_terminal"):
		visible = !visible
		if visible:
			code_edit.grab_focus()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Esta é a função conectada ao sinal "pressed" do botão
func _on_button_pressed() -> void:
	if rodando:
		# Se já está rodando, o botão serve para parar
		parar_codigo()
	else:
		# Se está parado, o botão serve para iniciar
		iniciar_codigo()

func iniciar_codigo() -> void:
	rodando = true
	botao_executar.text = "Interromper"
	executar_codigo_em_loop(code_edit.text)

func parar_codigo() -> void:
	rodando = false
	botao_executar.text = "Encantar"

func executar_codigo_em_loop(texto: String) -> void:
	var linhas = texto.split("\n")
	
	# O "while rodando" faz o código repetir infinitamente até você mandar parar
	while rodando:
		for linha in linhas:
			# Se você clicou em "Interromper" no meio da execução de uma linha, ele quebra o loop na hora
			if not rodando:
				break 
				
			var comando = linha.strip_edges().replace("()", "")
			
			if comando == "":
				continue
			
			match comando:
				"move_up":
					player.input_dir = Vector2.UP
					player.move()
					await _esperar_movimento()
					
				"move_down":
					player.input_dir = Vector2.DOWN
					player.move()
					await _esperar_movimento()
					
				"move_left":
					player.input_dir = Vector2.LEFT
					player.move()
					await _esperar_movimento()
					
				"move_right":
					player.input_dir = Vector2.RIGHT
					player.move()
					await _esperar_movimento()
					
				"change_weapon":
					player.trocar_arma()
					await get_tree().create_timer(0.2).timeout
					
				"check_health":
					print("Terminal diz - Vida atual: ", player.health)
					await get_tree().create_timer(0.1).timeout # Pequena pausa para não travar
					
				"check_time":
					print("Terminal diz - Tempo checado!")
					await get_tree().create_timer(0.1).timeout
					
				_:
					print("ERRO DE SINTAXE: Comando não reconhecido -> ", comando)
					parar_codigo() # Se achar um erro de sintaxe, para a execução automática
					break
		
		# Segurança extra: se o código digitado estiver vazio, espera um pouquinho antes de tentar ler de novo
		# Isso impede o jogo de travar (crash) num loop infinito instantâneo
		await get_tree().create_timer(0.05).timeout 



func _esperar_movimento():
	await get_tree().create_timer(0.15).timeout


func _on_botao_cabecalho_pressed() -> void:
	# Inverte a visibilidade da caixa de conteúdo (se tá true vira false, e vice-versa)
	conteudo_terminal.visible = !conteudo_terminal.visible
	
	# Muda o texto do botão para o jogador saber o estado
	if conteudo_terminal.visible:
		botao_cabecalho.text = "[-] Terminal de Comando"
	else:
		botao_cabecalho.text = "[+] Terminal de Comando"
