extends Node

signal volume_alterado

# -------------------------------------------------- #
var FONTE_TERMINAL : int = 0 
var TEMPO_ESCREVA : float = 3.0 
# -------------------------------------------------- #

# -------------------------------------------------- #
# VARIÁVEIS DE DESENVOLVEDOR

# Mude para false no build final
var MODO_DEV : bool = true 
var TUDO_DESBLOQUEADO : bool = true 
var REQUISITOS_DESATIVADOS : bool = true 
var TUDO_GRATIS : bool = false 
var JOGADOR_IMORTAL : bool = false 
var PULAR_TUTORIAL : bool = true 
var DEBUG : bool = false 

# Mude para true no build final
var TOCAR_MUSICA : bool = true 
var USAR_EFEITOS_TELA : bool = true 
# -------------------------------------------------- #

# -------------------------------------------------- #
# CONFIGURAÇÕES DO JOGADOR E ÁUDIO
# -------------------------------------------------- #

func _ready() -> void:
	# Quando o jogo abre, garante que o volume físico corresponde aos valores salvos aqui
	_atualizar_bus_audio("Master", VOLUME_MASTER)
	_atualizar_bus_audio("Musica", VOLUME_MUSICA)
	_atualizar_bus_audio("SFX", VOLUME_SFX)
	_atualizar_bus_audio("UI", VOLUME_UI)

# Função auxiliar para não repetir código toda hora
func _atualizar_bus_audio(nome_do_bus: String, valor_linear: float) -> void:
	# Pega o ID da mesa de som pelo nome
	var bus_index = AudioServer.get_bus_index(nome_do_bus)
	
	# Se não encontrar o bus (você esqueceu de criar), ele ignora para não crashar
	if bus_index == -1:
		if DEBUG: print("AVISO: Bus de áudio '", nome_do_bus, "' não encontrado!")
		return 
		
	# Converte a matemática de 0.0~1.0 para os Decibéis que o Godot entende
	var volume_db = linear_to_db(valor_linear)
	AudioServer.set_bus_volume_db(bus_index, volume_db)
	
	# Truque: Se o volume for 0, a gente muta de vez para evitar ruídos residuais
	AudioServer.set_bus_mute(bus_index, valor_linear <= 0.0)


# Usamos clamp() nos setters para garantir que o slider nunca passe um valor bugado (< 0 ou > 1)
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

# Define se jogo está em tela cheia
var TELA_CHEIA : bool = true

# Define se efeitos de shake de tela estão ativos ou não
var USAR_SHAKE : bool = true

# Define se vai ter luz e partículas nos ataques
var GRÁFICO_HIGH : bool = true
# -------------------------------------------------- #
