class_name AutocompleteDB
extends Resource

# o numero na frente da palavra é o recuo do cursor após usar o autocomplete
static var termos : Dictionary = {
	# Estruturas de Controle e Tipos
	"se():": 2, 
	"senao:": 0, 
	"enquanto():": 2, 
	"fim enquanto": 0, 
	"fim se": 0,
	"int": 0, "float": 0, "bool": 0, "string": 0,
	"Verdadeiro": 0, "Falso": 0, "Inimigo": 0, "Arena": 0, "Ataque": 0, "Direcao": 0,
	
	# Funções COM parâmetros (Volta 1 para cair dentro do parênteses)
	"mover()": 1, 
	"podeMover()": 1, 
	"atacar()": 1, 
	"nomeInimigo()": 1,
	"arena()": 1, 
	"comprar()": 1,
	"cinto.usarItem()": 1, 
	"cinto.colocarItem()": 1, 
	"mochila.colocarItem()": 1,

	# Funções SEM parâmetros (Volta 0, fica no final depois do parênteses)
	"inimigoMaisProximo()": 0, 
	"tempo()": 0, 
	"vidaAtual()": 0, 
	"escanearArea()": 0, 
	"posicaoX()": 0, 
	"posicaoY()": 0, 
	"tesouroX()": 0, 
	"tesouroY()": 0, 
	"escapar()": 0, 
	"mochila.usarItem()": 0,

	# Direções
	"Cima": 0, "Baixo": 0, "Direita": 0, "Esquerda": 0,

	# Ataques
	"EsferaAzul": 0, "EsferaVermelha": 0, "Agua": 0, "Gelo": 0, "Fogo": 0, "ExplosaoFogo": 0, "ExplosaoGelo": 0, "Alho": 0,

	# Recursos
	"Moeda": 0, "Osso": 0, "Couro": 0, "Magma": 0, "Cristal": 0, "Plasma": 0, "Sangue": 0, "Safira": 0, "Esmeralda": 0, "Diamante": 0,

	# Inimigos
	"Goblin": 0, "Esqueleto": 0, "SlimeDeFogo": 0, "SlimeDeGelo": 0, "Lobisomem": 0, "Orc": 0, "Fantasma": 0, "Vampiro": 0,

	# Arenas
	"Campos": 0, "Floresta": 0, "Labirinto": 0
}
