extends Node

var ultimos_ataques: Array[String] = []
var ultimos_movimentos: Array[String] = []
const MAX_HISTORICO = 10

func registrar_ataque(nome_ataque: String):
	ultimos_ataques.append(nome_ataque)
	if ultimos_ataques.size() > MAX_HISTORICO:
		ultimos_ataques.pop_front()

func registrar_movimento(direcao: String):
	ultimos_movimentos.append(direcao.to_lower().strip_edges())
	if ultimos_movimentos.size() > MAX_HISTORICO:
		ultimos_movimentos.pop_front()

func resetar():
	ultimos_ataques.clear()
	ultimos_movimentos.clear()
