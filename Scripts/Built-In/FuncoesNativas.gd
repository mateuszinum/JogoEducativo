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
	
	# Retorna apenas a STRING (o Nome/ID) do inimigo, e não o objeto em si
	static func inimigoMaisProximo() -> String:
		var tree = Engine.get_main_loop()
		var inimigos = tree.get_nodes_in_group("Enemy")
		var player = tree.get_first_node_in_group("Player")
		
		if inimigos.size() == 0 or not player:
			return "" # Retorna vazio se não tiver alvo
			
		var id_mais_proximo = ""
		var menor_distancia = INF
		var posicao_jogador = player.global_position
		
		for inimigo in inimigos:
			if is_instance_valid(inimigo):
				var distancia = posicao_jogador.distance_to(inimigo.global_position)
				if distancia < menor_distancia:
					menor_distancia = distancia
					id_mais_proximo = inimigo.name # <-- Captura a String Única
					
		return id_mais_proximo

	# Retorna um Array de STRINGS
	static func escanear_area() -> Array:
		var tree = Engine.get_main_loop()
		var inimigos = tree.get_nodes_in_group("Enemy")
		var player = tree.get_first_node_in_group("Player")
		
		if inimigos.size() == 0 or not player:
			return []
			
		var raio = 300.0
		var posicao_jogador = player.global_position
		var inimigos_proximos_ids = []
		
		for inimigo in inimigos:
			if is_instance_valid(inimigo):
				var distancia = posicao_jogador.distance_to(inimigo.global_position)
				if distancia <= raio:
					inimigos_proximos_ids.append(inimigo.name) # <-- Guarda a String
					
		return inimigos_proximos_ids

	# O utilitário que transforma o ID devolta na classe do inimigo para vermos o nome
	static func nomeInimigo(alvo_id: String) -> String:
		var tree = Engine.get_main_loop()
		var inimigos = tree.get_nodes_in_group("Enemy")
		
		for inimigo in inimigos:
			if is_instance_valid(inimigo) and inimigo.name == alvo_id:
				if "type" in inimigo and inimigo.type != null:
					return inimigo.type.title
				return "Inimigo Desconhecido"
				
		return ""

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
