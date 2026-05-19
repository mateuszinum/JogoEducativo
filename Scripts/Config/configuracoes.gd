extends Control

@onready var slider_master = %SliderMaster
@onready var slider_musica = %SliderMusica
@onready var slider_sfx = %SliderSFX
@onready var slider_ui = %SliderUI
@onready var blur_rect = %Blur

@onready var check_fullscreen = %CheckFullscreen
@onready var check_shake = %CheckShake
@onready var check_grafico = %CheckGrafico

var cache_master : float
var cache_musica : float
var cache_sfx : float
var cache_ui : float
var cache_fullscreen : bool

func _ready() -> void:
	_sincronizar_ui_com_constantes()

func abrir(blur: bool = false) -> void:
	if not is_node_ready():
		await ready
	# 1. Tira a "foto" dos valores exatos ANTES do jogador ver a tela
	cache_master = Constantes.VOLUME_MASTER
	cache_musica = Constantes.VOLUME_MUSICA
	cache_sfx = Constantes.VOLUME_SFX
	cache_ui = Constantes.VOLUME_UI
	cache_fullscreen = Constantes.TELA_CHEIA
	
	# 2. Força a interface a ir para a posição correta da foto
	_sincronizar_ui_com_constantes()
	
	# 3. Finalmente, mostra a tela pro jogador
	if blur:
		blur_rect.show()
	else:
		blur_rect.hide()
	show()
	
func _sincronizar_ui_com_constantes() -> void:
	if not is_node_ready():
		return
	slider_master.value = Constantes.VOLUME_MASTER
	slider_musica.value = Constantes.VOLUME_MUSICA
	slider_sfx.value = Constantes.VOLUME_SFX
	slider_ui.value = Constantes.VOLUME_UI
	
	if check_fullscreen:
		check_fullscreen.button_pressed = Constantes.TELA_CHEIA
	if check_shake:
		check_shake.button_pressed = Constantes.USAR_SHAKE
	if check_grafico:
		check_grafico.button_pressed = Constantes.GRÁFICO_HIGH
	

# -------------------------------------------------- #
# SINAIS DA TELA (Checkbox e OptionButton)
# -------------------------------------------------- #
func _on_check_fullscreen_toggled(toggled_on: bool) -> void:
	Constantes.TELA_CHEIA = toggled_on

func _on_check_shake_toggled(toggled_on: bool) -> void:
	Constantes.USAR_SHAKE = toggled_on

func _on_check_grafico_toggled(toggled_on: bool) -> void:
	Constantes.GRÁFICO_HIGH = toggled_on
	
# -------------------------------------------------- #
# SINAIS DOS BOTÕES FINAIS (Save / Cancel)
# -------------------------------------------------- #
func _on_botao_save_pressed() -> void:
	GerenciadorVideo.aplicar_configuracoes_de_tela()
	
	SaveMaster.salvar_dado_config()
	hide()

func _on_botao_cancel_pressed() -> void:
	# 1. Devolve os valores originais para o Autoload (o som volta ao normal na mesma hora)
	Constantes.VOLUME_SFX = cache_sfx
	Constantes.VOLUME_MUSICA = cache_musica
	Constantes.VOLUME_UI = cache_ui
	Constantes.VOLUME_MASTER = cache_master
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
	
# -------------------------------------------------- #
# SINAIS DOS SLIDERS (Para mudar o som em tempo real)
# -------------------------------------------------- #

func _on_slider_master_value_changed(value: float) -> void:
	Constantes.VOLUME_MASTER = value

func _on_slider_musica_value_changed(value: float) -> void:
	Constantes.VOLUME_MUSICA = value
	
func _on_slider_sfx_value_changed(value: float) -> void:
	Constantes.VOLUME_SFX = value

func _on_slider_ui_value_changed(value: float) -> void:
	Constantes.VOLUME_UI = value
