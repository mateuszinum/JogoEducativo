# HistoricoAtaques.gd
extends Node

var ultimos_ataques: Array[String] = []
const MAX_HISTORICO = 10

func registrar(nome_ataque: String):
	ultimos_ataques.append(nome_ataque)
	if ultimos_ataques.size() > MAX_HISTORICO:
		ultimos_ataques.pop_front()

func resetar():
	ultimos_ataques.clear()
