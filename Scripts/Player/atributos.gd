extends Node

var max_health : int = 50
var global_knockback_multiplier : float = 1.0
var tempo_tick : float = 0.8
var coleta_multiplier : float = 1.0
var forca_multiplier : float = 1.0

var ganhos_health = [4, 6, 8]
var ganhos_kb = [1.5, 2.0, 3.0]
var ganhos_agilidade = [0.7, 0.5, 0.3]
var ganhos_coleta = [2.0, 3.0, 4.0]
var ganhos_forca = [1.5, 2.0, 3.0]

# ------------------------------------- #

var multiplicador_labirinto : float = 1.0

func GetTempoTick():
	return tempo_tick / multiplicador_labirinto

func comprar_upgrade(nome_upgrade, nivel_atual):
	match nome_upgrade:
		"Agilidade":
			var novo_valor = ganhos_agilidade[nivel_atual - 2]
	
			tempo_tick = novo_valor
			if Constantes.DEBUG: print("Upgrade Nível ", nivel_atual, "! Agilidade está em:", novo_valor)
		
		"Vida Máxima":
			var valor_adicional = ganhos_health[nivel_atual - 2]
	
			max_health += valor_adicional
			if Constantes.DEBUG: print("Upgrade Nível ", nivel_atual, "! Ganhou +", valor_adicional, " de Vida.")
			
		"Knockback":
			var novo_valor = ganhos_kb[nivel_atual - 2]
	
			global_knockback_multiplier = novo_valor
			if Constantes.DEBUG: print("Upgrade Nível ", nivel_atual, "! Multiplicador de knockback está em: ", novo_valor, " x")
		
		"Coleta":
			var novo_valor = ganhos_coleta[nivel_atual - 2]
	
			coleta_multiplier = novo_valor
			if Constantes.DEBUG: print("Upgrade Nível ", nivel_atual, "! Multiplicador de Coleta está em: ", novo_valor, " x")
		
		"Força":
			var novo_valor = ganhos_forca[nivel_atual - 2]
	
			forca_multiplier = novo_valor
			if Constantes.DEBUG: print("Upgrade Nível ", nivel_atual, "! Multiplicador de Força está em: ", novo_valor, " x")

func maximizar_agilidade() -> void:
	tempo_tick = ganhos_agilidade[-1]
	if Constantes.DEBUG: print("A agilidade foi maximizada!")

func resetar_multiplicador_labirinto(valor: float) -> void:
	multiplicador_labirinto = valor

func incrementar_multiplicador_labirinto(incremento: float, valor_maximo: float) -> void:
	multiplicador_labirinto += incremento
	if multiplicador_labirinto > valor_maximo:
		multiplicador_labirinto = valor_maximo
		
	if Constantes.DEBUG: print("Incremento! tempo_tick atual: ", GetTempoTick())
	
func debug_tempo_tick():
	print(GetTempoTick())
