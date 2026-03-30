extends Node

'''
Bugs
- tempo() e vida_atual() não estão funcionando
- inimigo mais próximo dando "BreakPoint"
'''


# Mapeamento de Inputs para Debug sem necessidade do backend
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_z"):
		print("apertou z")
		print(Partida.tempo())
		
	elif event.is_action_pressed("debug_x"):
		print("apertou x")
		print(Jogador.vida_atual())
		
	elif event.is_action_pressed("debug_c"):
		print("apertou c")
		print(Inimigo.escanearArea())
		
	elif event.is_action_pressed("debug_v"):
		print("apertou v")
		print(Inimigo.nomeInimigo(Inimigo.inimigoMaisProximo()))

class Inimigo:
	# Função inimigoMaisProximo()
	static func inimigoMaisProximo() -> CharacterBody2D:
		var tree = Engine.get_main_loop()
		
		var inimigos = tree.get_nodes_in_group("Enemy")
		if inimigos.is_empty():
			return null
		
		var player = tree.get_first_node_in_group("Player")
		if not player:
			return null
			
		var pos_jogador = player.global_position

		var mais_proximo: CharacterBody2D = null
		var menor_distancia := INF

		for inimigo in inimigos:
			if not is_instance_valid(inimigo):
				continue

			# Compara a distância do jogador até o inimigo atual
			var distancia = pos_jogador.distance_squared_to(inimigo.global_position)
			if distancia < menor_distancia:
				menor_distancia = distancia
				mais_proximo = inimigo

		return mais_proximo
		
	# Função escanearArea()
	static func escanearArea():
		var tree = Engine.get_main_loop()
			
		var inimigos = tree.get_nodes_in_group("Enemy")
		if inimigos.is_empty():
			return null
		
		return inimigos

	# Função nomeInimigo(alvo)
	static func nomeInimigo(alvo: CharacterBody2D):
		if is_instance_valid(alvo) and "type" in alvo and alvo.type != null:
			return alvo.type.nome

class Partida:
	# Função tempo()
	static func tempo() -> Array:
		var spawner = Engine.get_main_loop().get_first_node_in_group("Spawner")
		if spawner:
			var total = spawner.total_time_seconds
			var m = total / 60
			var s = total % 60
			return [m, s]
		return [0, 0]
	
	# Função arena(nomeDaArena) (Entender como que funciona para mudar a cena da arena)
	#func arena(nome_arena: String):
		#const DIRETORIO_BASE = "res://Resources/Stages"
		#var caminho_completo = DIRETORIO_BASE + nome_arena + "/" + nome_arena + "_data.tres"
#
		#if ResourceLoader.exists(caminho_completo):
			#var dados_da_arena = load(caminho_completo)
		#else:
			#printerr("ERRO: Os dados da arena '%s' não foram encontrados no caminho: %s" % [nome_arena, caminho_completo])
			#return null
		
	# Função tesouro() (Ver Pedro)
	
class Jogador:
	# Função vidaAtual()
	static func vida_atual():
		var player = Engine.get_main_loop().get_first_node_in_group("Player")
		if player:
			return player.health
		return 0.0
	
	# Função mover(direcao)

	# Função escapar()
	static func escapar() -> void:
		Engine.get_main_loop().paused = false
		Engine.get_main_loop().change_scene_to_file("res://Scenes/UI/jogo.tscn")

	# Função posicao() (Ver Pedro)
	
	# Função podeMover(direcao)
	
#class Equipamento:
# Função cinto.usarItem(indice) (Não precisa agr)

# Função mochila.usarItem() (Não precisa agr)

# Função cinto.colocarItem(item, indice) (Não precisa agr)

# Função mochila.colocarItem(item) (Não precisa agr)

# Função comprar(produto) (Não precisa agr)
