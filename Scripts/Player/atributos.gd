extends Node

var max_health : int = 50
var global_knockback_multiplier : float = 1.0
var tempo_tick : float = 0.8

var ganhos_health = [4, 6, 8]
var ganhos_kb = [1.5, 2.0, 3.0]
var ganhos_agilidade = [0.6, 0.4, 0.2]

func comprar_upgrade(nome_upgrade, nivel_atual):
	match nome_upgrade:
		"Agilidade":
			var novo_valor = ganhos_agilidade[nivel_atual - 2]
	
			tempo_tick = novo_valor
			print("Upgrade Nível ", nivel_atual, "! Agilidade está em:", novo_valor)
		
		"Vida Máxima":
			var valor_adicional = ganhos_health[nivel_atual - 2]
	
			max_health += valor_adicional
			print("Upgrade Nível ", nivel_atual, "! Ganhou +", valor_adicional, " de Vida.")
			
		"Knockback":
			var novo_valor = ganhos_kb[nivel_atual - 2]
	
			global_knockback_multiplier = novo_valor
			print("Upgrade Nível ", nivel_atual, "! Multiplicador de knockback está em: ", novo_valor)
