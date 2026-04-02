#arena(Floresta)
#Direcao dir = Esquerda

#enquanto(Verdadeiro):
	#se(podeMover(Esquerda) == Falso):
		#dir = Direita
	#fim se
	#se(podeMover(Direita) == Falso):
		#dir = Esquerda
	#fim se
	#mover(dir)
#fim enquanto
