class_name AutocompleteDB
extends Resource

# Formato: "termo": [recuo_do_cursor, "Nome Exato do Produto na Skill Tree"]
# Se o requisito for "", a palavra já começa desbloqueada no jogo!

static var termos : Dictionary = {
	# --- Estruturas de Controle, Tipos e Funções ---
	"se():": [2, "Loop e Condicional"], "senao:": [0, "Loop e Condicional"], "enquanto():": [2, "Loop e Condicional"], "fim enquanto": [0, "Loop e Condicional"], "fim se": [0, "Loop e Condicional"], 
	"int": [0, "Variáveis"], "float": [0, "Variáveis"], "bool": [0, "Variáveis"], "string": [0, "Variáveis"], "vazio": [0, "Variáveis"],
	"Verdadeiro": [0, ""], "Falso": [0, ""], "Inimigo": [0, "Variáveis"], "Arena": [0, "Variáveis"], "Ataque": [0, "Variáveis"], "Direcao": [0, "Variáveis"],
	"retorna": [0, "Funções"], "fim funcao": [0, "Funções"],

	# --- Funções COM parâmetros ---
	"mover()": [1, ""], "podeMover()": [1, "Sensores 2"], "atacar()": [1, "Início"], "nomeInimigo()": [1, "Sensores 1"], "arena()": [1, "Início"], "comprar()": [1, "Automação 2"], "cinto.usarItem()": [1, "Itens"], "escrever()": [1, "Debug"], "min()": [1, "Utilidades"], "max()": [1, "Utilidades"], "vidaInimigo()": [1, "Sensores 3"], "velocidadeInimigo()": [1, "Sensores 3"],

	# --- Funções SEM parâmetros ---
	"inimigoMaisProximo()": [0, "Início"], "tempo()": [0, "Sensores 2"], "vidaAtual()": [0, "Sensores 2"], "escanearArea()": [0, "Sensores 3"], "posicaoX()": [0, "Localização"], "posicaoY()": [0, "Localização"], "tesouroX()": [0, "Localização"], "tesouroY()": [0, "Localização"], "escapar()": [0, "Automação 1"], "mochila.usarItem()": [0, "Itens"], "venderTudo()": [0, "Automação 2"], "aleatorio()": [0, "Utilidades"],

	# --- Direções ---
	"Cima": [0, ""], "Baixo": [0, ""], "Direita": [0, ""], "Esquerda": [0, ""],

	# --- Ataques ---
	"EsferaAzul": [0, "Início"], "EsferaVermelha": [0, "Esfera Vermelha"], "Gelo": [0, "Gelo"], "Fogo": [0, "Fogo"], "ExplosaoFogo": [0, "Explosão de Fogo"], "ExplosaoGelo": [0, "Explosão de Gelo"], "Alho": [0, "Alho"],

	# --- Inimigos ---
	"Goblin": [0, "Início"], "Esqueleto": [0, "Início"], "SlimeDeFogo": [0, "Início"], "SlimeDeGelo": [0, "Início"], "Lobisomem": [0, "Floresta"], "Orc": [0, "Floresta"], "Fantasma": [0, "Floresta"], "Vampiro": [0, "Floresta"],

	# --- Arenas ---
	"Campos": [0, "Início"], "Floresta": [0, "Floresta"], "Labirinto": [0, "Labirinto"]
}
