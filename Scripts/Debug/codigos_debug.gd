class_name CodigosDebug extends RefCounted

static var codigos_salvos: Array[String] = [
	
# --- SLOT 0 (Código A) ---
"""arena(Campos)
Vetor de Direcao dir = [Esquerda, Cima, Direita, Baixo]
bool f = !Verdadeiro
int i = 0

Direcao GetDirecao(int j)
{
	retorna dir[j]
}

vazio Movimento()
{
	mover(GetDirecao(i))
	retorna
}

vazio AtacarInimigoMaisProximo()
{
	Inimigo alvo = inimigoMaisProximo()
	Ataque atk = EsferaAzul
	se(alvo.nome == SlimeDeFogo)
	{
		atk = Gelo
	}
	senao se(alvo.nome == SlimeDeGelo)
	{
		atk = Fogo
	}
	se(alvo.nome == Nulo)
	{
		retorna
	}
	senao
	{
		escreva("Ataquei um " + alvo.nome + " usando " + atk)
		atacar(alvo, atk)
	}
}

vazio Incremento(int maior)
{
	i = i + 1
	se(i > maior)
	{
		i = 0
	}
	retorna
}
	
enquanto(Verdadeiro)
{
	se(vidaAtual() == 1)
	{
		escapar()
		arena(Campos)
	}
	Movimento()
	AtacarInimigoMaisProximo()
	
	Incremento(3)
}""",

# --- SLOT 1 (Código B) ---
"""arena(Floresta)
Vetor de Direcao dir = [Esquerda, Cima, Direita, Baixo, Esquerda, Cima, Direita, Baixo]
Vetor de Ataque atk = [EsferaAzul, EsferaVermelha, Raio, Gelo, ExplosaoGelo, Fogo, ExplosaoFogo, Alho]
bool f = !Verdadeiro
int i = 0

Direcao GetDirecao(int j)
{
	retorna dir[j]
}

vazio Movimento()
{
	mover(GetDirecao(i))
	retorna
}

vazio AtacarInimigoMaisProximo()
{
	Inimigo alvo = inimigoMaisProximo()
	Ataque ataque = atk[i]
	se(alvo.nome == Nulo)
	{
		retorna
	}
	senao se(alvo.nome == Vampiro)
	{
		escreva("Ataquei um " + alvo.nome)
		atacar(alvo, Alho)
		retorna
	}
	escreva("Ataquei um " + alvo.nome)
	atacar(alvo, ataque)
	retorna
}

vazio Incremento(int maior)
{
	i = i + 1
	se(i > maior)
	{
		i = 0
	}
	retorna
}
	
enquanto(Verdadeiro)
{
	se(vidaAtual() == 1)
	{
		escapar()
		arena(Floresta)
	}
	Movimento()
	AtacarInimigoMaisProximo()
	
	Incremento(7)
}""",

# --- SLOT 2 (Código C) ---
"""arena(Labirinto)

Direcao PegarDireita(Direcao direcaoAtual)
{
	se(direcaoAtual == Cima)
	{
		retorna Direita
	}
	se(direcaoAtual == Direita)
	{
		retorna Baixo
	}
	se(direcaoAtual == Baixo)
	{
		retorna Esquerda
	}
	se(direcaoAtual == Esquerda)
	{
		retorna Cima
	}
}

Direcao PegarEsquerda(Direcao direcaoAtual)
{
	se(direcaoAtual == Cima)
	{
		retorna Esquerda
	}
	se(direcaoAtual == Esquerda)
	{
		retorna Baixo
	}
	se(direcaoAtual == Baixo)
	{
		retorna Direita
	}
	se(direcaoAtual == Direita)
	{
		retorna Cima
	}
}

Direcao PegarTras(Direcao direcaoAtual)
{
	se(direcaoAtual == Cima)
	{
		retorna Baixo
	}
	se(direcaoAtual == Baixo)
	{
		retorna Cima
	}
	se(direcaoAtual == Direita)
	{
		retorna Esquerda
	}
	se(direcaoAtual == Esquerda)
	{
		retorna Direita
	}
}

Direcao dirAtual = Baixo
Direcao dirDireita = Baixo
Direcao dirEsquerda = Baixo
Direcao dirTras = Baixo

enquanto(Verdadeiro)
{
	dirDireita = PegarDireita(dirAtual)
	dirEsquerda = PegarEsquerda(dirAtual)
	dirTras = PegarTras(dirAtual)

	se(podeMover(dirDireita))
	{
		dirAtual = dirDireita
		mover(dirAtual)
	}
	senao
	{
		se(podeMover(dirAtual))
		{
			mover(dirAtual)
		}
		senao
		{
			se(podeMover(dirEsquerda))
			{
				dirAtual = dirEsquerda
				mover(dirAtual)
			}
			senao
			{
				dirAtual = dirTras
				mover(dirAtual)
			}
		}
	}
}""",

# --- SLOT 3 (Código D) ---
"""""",

# --- SLOT 4 (Código E) ---
"""# ==================================================
# TESTE GERAL DA LINGUAGEM DO GRIMORIO
# Rode na vila. So aparece mensagem em falha e no
# fim de cada secao. A ultima secao entra na arena.
# ==================================================

int testes = 0
int falhas = 0
int testesSecao = 0
int falhasSecao = 0

vazio checar(string nome, bool condicao)
{
	testes = testes + 1
	testesSecao = testesSecao + 1
	se(!condicao)
	{
		falhas = falhas + 1
		falhasSecao = falhasSecao + 1
		escreva("FALHOU: " + nome)
	}
}

vazio fimSecao(string titulo)
{
	se(falhasSecao == 0)
	{
		escreva("[OK] " + titulo + ": " + testesSecao + " testes")
	}
	senao
	{
		escreva("[ERRO] " + titulo + ": " + falhasSecao + " de " + testesSecao + " falharam")
	}
	testesSecao = 0
	falhasSecao = 0
}

bool perto(float valorA, float valorB)
{
	retorna valorA - valorB < 0.001 e valorB - valorA < 0.001
}

# ---------- VARIAVEIS E TIPOS ----------
int varInt = 10
float varFloat = 2.5
bool varBool = Verdadeiro
string varString = "texto"
Direcao varDirecao = Cima
Ataque varAtaque = Fogo
Arena varArena = Campos
Inimigo varInimigo = Goblin
checar("declarar int", varInt == 10)
checar("declarar float", varFloat == 2.5)
checar("declarar bool", varBool)
checar("declarar string", varString == "texto")
checar("declarar Direcao", varDirecao == Cima)
checar("declarar Ataque", varAtaque == Fogo)
checar("declarar Arena", varArena == Campos)
checar("declarar Inimigo", varInimigo == Goblin)

varInt = 20
varFloat = 3.5
varBool = Falso
varString = "outro"
varDirecao = Baixo
varAtaque = Gelo
varArena = Floresta
checar("atribuir int", varInt == 20)
checar("atribuir float", varFloat == 3.5)
checar("atribuir bool", !varBool)
checar("atribuir string", varString == "outro")
checar("atribuir Direcao", varDirecao == Baixo)
checar("atribuir Ataque", varAtaque == Gelo)
checar("atribuir Arena", varArena == Floresta)

varFloat = 2
checar("float recebe int e converte", varFloat == 2.0)
float floatDeInt = 3
checar("float declarado com int", floatDeInt + 0.5 == 3.5)

int comentado = 1 # comentario no fim da linha
checar("comentario no fim da linha", comentado == 1)
int mesmaLinhaA = 1 int mesmaLinhaB = 2
checar("dois comandos na mesma linha", mesmaLinhaA + mesmaLinhaB == 3)
int var_2 = 5
int Maiuscula = 1
int maiuscula = 2
checar("nome com _ e numero", var_2 == 5)
checar("nomes diferenciam maiusculas", Maiuscula != maiuscula)
int senaoX = 1
int seguir = 2
int ouro = 3
int enquantoVale = 4
int retornaValor = 5
int deposito = 6
int eixo = 7
checar("nomes parecidos com palavras-chave", senaoX + seguir + ouro + enquantoVale + retornaValor + deposito + eixo == 28)
fimSecao("Variaveis")

# ---------- ARITMETICA ----------
int unarioBase = 5
checar("precedencia * sobre +", 2 + 3 * 4 == 14)
checar("parenteses", (2 + 3) * 4 == 20)
checar("subtracao associa a esquerda", 10 - 2 - 3 == 5)
checar("divisao associa a esquerda", 20 / 2 / 5 == 2)
checar("divisao inteira", 7 / 2 == 3)
checar("modulo", 7 % 3 == 1)
checar("divisao float", perto(7.0 / 2, 3.5))
checar("modulo float", perto(5.5 % 2, 1.5))
checar("soma int e float", perto(1 + 2.5, 3.5))
checar("negativo", -5 + 2 == -3)
checar("negativo com parenteses", -(2 + 3) == -5)
checar("subtrair negativo", 3 - -2 == 5)
checar("multiplicar negativo", 2 * -3 == -6)
checar("negar variavel", -unarioBase == -5)
checar("divisao por zero int", 1 / 0 == 0)
checar("modulo por zero int", 1 % 0 == 0)
checar("divisao por zero float", perto(1.5 / 0, 0))
checar("numero grande", 1000 * 1000 == 1000000)
fimSecao("Aritmetica")

# ---------- COMPARACOES E LOGICA ----------
checar("menor", 1 < 2)
checar("maior", 2 > 1)
checar("maior ou igual", 2 >= 2)
checar("menor ou igual", 2 <= 2)
checar("igual", 1 == 1)
checar("diferente", 1 != 2)
checar("compara int e float", 1.5 > 1)
checar("strings iguais", "a" == "a")
checar("strings diferentes", "a" != "b")
checar("bool igual", Verdadeiro == Verdadeiro)
checar("bool diferente", Verdadeiro != Falso)
checar("constante igual", Cima == Cima)
checar("constante diferente", Cima != Baixo)
checar("e VV", Verdadeiro e Verdadeiro)
checar("e VF", !(Verdadeiro e Falso))
checar("ou VF", Verdadeiro ou Falso)
checar("ou FF", !(Falso ou Falso))
checar("nao", !Falso)
checar("nao duplo", !!Verdadeiro)
checar("nao com parenteses", !(1 > 2))
checar("e antes de ou", Verdadeiro ou Falso e Falso)
checar("parenteses mudam logica", !((Verdadeiro ou Falso) e Falso))
checar("logica com comparacoes", 1 < 2 e 2 < 3)
checar("logica com contas", 1 + 1 == 2 e 2 * 2 == 4)
# Comportamento desejado: se estes falharem, e bug do interpretador.
checar("igualdade float == int", 2.0 == 2)
checar("igualdade int == float", 2 == 2.0)
fimSecao("Comparacoes e logica")

# ---------- STRINGS ----------
string textoVazio = ""
checar("string vazia", textoVazio == "")
checar("concatenar", "a" + "b" == "ab")
checar("concatenar variavel", varString + "!" == "outro!")
checar("texto + numeros", "a" + 1 + 2 == "a12")
checar("conta antes do texto", 1 + 2 + "a" == "3a")
checar("texto + float", "v" + 1.5 == "v1.5")
checar("texto + bool", "v" + Verdadeiro == "vVerdadeiro")
checar("texto + Nulo", "v" + Nulo == "vNulo")
checar("texto + constante", "v" + Cima == "vCima")
checar("texto + vetor", "v" + [1, 2] == "v[1, 2]")
checar("cerquilha na string", "a#b" != "a")
checar("chaves na string", "{ }" != "")
checar("acentos na string", "ação" == "ação")
escreva("Quebra de linha: linha 1\\nlinha 2")
escreva(123)
escreva(1.5)
escreva(Verdadeiro)
escreva(Nulo)
escreva([1, 2, 3])
fimSecao("Strings")

# ---------- NULO ----------
Inimigo semAlvo = Nulo
int inteiroNulo = Nulo
string textoNulo = Nulo
checar("Nulo == Nulo", Nulo == Nulo)
checar("variavel Nulo", semAlvo == Nulo)
checar("Nulo != valor", semAlvo != Goblin)
checar("int Nulo", inteiroNulo == Nulo)
checar("string Nulo", textoNulo == Nulo)
checar("Nulo vale 0 na conta", inteiroNulo + 1 == 1)
checar("atributo de Nulo", semAlvo.nome == Nulo)
checar("vida de Nulo", semAlvo.vida == Nulo)
fimSecao("Nulo")

# ---------- SE / SENAO ----------
string classificar(int numero)
{
	se(numero < 0)
	{
		retorna "negativo"
	}
	senao se(numero == 0)
	{
		retorna "zero"
	}
	senao se(numero < 10)
	{
		retorna "pequeno"
	}
	senao
	{
		retorna "grande"
	}
}
checar("se", classificar(-1) == "negativo")
checar("senao se 1", classificar(0) == "zero")
checar("senao se 2", classificar(5) == "pequeno")
checar("senao", classificar(50) == "grande")

int passouSe = 0
se(Verdadeiro)
{
	passouSe = passouSe + 1
}
se(Falso)
{
	passouSe = passouSe + 10
}
se(1 < 2)
{
	se(2 < 3)
	{
		se(!Falso)
		{
			passouSe = passouSe + 100
		}
	}
	senao
	{
		passouSe = passouSe + 1000
	}
}
checar("se simples e aninhado", passouSe == 101)
fimSecao("Se e senao")

# ---------- ENQUANTO ----------
int contagem = 0
int somaLaco = 0
enquanto(contagem < 5)
{
	contagem = contagem + 1
	somaLaco = somaLaco + contagem
	int dobroLaco = contagem * 2
}
checar("enquanto conta", contagem == 5)
checar("enquanto soma", somaLaco == 15)
checar("redeclarar dentro do laco", dobroLaco == 10)

enquanto(Falso)
{
	checar("enquanto(Falso) nao roda", Falso)
}

int externoLaco = 0
int totalAninhado = 0
enquanto(externoLaco < 3)
{
	int internoLaco = 0
	enquanto(internoLaco < 4)
	{
		totalAninhado = totalAninhado + 1
		internoLaco = internoLaco + 1
	}
	externoLaco = externoLaco + 1
}
checar("enquanto aninhado", totalAninhado == 12)

int regressiva = 3
enquanto(regressiva > 0)
{
	regressiva = regressiva - 1
}
checar("contagem regressiva", regressiva == 0)
fimSecao("Enquanto")

# ---------- FUNCOES ----------
int devolveInt()
{
	retorna 7
}

float devolveFloat()
{
	retorna 1.5
}

float devolveFloatDeInt()
{
	retorna 2
}

bool devolveBool()
{
	retorna Verdadeiro
}

string devolveString()
{
	retorna "ola"
}

Direcao devolveDirecao()
{
	retorna Esquerda
}

Ataque devolveAtaque()
{
	retorna Raio
}

int somar(int parcelaA, int parcelaB)
{
	retorna parcelaA + parcelaB
}

int somarTres(int p1, int p2, int p3)
{
	retorna somar(somar(p1, p2), p3)
}

int fatorial(int numero)
{
	se(numero <= 1)
	{
		retorna 1
	}
	retorna numero * fatorial(numero - 1)
}

int fibonacci(int numero)
{
	se(numero < 2)
	{
		retorna numero
	}
	retorna fibonacci(numero - 1) + fibonacci(numero - 2)
}

bool ehImpar(int numero)
{
	se(numero == 0)
	{
		retorna Falso
	}
	retorna ehPar(numero - 1)
}

bool ehPar(int numero)
{
	se(numero == 0)
	{
		retorna Verdadeiro
	}
	retorna ehImpar(numero - 1)
}

int profundidade(int numero)
{
	se(numero == 0)
	{
		retorna 0
	}
	retorna 1 + profundidade(numero - 1)
}

int primeiroMultiplo(int base)
{
	int candidato = 1
	enquanto(Verdadeiro)
	{
		se(candidato % base == 0)
		{
			retorna candidato
		}
		candidato = candidato + 1
	}
}

int contadorVazio = 0

vazio incrementaAntesDeSair(bool sair)
{
	contadorVazio = contadorVazio + 1
	se(sair)
	{
		retorna
	}
	contadorVazio = contadorVazio + 10
}

checar("retorna int", devolveInt() == 7)
checar("retorna float", devolveFloat() == 1.5)
checar("retorna float a partir de int", perto(devolveFloatDeInt(), 2))
checar("retorna bool", devolveBool())
checar("retorna string", devolveString() == "ola")
checar("retorna Direcao", devolveDirecao() == Esquerda)
checar("retorna Ataque", devolveAtaque() == Raio)
checar("dois parametros", somar(2, 3) == 5)
checar("funcao chamando funcao", somarTres(1, 2, 3) == 6)
checar("funcao como argumento", somar(somar(1, 1), somar(2, 2)) == 6)
checar("funcao em expressao", somar(1, 2) * 2 == 6)
checar("recursao fatorial", fatorial(5) == 120)
checar("recursao fibonacci", fibonacci(10) == 55)
checar("recursao mutua", ehPar(10) e ehImpar(7))
checar("recursao profunda", profundidade(90) == 90)
checar("retorna dentro de laco", primeiroMultiplo(7) == 7)
incrementaAntesDeSair(Verdadeiro)
checar("vazio com retorna antecipado", contadorVazio == 1)
incrementaAntesDeSair(Falso)
checar("vazio ate o fim", contadorVazio == 12)
fimSecao("Funcoes")

# ---------- ESCOPOS ----------
int globalLida = 100
int globalAlterada = 1
int globalSombra = 5

int leGlobal()
{
	retorna globalLida
}

vazio alteraGlobal()
{
	globalAlterada = 2
}

int sombreia()
{
	int globalSombra = 50
	globalSombra = globalSombra + 1
	retorna globalSombra
}

int sombreiaParametro(int globalLida)
{
	retorna globalLida + 1
}

checar("funcao le global", leGlobal() == 100)
alteraGlobal()
checar("funcao altera global", globalAlterada == 2)
checar("local esconde global", sombreia() == 51)
checar("global continua igual", globalSombra == 5)
checar("parametro esconde global", sombreiaParametro(1) == 2)
checar("global apos parametro", globalLida == 100)
se(Verdadeiro)
{
	int criadaNoSe = 7
}
checar("variavel do se continua visivel", criadaNoSe == 7)
fimSecao("Escopos")

# ---------- VETORES ----------
Vetor de int numeros = [10, 20, 30]
Vetor de float flutuantes = [1, 2.5]
Vetor de bool logicos = [Verdadeiro, Falso]
Vetor de string palavras = ["a", "b"]
Vetor de Direcao direcoes = [Cima, Baixo, Direita, Esquerda]
Vetor de Ataque ataques = [EsferaAzul, EsferaVermelha, Raio, Gelo, Fogo, ExplosaoFogo, ExplosaoGelo, Alho]
Vetor de Arena arenas = [Campos, Floresta, Labirinto]
Vetor de Inimigo inimigos = [Goblin, Esqueleto, SlimeDeFogo, SlimeDeGelo, Lobisomem, Orc, Fantasma, Vampiro]
Vetor de string recursos = [Moeda, Osso, Couro, Magma, Cristal, Plasma, Sangue, Safira, Esmeralda, Diamante]
Vetor de string itens = [PocaoDeVida]
Vetor de int vazioInicial = []
Vetor de int comNulo = [1, Nulo, 3]
Vetor de int calculados = [1 + 1, somar(2, 2), numeros[0] * 2]

checar("ler primeiro", numeros[0] == 10)
checar("ler ultimo", numeros[2] == 30)
checar("indice por conta", numeros[1 + 1] == 30)
checar("fora do limite vale Nulo", numeros[99] == Nulo)
checar("float converte int", flutuantes[0] == 1.0)
checar("vetor de bool", logicos[0] e !logicos[1])
checar("vetor de string", palavras[1] == "b")
checar("vetor de Direcao", direcoes[3] == Esquerda)
checar("vetor de Ataque", ataques[7] == Alho)
checar("vetor de Arena", arenas[2] == Labirinto)
checar("vetor de Inimigo", inimigos[1] == Esqueleto)
checar("recursos", tamanho(recursos) == 10)
checar("itens", itens[0] == PocaoDeVida)
checar("tamanho de vetor vazio", tamanho(vazioInicial) == 0)
checar("Nulo como item", comNulo[1] == Nulo)
checar("itens com expressoes", calculados[0] == 2 e calculados[1] == 4 e calculados[2] == 20)
checar("tamanho de literal", tamanho([1, 2, 3]) == 3)
checar("texto do vetor", "" + numeros == "[10, 20, 30]")

numeros[1] = 25
checar("alterar item", numeros[1] == 25)
flutuantes[1] = 3
checar("float converte na atribuicao", flutuantes[1] == 3.0)
vazioInicial[0] = 5
checar("gravar em vetor vazio", tamanho(vazioInicial) == 1)
vazioInicial[4] = 9
checar("vetor cresce", tamanho(vazioInicial) == 5)
checar("buracos valem Nulo", vazioInicial[2] == Nulo)

Vetor de int indices = [2, 0, 1]
checar("indice vindo de vetor", numeros[indices[0]] == 30)

Vetor de int substituido = [1, 2, 3]
substituido = [7, 8]
checar("substituir vetor inteiro", tamanho(substituido) == 2 e substituido[1] == 8)
substituido = []
checar("substituir por vazio", tamanho(substituido) == 0)

int somaVetor(int lista)
{
	int soma = 0
	int posicao = 0
	enquanto(posicao < tamanho(lista))
	{
		soma = soma + lista[posicao]
		posicao = posicao + 1
	}
	retorna soma
}

vazio alteraPrimeiro(int lista)
{
	lista[0] = 99
}

vazio ordenar(int lista)
{
	int passada = 0
	enquanto(passada < tamanho(lista))
	{
		int atual = 0
		enquanto(atual < tamanho(lista) - 1 - passada)
		{
			se(lista[atual] > lista[atual + 1])
			{
				int guardado = lista[atual]
				lista[atual] = lista[atual + 1]
				lista[atual + 1] = guardado
			}
			atual = atual + 1
		}
		passada = passada + 1
	}
}

int vetorLocal()
{
	Vetor de int interno = [4, 5, 6]
	interno[0] = 1
	retorna interno[0] + interno[2]
}

Vetor de int paraSomar = [1, 2, 3, 4]
checar("vetor como parametro", somaVetor(paraSomar) == 10)
alteraPrimeiro(paraSomar)
checar("parametro altera o original", paraSomar[0] == 99)
checar("vetor local", vetorLocal() == 7)

Vetor de int desordenado = [5, 1, 4, 2, 3]
ordenar(desordenado)
checar("ordenacao", desordenado[0] == 1 e desordenado[2] == 3 e desordenado[4] == 5)

Vetor de int preenchido = []
int indicePreenche = 0
enquanto(indicePreenche < 10)
{
	preenchido[indicePreenche] = indicePreenche * indicePreenche
	indicePreenche = indicePreenche + 1
}
checar("preencher com laco", tamanho(preenchido) == 10 e preenchido[9] == 81)
fimSecao("Vetores")

# ---------- FUNCOES NATIVAS ----------
checar("max", max(1, 2) == 2)
checar("max float", perto(max(2.5, 1), 2.5))
checar("min", min(1, 2) == 1)
checar("min float", perto(min(2.5, 1), 1))
checar("trunca", trunca(2.9) == 2)
checar("trunca negativo", trunca(-2.9) == -2)
checar("trunca int", trunca(3) == 3)
int rodadasSorte = 0
bool sorteValida = Verdadeiro
enquanto(rodadasSorte < 20)
{
	float sorte = aleatorio()
	se(sorte < 0 ou sorte > 1)
	{
		sorteValida = Falso
	}
	rodadasSorte = rodadasSorte + 1
}
checar("aleatorio entre 0 e 1", sorteValida)
fimSecao("Funcoes nativas")

# ---------- JOGO DE VERDADE ----------
# Nao usa comprar, venderTudo nem usarItem, para nao mexer no save.
escreva("Entrando na arena para testar os sensores...")
arena(Campos)

checar("tempo", tempo() >= 0)
checar("vidaAtual", vidaAtual() > 0)
int jogadorX = posicaoX()
int jogadorY = posicaoY()
int baseTesouroX = tesouroX()
int baseTesouroY = tesouroY()
escreva("Jogador em " + jogadorX + ", " + jogadorY + " | tesouro em " + baseTesouroX + ", " + baseTesouroY)

Vetor de Direcao direcoesJogo = [Cima, Direita, Baixo, Esquerda]
int indiceDirecao = 0
enquanto(indiceDirecao < tamanho(direcoesJogo))
{
	Direcao direcaoTeste = direcoesJogo[indiceDirecao]
	bool livre = podeMover(direcaoTeste)
	checar("podeMover devolve bool", livre == Verdadeiro ou livre == Falso)
	se(livre)
	{
		mover(direcaoTeste)
	}
	indiceDirecao = indiceDirecao + 1
}

bool achouInimigo = Falso
enquanto(!achouInimigo e tempo() < 20)
{
	Inimigo alvo = inimigoMaisProximo()
	se(alvo != Nulo)
	{
		achouInimigo = Verdadeiro
	}
}

se(achouInimigo)
{
	checar("alvo.nome", alvo.nome != Nulo)
	checar("alvo.vida", alvo.vida > 0)
	checar("alvo.posicaoX", alvo.posicaoX != Nulo)
	checar("alvo.posicaoY", alvo.posicaoY != Nulo)
	checar("atributo direto da funcao", inimigoMaisProximo().nome != Nulo)
	checar("escanearArea", tamanho(escanearArea()) > 0)
	escreva("Inimigo encontrado: " + alvo)
	atacar(alvo, EsferaAzul)
}
senao
{
	escreva("Nenhum inimigo apareceu: testes de alvo pulados")
}
atacar(Nulo, EsferaAzul)
fimSecao("Jogo")

vazio resumoFinal()
{
	escreva("RESULTADO: " + (testes - falhas) + " de " + testes + " testes passaram")
}

resumoFinal()
escapar()
resumoFinal()

# ==================================================
# CASOS QUE DEVEM PARAR O CODIGO COM ERRO
# Descomente um bloco por vez e rode sozinho.
# ==================================================

# [ERRO] variavel nao declarada
# escreva(naoExiste)
#
# [ERRO] tipo errado na declaracao
# int errado = "texto"
#
# [ERRO] tipo errado na atribuicao
# int outroErrado = 1
# outroErrado = Verdadeiro
#
# [ERRO] variavel declarada duas vezes
# int repetida = 1
# int repetida = 2
#
# [ERRO] palavra reservada como nome
# int mover = 1
#
# [ERRO] lista sem Vetor de
# int lista = [1, 2]
#
# [ERRO] tipo errado em vetor
# Vetor de int misturado = [1, "a"]
#
# [ERRO] indice negativo
# Vetor de int negativo = [1]
# escreva(negativo[-1])
#
# [ERRO] condicao que nao e bool
# int condicaoRuim = 1
# se(condicaoRuim)
# {
# 	mover(Cima)
# }
#
# [ERRO] variavel local fora da funcao
# vazio criaLocal()
# {
# 	int soDentro = 1
# }
# criaLocal()
# escreva(soDentro)
#
# [ERRO] funcao chamada antes de ser declarada
# depois()
# vazio depois()
# {
# 	mover(Cima)
# }
#
# [ERRO] numero errado de argumentos
# int umParametro(int valor)
# {
# 	retorna valor
# }
# umParametro(1, 2)
#
# [ERRO] recursao infinita
# int semFim(int valor)
# {
# 	retorna semFim(valor)
# }
# semFim(1)
#
# [ERRO] retorna fora de funcao
# retorna
#
# [ERRO] bloco vazio
# se(Verdadeiro)
# {
# }
#
# [BUG CONHECIDO] hoje para com erro; deveria funcionar
# int comecaNulo = Nulo
# comecaNulo = 1
#
# [BUG CONHECIDO] hoje para com erro; deveria funcionar
# int recebeNulo = 1
# recebeNulo = Nulo
#
# [BUG CONHECIDO] hoje para com erro; deveria funcionar
# float comecaComInt = 3
# comecaComInt = 1.5
#
# [BUG CONHECIDO] funcao tipada nao consegue devolver Nulo
# Inimigo semInimigo()
# {
# 	retorna Nulo
# }
# Inimigo resultado = semInimigo()
#
# [BUG CONHECIDO] resultado de escanearArea nao cabe em variavel
# Inimigo area = escanearArea()"""
]

static func obter_codigo(indice: int) -> String:
	if indice >= 0 and indice < codigos_salvos.size():
		return codigos_salvos[indice]
	return ""
