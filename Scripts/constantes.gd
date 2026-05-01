extends Node
signal volume_alterado

# -------------------------------------------------- #
# Mude tudo aqui para 'false' na hora de compilar o jogo final pro público!
var MODO_DEV : bool = true # coleção de coisas que facilitam o desenvolvimento
var TUDO_DESBLOQUEADO : bool = true # começa com tudo da skilltree já desbloqueado
var REQUISITOS_DESATIVADOS : bool = true # define se os ataques precisam de requisitos para serem lançados
var TUDO_GRATIS : bool = false # custos de produtos ignorados
var JOGADOR_IMORTAL : bool = false # define se o jogador é invulnerável ou não
var DEBUG : bool = false # ativa/desativa prints úteis para debug


# Mude tudo aqui para 'true' na hora de compilar o jogo final pro público!
var TOCAR_MUSICA : bool = true # liga ou desliga todas as músicas
var USAR_EFEITOS_TELA : bool = true # define se vai ter efeitos de pós processamento

# Define o índice da fonte do terminal. Atualmente só temos 0 e 1
var FONTE_TERMINAL : int = 0

# Define o tempo que uma mensagem no escreva demora para sumir da tela
var TEMPO_ESCREVA : float = 3.0
# -------------------------------------------------- #



# -------------------------------------------------- #
# CONFIGURAÇÕES DO JOGADOR
# essas são as coisas que o jogador vai conseguir alterar por contra própria

# Valor de 0 a 1 para o slider, o padrão é 0.5 (0.5 = 100%)
var VOLUME_MASTER : float = 0.5:
	set(value):
		VOLUME_MASTER = value
		volume_alterado.emit()

var VOLUME_MUSICA : float = 0.5:
	set(value):
		VOLUME_MUSICA = value
		volume_alterado.emit()

var VOLUME_SFX : float = 0.5:
	set(value):
		VOLUME_SFX = value
		volume_alterado.emit()

var VOLUME_UI : float = 0.5:
	set(value):
		VOLUME_UI = value
		volume_alterado.emit()

# Define se jogo está em tela cheia
var TELA_CHEIA : bool = true

# Define se efeitos de shake de tela estão ativos ou não
var USAR_SHAKE : bool = true

# Define se vai ter luz e partículas nos ataques
var GRÁFICO_HIGH : bool = true
# -------------------------------------------------- #
