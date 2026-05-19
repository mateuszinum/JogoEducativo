extends Node
signal volume_alterado

# -------------------------------------------------- #
# VARIÁVEIS DE DESENVOLVEDOR

# Mude para false no build final
var MODO_DEV : bool = true 
var MOVIMENTO_WASD : bool = true 
var TUDO_DESBLOQUEADO : bool = true 
var REQUISITOS_DESATIVADOS : bool = true 
var TUDO_GRATIS : bool = false 
var JOGADOR_IMORTAL : bool = false 
var PULAR_TUTORIAL : bool = true 
var DEBUG : bool = true 

# Mude para true no build final
var TOCAR_MUSICA : bool = true 
var USAR_EFEITOS_TELA : bool = true 

# Mantenha essas como estão
var FONTE_TERMINAL : int = 0 # altera a fonte do código do usuário no grimório
var TEMPO_ESCREVA : float = 3.0 # o tempo que cada mensagem do "escreva()" persiste na tela
var IDIOMA : int = 0 # define o idioma dos textos do jogo
# -------------------------------------------------- #


# -------------------------------------------------- #
# CONFIGURAÇÕES DO JOGADOR E ÁUDIO

# Define se jogo está em tela cheia
var TELA_CHEIA : bool = true

# Define se efeitos de shake de tela estão ativos ou não
var USAR_SHAKE : bool = true

# Define se vai ter luz e partículas nos ataques
var GRÁFICO_HIGH : bool = true

var VOLUME_MASTER : float = 0.5:
	set(value):
		VOLUME_MASTER = clamp(value, 0.0, 1.0)
		_atualizar_bus_audio("Master", VOLUME_MASTER)
		volume_alterado.emit()

var VOLUME_MUSICA : float = 0.5:
	set(value):
		VOLUME_MUSICA = clamp(value, 0.0, 1.0)
		_atualizar_bus_audio("Musica", VOLUME_MUSICA)
		volume_alterado.emit()

var VOLUME_SFX : float = 0.5:
	set(value):
		VOLUME_SFX = clamp(value, 0.0, 1.0)
		_atualizar_bus_audio("SFX", VOLUME_SFX)
		volume_alterado.emit()

var VOLUME_UI : float = 0.5:
	set(value):
		VOLUME_UI = clamp(value, 0.0, 1.0)
		_atualizar_bus_audio("UI", VOLUME_UI)
		volume_alterado.emit()
		
# -------------------------------------------------- #

func _ready() -> void:
	_atualizar_bus_audio("Master", VOLUME_MASTER)
	_atualizar_bus_audio("Musica", VOLUME_MUSICA)
	_atualizar_bus_audio("SFX", VOLUME_SFX)
	_atualizar_bus_audio("UI", VOLUME_UI)

func _atualizar_bus_audio(nome_do_bus: String, valor_linear: float) -> void:
	var bus_index = AudioServer.get_bus_index(nome_do_bus)
	
	if bus_index == -1:
		if DEBUG: print("AVISO: Bus de áudio '", nome_do_bus, "' não encontrado!")
		return 
		
	var volume_db = linear_to_db(valor_linear)
	AudioServer.set_bus_volume_db(bus_index, volume_db)
	
	AudioServer.set_bus_mute(bus_index, valor_linear <= 0.0)
