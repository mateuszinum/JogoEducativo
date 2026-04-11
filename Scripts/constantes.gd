extends Node

# Mude para 'false' na hora de compilar o jogo final pro público!
var MODO_DEV : bool = true
var TUDO_DESBLOQUEADO : bool = true

# Define se vai ter efeitos de pós processamento e música
var TOCAR_MUSICA : bool = false
var USAR_EFEITOS_TELA : bool = true

# -------------------------------------------------- #
# CONFIGURAÇÕES DO JOGADOR

# Valor de 0 a 1, o padrão é 0.5 (0.5 = 100%)
var VOLUME_MASTER : float = 0.5 
var VOLUME_MUSICA : float = 0.5
var VOLUME_SFX : float = 0.5
var VOLUME_UI : float = 0.5

# Define se jogo está em tela cheia
var TELA_CHEIA : bool = true

# Define se efeitos de shake de tela estão ativos ou não
var USAR_SHAKE : bool = true

# Define o índice da fonte do terminal. 
var FONTE_TERMINAL : int = 0

# -------------------------------------------------- #
