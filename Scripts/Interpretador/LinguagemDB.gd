class_name LinguagemDB
extends RefCounted

## Vocabulário da linguagem do Grimório por idioma, usado pelo EDITOR
## (realce de sintaxe, autocomplete, auto-indentação, bloqueio por habilidade).
##
## O idioma ativo é o mesmo do interpretador: o Terminal pergunta ao
## InterpretadorServico (IdiomaEfetivo()) e chama LinguagemDB.definir_idioma().
## Assim o editor nunca sugere palavras que o interpretador não entende.
##
## Para adicionar/atualizar um idioma, mantenha estas listas alinhadas com a
## gramática (.g4) e com o visitor do interpretador correspondente.
##
## termos_autocomplete — formato: "termo": [recuo_do_cursor, "Nome exato do Produto na Skill Tree"]
##   recuo_do_cursor: quantos caracteres o cursor volta depois de inserir (ex.: para cair dentro dos parênteses)
##   Requisito "" = já começa desbloqueado. Os requisitos são os nomes internos dos produtos (em português)
##   e são os mesmos em todos os idiomas.

const IDIOMA_PADRAO := "pt"

static var idioma_ativo: String = IDIOMA_PADRAO

const PERFIS := {
	# =====================================================================
	# PORTUGUÊS — interpretador backend-extensao (branch Panorama-Geral)
	# =====================================================================
	"pt": {
		"abre_bloco": "{",
		"fecha_bloco": "}",
		# estrutura -> tem condição entre parênteses? (usado pelo AssistenteBlocos)
		"estruturas_bloco": {"senao se": true, "se": true, "senao": false, "enquanto": true},
		"tipos_funcao": ["vazio", "int", "float", "bool", "string", "Inimigo", "Arena", "Ataque", "Direcao"],
		"palavras_controle": ["se", "senao", "enquanto", "retorna", "e", "ou"],
		"palavras_tipo": ["int", "float", "bool", "string", "vazio", "Verdadeiro", "Falso", "Nulo", "Inimigo", "Arena", "Ataque", "Direcao", "Vetor", "de", "cinto", "mochila"],
		"constantes": [
			"Cima", "Baixo", "Direita", "Esquerda",
			"EsferaAzul", "EsferaVermelha", "Raio", "Gelo", "Fogo", "ExplosaoFogo", "ExplosaoGelo", "Alho",
			"Moeda", "Osso", "Couro", "Magma", "Cristal", "Plasma", "Sangue", "Safira", "Esmeralda", "Diamante",
			"Goblin", "Esqueleto", "SlimeDeFogo", "SlimeDeGelo", "Lobisomem", "Orc", "Fantasma", "Vampiro",
			"Campos", "Floresta", "Labirinto",
			"PocaoDeVida",
		],
		"funcoes_nativas": [
			"mover", "atacar", "inimigoMaisProximo", "podeMover", "tempo", "vidaAtual", "escapar",
			"escanearArea", "posicaoX", "posicaoY", "tesouroX", "tesouroY", "arena", "comprar", "venderTudo",
			"min", "max", "tamanho", "trunca", "aleatorio", "escreva",
		],
		"funcoes_membro": ["usarItem", "colocarItem"],
		"termos_autocomplete": {
			# --- Estruturas de controle ---
			# Ao aceitar, o AssistenteBlocos monta "{", corpo e "}" em linhas próprias.
			"se()": [1, "Loop e Condicional"], "senao se()": [1, "Loop e Condicional"], "senao": [0, "Loop e Condicional"],
			"enquanto()": [1, "Loop e Condicional"],
			# --- Tipos e valores ---
			"int": [0, "Variáveis"], "float": [0, "Variáveis"], "bool": [0, "Variáveis"], "Nulo": [0, "Variáveis"], "string": [0, "Variáveis"], "vazio": [0, "Variáveis"],
			"Verdadeiro": [0, ""], "Falso": [0, ""], "Inimigo": [0, "Variáveis"], "Arena": [0, "Variáveis"], "Ataque": [0, "Variáveis"], "Direcao": [0, "Variáveis"],
			"Vetor de": [0, "Listas"],
			"retorna": [0, "Funções"],
			# --- Funções COM parâmetros ---
			"mover()": [1, ""], "podeMover()": [1, "Sensores 2"], "atacar()": [1, "Início"], "arena()": [1, "Início"], "comprar()": [1, "Automação 2"], "cinto.usarItem()": [1, "Itens"], "escreva()": [1, "Debug"], "tamanho()": [1, "Utilidades"], "trunca()": [1, "Utilidades"], "min()": [1, "Utilidades"], "max()": [1, "Utilidades"],
			# --- Funções SEM parâmetros ---
			"inimigoMaisProximo()": [0, "Início"], "tempo()": [0, "Sensores 2"], "vidaAtual()": [0, "Sensores 2"], "escanearArea()": [0, "Sensores 3"], "posicaoX()": [0, "Localização"], "posicaoY()": [0, "Localização"], "tesouroX()": [0, "Localização"], "tesouroY()": [0, "Localização"], "escapar()": [0, "Automação 1"], "mochila.usarItem()": [0, "Itens"], "venderTudo()": [0, "Automação 2"], "aleatorio()": [0, "Utilidades"],
			# --- Direções ---
			"Cima": [0, ""], "Baixo": [0, ""], "Direita": [0, ""], "Esquerda": [0, ""],
			# --- Ataques ---
			"EsferaAzul": [0, "Início"], "EsferaVermelha": [0, "Esfera Vermelha"], "Gelo": [0, "Gelo"], "Fogo": [0, "Fogo"], "ExplosaoFogo": [0, "Explosão de Fogo"], "ExplosaoGelo": [0, "Explosão de Gelo"], "Alho": [0, "Alho"], "Raio": [0, "Raio"],
			# --- Inimigos ---
			"Goblin": [0, "Início"], "Esqueleto": [0, "Início"], "SlimeDeFogo": [0, "Início"], "SlimeDeGelo": [0, "Início"], "Lobisomem": [0, "Floresta"], "Orc": [0, "Floresta"], "Fantasma": [0, "Floresta"], "Vampiro": [0, "Floresta"],
			# --- Arenas ---
			"Campos": [0, "Início"], "Floresta": [0, "Floresta"], "Labirinto": [0, "Labirinto"],
			# --- Atributos de inimigos ---
			".nome": [0, "Sensores 1"], ".vida": [0, "Sensores 2"], ".posicaoX": [0, "Sensores 3"], ".posicaoY": [0, "Sensores 3"],
		},
	},

	# =====================================================================
	# INGLÊS — RASCUNHO, baseado no backend-extensao-ingles atual (desatualizado).
	# Revisar quando o interpretador em inglês for atualizado (ex.: "Vector of"?).
	# Só é usado quando o InterpretadorServico reportar IdiomaEfetivo() == "en".
	# =====================================================================
	"en": {
		"abre_bloco": "{",
		"fecha_bloco": "}",
		"estruturas_bloco": {"else if": true, "if": true, "else": false, "while": true},
		"tipos_funcao": ["void", "int", "float", "bool", "string", "Enemy", "Arena", "Attack", "Direction"],
		"palavras_controle": ["if", "else", "while", "return", "and", "or"],
		"palavras_tipo": ["int", "float", "bool", "string", "void", "True", "False", "Null", "Enemy", "Arena", "Attack", "Direction", "belt", "backpack"],
		"constantes": [
			"Up", "Down", "Right", "Left",
			"BlueSphere", "RedSphere", "Lightning", "Ice", "Fire", "FireExplosion", "IceExplosion", "Garlic",
			"Coin", "Bone", "Leather", "Magma", "Crystal", "Plasma", "Blood", "Sapphire", "Emerald", "Diamond",
			"Goblin", "Skeleton", "FireSlime", "IceSlime", "Werewolf", "Orc", "Ghost", "Vampire",
			"Fields", "Forest", "Maze",
			"HealthPotion",
		],
		"funcoes_nativas": [
			"move", "attack", "nearestEnemy", "canMove", "time", "currentHealth", "escape",
			"scanArea", "positionX", "positionY", "treasureX", "treasureY", "arena", "buy", "sellAll",
			"min", "max", "size", "truncate", "random", "write",
		],
		"funcoes_membro": ["useItem", "putItem"],
		"termos_autocomplete": {
			"if()": [1, "Loop e Condicional"], "else if()": [1, "Loop e Condicional"], "else": [0, "Loop e Condicional"],
			"while()": [1, "Loop e Condicional"],
			"int": [0, "Variáveis"], "float": [0, "Variáveis"], "bool": [0, "Variáveis"], "Null": [0, "Variáveis"], "string": [0, "Variáveis"], "void": [0, "Variáveis"],
			"True": [0, ""], "False": [0, ""], "Enemy": [0, "Variáveis"], "Arena": [0, "Variáveis"], "Attack": [0, "Variáveis"], "Direction": [0, "Variáveis"],
			"return": [0, "Funções"],
			"move()": [1, ""], "canMove()": [1, "Sensores 2"], "attack()": [1, "Início"], "arena()": [1, "Início"], "buy()": [1, "Automação 2"], "belt.useItem()": [1, "Itens"], "write()": [1, "Debug"], "size()": [1, "Utilidades"], "truncate()": [1, "Utilidades"], "min()": [1, "Utilidades"], "max()": [1, "Utilidades"],
			"nearestEnemy()": [0, "Início"], "time()": [0, "Sensores 2"], "currentHealth()": [0, "Sensores 2"], "scanArea()": [0, "Sensores 3"], "positionX()": [0, "Localização"], "positionY()": [0, "Localização"], "treasureX()": [0, "Localização"], "treasureY()": [0, "Localização"], "escape()": [0, "Automação 1"], "backpack.useItem()": [0, "Itens"], "sellAll()": [0, "Automação 2"], "random()": [0, "Utilidades"],
			"Up": [0, ""], "Down": [0, ""], "Right": [0, ""], "Left": [0, ""],
			"BlueSphere": [0, "Início"], "RedSphere": [0, "Esfera Vermelha"], "Ice": [0, "Gelo"], "Fire": [0, "Fogo"], "FireExplosion": [0, "Explosão de Fogo"], "IceExplosion": [0, "Explosão de Gelo"], "Garlic": [0, "Alho"], "Lightning": [0, "Raio"],
			"Goblin": [0, "Início"], "Skeleton": [0, "Início"], "FireSlime": [0, "Início"], "IceSlime": [0, "Início"], "Werewolf": [0, "Floresta"], "Orc": [0, "Floresta"], "Ghost": [0, "Floresta"], "Vampire": [0, "Floresta"],
			"Fields": [0, "Início"], "Forest": [0, "Floresta"], "Maze": [0, "Labirinto"],
			".name": [0, "Sensores 1"], ".health": [0, "Sensores 2"], ".positionX": [0, "Sensores 3"], ".positionY": [0, "Sensores 3"],
		},
	},
}

static func definir_idioma(codigo: String) -> void:
	idioma_ativo = codigo if PERFIS.has(codigo) else IDIOMA_PADRAO

static func perfil(codigo: String = "") -> Dictionary:
	if codigo == "":
		codigo = idioma_ativo
	return PERFIS.get(codigo, PERFIS[IDIOMA_PADRAO])

static func termos_autocomplete() -> Dictionary:
	return perfil()["termos_autocomplete"]

## "se()" → "se" | "cinto.usarItem()" → "cinto.usarItem" | "Vetor de" → "Vetor de"
static func palavra_do_termo(termo: String) -> String:
	return termo.replace("()", "").replace("{", "").replace(":", "").strip_edges()
