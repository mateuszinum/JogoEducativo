extends Node

# Mude para 'false' na hora de compilar o jogo final pro público!
var MODO_DEV : bool = true
# NOVO: Se verdadeiro, ignora os bloqueios de progressão da skill tree

var TUDO_DESBLOQUEADO : bool = true

# define se trilhas sonoras vão tocar
var TOCAR_MUSICA : bool = true

# Define se vai ter efeitos de pós processamento
var USAR_EFEITOS_TELA : bool = true

# -------------------------------------------------- #
# CONFIGURAÇÕES DO JOGADOR

# Valor de 0 a 1, o padrão é 0.5 (0.5 = 100%)
var VOLUME_MASTER : float = 0.5 
var VOLUME_MUSICA : float = 0.5
var VOLUME_SFX : float = 0.5

# Define se efeitos de shake de tela estão ativos ou não
var USAR_SHAKE : bool = true

# -------------------------------------------------- #
