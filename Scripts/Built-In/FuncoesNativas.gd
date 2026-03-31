extends Node

'''
Fazer
- entender geração do level para fazer a função arena()
'''

# Mapeamento de Inputs para Debug sem necessidade do backend
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_z"):
		FuncoesNativas.Partida.arena("Floresta")
		
		var mundo = get_tree().get_first_node_in_group("Mundo")
		if mundo and mundo.stage_data != null:
			print("O arquivo que está no Mundo agora é: ", mundo.stage_data.resource_path)	
	elif event.is_action_pressed("debug_x"):
		FuncoesNativas.Partida.arena("Genérico")

		var mundo = get_tree().get_first_node_in_group("Mundo")
		if mundo and mundo.stage_data != null:
			print("O arquivo que está no Mundo agora é: ", mundo.stage_data.resource_path)
			
	elif event.is_action_pressed("debug_c"):
		var livre = Jogador.podeMover("Direita")
		if livre:
			print("caminho livre")
		else:
			print("tem uma parede")

	elif event.is_action_pressed("debug_v"):
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

	#Função nomeInimigo(alvo)
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
	
	# Função arena(nomeDaArena)
	static func arena(nome_arena: String):
		const DIRETORIO_BASE = "res://Resources/Stages/"
		
		var caminho_completo = DIRETORIO_BASE + nome_arena + "/" + nome_arena + "_data.tres"
		var dados_da_arena
		
		if ResourceLoader.exists(caminho_completo):
			dados_da_arena = load(caminho_completo)
		else:
			printerr("ERRO: Os dados da arena '%s' não foram encontrados no caminho: %s" % [nome_arena, caminho_completo])
			return null
		
		var mundo = Engine.get_main_loop().get_first_node_in_group("Mundo")
		
		if dados_da_arena != null:
			mundo.stage_data = dados_da_arena

	# Função tesouro() (Ver Pedro)
	
class Jogador:
	# Função vidaAtual()
	static func vida_atual():
		var player = Engine.get_main_loop().get_first_node_in_group("Player")
		if player:
			return player.health
		return 0.0
	
	# Função mover(direcao)
	static func mover(direcao):
		var player = Engine.get_main_loop().get_first_node_in_group("Player")

		if not player:
			return

		if direcao == Vector2.ZERO or player.moving:
			return

		var raycast = player.get_node("RayCast2D")
		raycast.target_position = direcao * player.tile_size
		raycast.force_raycast_update()

		if raycast.is_colliding():
			return 

		if direcao.x != 0:
			player.anim.flip_h = (direcao.x < 0)
		
		player.moving = true

		if player.step_sound != null:
			var audio = AudioStreamPlayer2D.new()
			audio.stream = player.step_sound
			audio.volume_db = player.step_volume
			audio.global_position = player.global_position
			audio.pitch_scale = randf_range(player.step_pitch_min, player.step_pitch_max)
			player.get_parent().add_child(audio)
			audio.play()
			audio.finished.connect(audio.queue_free)

		var tween = player.create_tween()
		tween.tween_property(player, "position", player.position + direcao * player.tile_size, player.TEMPO_DE_PASSO)
		tween.tween_callback(player.move_false)

		var squash_tween = player.create_tween()
		squash_tween.tween_property(player.anim, "scale", Vector2(1.6, 0.6), player.TEMPO_ANIMACAO / 2.0)
		squash_tween.tween_property(player.anim, "scale", Vector2(1.0, 1.0), player.TEMPO_ANIMACAO / 2.0)

	# Função escapar()
	static func escapar() -> void:
		Engine.get_main_loop().paused = false
		Engine.get_main_loop().change_scene_to_file("res://Scenes/UI/jogo.tscn")

	# Função posicao()
	static func posicao():
		var tree = Engine.get_main_loop()
		var player = tree.get_first_node_in_group("Player")
		var tilemap = tree.get_first_node_in_group("Mapa")

		if not player or not tilemap:
			return Vector2.ZERO

		var coordenada_jogador = tilemap.local_to_map(player.global_position)
		return coordenada_jogador

	# Função podeMover(direcao)
	static func podeMover(direcao: String) -> bool:
		var tree = Engine.get_main_loop()
		var player = tree.get_first_node_in_group("Player")

		var vetor_dir := Vector2.ZERO
		
		match direcao.to_lower(): 
			"cima": vetor_dir = Vector2.UP
			"baixo": vetor_dir = Vector2.DOWN
			"esquerda": vetor_dir = Vector2.LEFT
			"direita": vetor_dir = Vector2.RIGHT
			_:
				printerr("ERRO: Direção inválida em podeMover(). Use 'Cima', 'Baixo', 'Esquerda' ou 'Direita'.")
				return false

		var tile_size = 32.0 
		var origem = player.global_position
		var destino = origem + (vetor_dir * tile_size)

		var space_state = player.get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(origem, destino)

		var resultado = space_state.intersect_ray(query)

		if not resultado.is_empty():
			return false

		return true

#class Equipamento:
# Função cinto.usarItem(indice) (Não precisa agr)

# Função mochila.usarItem() (Não precisa agr)

# Função cinto.colocarItem(item, indice) (Não precisa agr)

# Função mochila.colocarItem(item) (Não precisa agr)

# Função comprar(produto) (Não precisa agr)
