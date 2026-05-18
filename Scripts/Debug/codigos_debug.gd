class_name CodigosDebug extends RefCounted

static var codigos_salvos: Array[String] = [
	
# --- SLOT 0 (Código A) ---
"""arena(Campos)
Direcao dir = [Esquerda, Cima, Direita, Baixo]
bool f = !Verdadeiro
int i = 0

Direcao GetDirecao(int j):
	retorna dir[j]
fim funcao

vazio Movimento():
	mover(GetDirecao(i))
	retorna
fim funcao

vazio AtacarInimigoMaisProximo():
	Inimigo alvo = inimigoMaisProximo()
	Ataque atk = EsferaAzul
	se(alvo.nome == SlimeDeFogo):
		atk = Gelo
	senao se(alvo.nome == SlimeDeGelo):
		atk = Fogo
	fim se
	se(alvo.nome == "NULO"):
		retorna
	senao:
		escreva("Ataquei um " + alvo.nome + " usando " + atk)
		atacar(alvo, atk)
	fim se
fim funcao

vazio Incremento(int maior):
	i = i + 1
	se(i > maior):
		i = 0
	fim se
	retorna
fim funcao
	
enquanto(Verdadeiro):
	Movimento()
	AtacarInimigoMaisProximo()
	
	Incremento(3)
fim enquanto""",

# --- SLOT 1 (Código B) ---
"""arena(Floresta)
Direcao dir = [Esquerda, Cima, Direita, Baixo, Esquerda, Cima, Direita, Baixo]
Ataque atk = [EsferaAzul, EsferaVermelha, Raio, Gelo, ExplosaoGelo, Fogo, ExplosaoFogo, Alho]
bool f = !Verdadeiro
int i = 0

Direcao GetDirecao(int j):
	retorna dir[j]
fim funcao

vazio Movimento():
	mover(GetDirecao(i))
	retorna
fim funcao

vazio AtacarInimigoMaisProximo():
	Inimigo alvo = inimigoMaisProximo()
	Ataque ataque = atk[i]
	se(alvo.nome == "NULO"):
		retorna
	senao se(alvo.nome == Vampiro):
		escreva("Ataquei um " + alvo.nome)
		atacar(alvo, Alho)
		retorna
	fim se
	escreva("Ataquei um " + alvo.nome)
	atacar(alvo, ataque)
	retorna
fim funcao

vazio Incremento(int maior):
	i = i + 1
	se(i > maior):
		i = 0
	fim se
	retorna
fim funcao
	
enquanto(Verdadeiro):
	Movimento()
	AtacarInimigoMaisProximo()
	
	Incremento(7)
fim enquanto""",

# --- SLOT 2 (Código C) ---
"""arena(Labirinto)

Direcao PegarDireita(Direcao direcaoAtual):
	se(direcaoAtual == Cima):
		retorna Direita
	fim se
	se(direcaoAtual == Direita):
		retorna Baixo
	fim se
	se(direcaoAtual == Baixo):
		retorna Esquerda
	fim se
	se(direcaoAtual == Esquerda):
		retorna Cima
	fim se
fim funcao

Direcao PegarEsquerda(Direcao direcaoAtual):
	se(direcaoAtual == Cima):
		retorna Esquerda
	fim se
	se(direcaoAtual == Esquerda):
		retorna Baixo
	fim se
	se(direcaoAtual == Baixo):
		retorna Direita
	fim se
	se(direcaoAtual == Direita):
		retorna Cima
	fim se
fim funcao

Direcao PegarTras(Direcao direcaoAtual):
	se(direcaoAtual == Cima):
		retorna Baixo
	fim se
	se(direcaoAtual == Baixo):
		retorna Cima
	fim se
	se(direcaoAtual == Direita):
		retorna Esquerda
	fim se
	se(direcaoAtual == Esquerda):
		retorna Direita
	fim se
fim funcao

Direcao dirAtual = Baixo
Direcao dirDireita = Baixo
Direcao dirEsquerda = Baixo
Direcao dirTras = Baixo

enquanto(Verdadeiro):
	dirDireita = PegarDireita(dirAtual)
	dirEsquerda = PegarEsquerda(dirAtual)
	dirTras = PegarTras(dirAtual)

	se(podeMover(dirDireita)):
		dirAtual = dirDireita
		mover(dirAtual)
	senao:
		se(podeMover(dirAtual)):
			mover(dirAtual)
		senao:
			se(podeMover(dirEsquerda)):
				dirAtual = dirEsquerda
				mover(dirAtual)
			senao:
				dirAtual = dirTras
				mover(dirAtual)
			fim se
		fim se
	fim se
fim enquanto""",

# --- SLOT 3 (Código D) ---
"""enquanto(Verdadeiro):
	arena(Campos)
	bool atacou = Falso
	
	enquanto(!atacou):
		Inimigo alvo = inimigoMaisProximo()
		se(alvo.nome != "NULO"):
			atacar(alvo, EsferaAzul)
			atacou = Verdadeiro
		fim se
	fim enquanto
	
	escapar()
fim enquanto""",

# --- SLOT 4 (Código E) ---
"""enquanto(Verdadeiro):
	arena(Campos)
	escapar()
fim enquanto"""
]

static func obter_codigo(indice: int) -> String:
	if indice >= 0 and indice < codigos_salvos.size():
		return codigos_salvos[indice]
	return ""
