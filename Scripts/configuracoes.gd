extends Control

# Puxando as referências dos nós da sua UI
@onready var dropdown_resolucao = $Fundo/Margem/VBoxPrincipal/HBoxTela/DropdownResolucao
@onready var check_fullscreen = $Fundo/Margem/VBoxPrincipal/HBoxTela/CheckFullscreen
@onready var slider_som = $Fundo/Margem/VBoxPrincipal/SliderSom
@onready var slider_musica = $Fundo/Margem/VBoxPrincipal/SliderMusica
@onready var dropdown_idioma =$Fundo/Margem/VBoxPrincipal/DropdownIdioma


var cache_som : float
var cache_musica : float
var cache_fullscreen : bool

func _ready() -> void:
	# 1. Configura as opções visuais
	dropdown_resolucao.add_item("1920x1080")
	dropdown_resolucao.add_item("1280x720")
	
	dropdown_idioma.add_item("ENGLISH")
	dropdown_idioma.add_item("PORTUGUÊS")

	# 2. Carrega as configurações ao abrir a tela
	_sincronizar_ui_com_constantes()

func abrir() -> void:
	if not is_node_ready():
		await ready
	# 1. Tira a "foto" dos valores exatos ANTES do jogador ver a tela
	cache_som = Constantes.VOLUME_SFX
	cache_musica = Constantes.VOLUME_MUSICA
	cache_fullscreen = Constantes.TELA_CHEIA
	
	# 2. Força a interface a ir para a posição correta da foto
	_sincronizar_ui_com_constantes()
	
	# 3. Finalmente, mostra a tela pro jogador
	show()
	
func _sincronizar_ui_com_constantes() -> void:
	if not is_node_ready():
		return
	check_fullscreen.button_pressed = Constantes.TELA_CHEIA
	slider_som.value = Constantes.VOLUME_MASTER
	slider_musica.value = Constantes.VOLUME_MUSICA
	
	dropdown_resolucao.disabled = Constantes.TELA_CHEIA

# -------------------------------------------------- #
# SINAIS DOS SLIDERS (Para mudar o som em tempo real)
# -------------------------------------------------- #
func _on_slider_som_value_changed(value: float) -> void:
	Constantes.VOLUME_MASTER = value

func _on_slider_musica_value_changed(value: float) -> void:
	Constantes.VOLUME_MUSICA = value

# -------------------------------------------------- #
# SINAIS DA TELA (Checkbox e OptionButton)
# -------------------------------------------------- #
func _on_check_fullscreen_toggled(toggled_on: bool) -> void:
	# Ao marcar/desmarcar a tela cheia, a gente trava ou destrava o dropdown de resolução
	dropdown_resolucao.disabled = toggled_on

# -------------------------------------------------- #
# SINAIS DOS BOTÕES FINAIS (Save / Cancel)
# -------------------------------------------------- #
func _on_botao_save_pressed() -> void:
	Constantes.TELA_CHEIA = check_fullscreen.button_pressed
	
	# Pega a janela principal absoluta do jogo
	var janela_principal = get_tree().root
	
	if Constantes.TELA_CHEIA:
		# Coloca a janela principal em Tela Cheia
		janela_principal.mode = Window.MODE_FULLSCREEN
	else:
		# Tira da tela cheia
		janela_principal.mode = Window.MODE_WINDOWED
		
		# Define a nova resolução da janela
		if dropdown_resolucao.selected == 0:
			janela_principal.size = Vector2i(1920, 1080)
		elif dropdown_resolucao.selected == 1:
			janela_principal.size = Vector2i(1280, 720)
			
		# Dica de UX: Centraliza a janela no monitor do jogador após mudar o tamanho
		janela_principal.move_to_center()

	hide()

func _on_botao_cancel_pressed() -> void:
	# 1. Devolve os valores originais para o Autoload (o som volta ao normal na mesma hora)
	Constantes.VOLUME_SFX = cache_som
	Constantes.VOLUME_MUSICA = cache_musica
	Constantes.TELA_CHEIA = cache_fullscreen
	
	# 2. Força as barrinhas visuais a voltarem pro lugar antes da tela sumir
	_sincronizar_ui_com_constantes()
	
	hide()


func _on_botao_fechar_pressed() -> void:
	# O botão de "X" faz exatamente a mesma coisa que o cancelar
	_on_botao_cancel_pressed()


func _on_botao_deletar_pressed() -> void:
	# 1. Reseta os valores no Autoload para o padrão de fábrica
	Constantes.VOLUME_MASTER = 0.5
	Constantes.VOLUME_MUSICA = 0.5
	Constantes.VOLUME_SFX = 0.5
	Constantes.VOLUME_UI = 0.5
	Constantes.TELA_CHEIA = true
	Constantes.USAR_SHAKE = true
	Constantes.GRÁFICO_HIGH = true
	
	# 2. Faz a UI se atualizar (os sliders vão pular pro meio e o checkbox vai marcar)
	_sincronizar_ui_com_constantes()
	
	# 3. Força o jogo a voltar para tela cheia na mesma hora
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
