extends Node

var _cache_inimigo_proximo: String = ""
var _cache_pode_mover: Dictionary = {
	"cima": false, "baixo": false, "esquerda": false, "direita": false
}
var _coordenada_logica_atual := Vector2i(0, 0)
var _posicao_inicializada := false

func _physics_process(_delta: float) -> void:
	var tree = get_tree()
	var player = tree.get_first_node_in_group("Player")
	var tile_map = tree.get_first_node_in_group("Mapa")
	var inimigos = tree.get_nodes_in_group("Enemy")
	
	if player and tile_map and player.is_inside_tree():
		if not _posicao_inicializada:
			_coordenada_logica_atual = tile_map.local_to_map(player.global_position)
			_posicao_inicializada = true
		
		var direcoes_vetores = {
			"cima": Vector2i(0, -1),
			"baixo": Vector2i(0, 1),
			"esquerda": Vector2i(-1, 0),
			"direita": Vector2i(1, 0)
		}
		
		for dir_nome in direcoes_vetores:
			var coord_destino = _coordenada_logica_atual + direcoes_vetores[dir_nome]
			
			var tem_chao = tile_map.get_cell_source_id(0, coord_destino) != -1
			var sem_obstaculo = tile_map.get_cell_source_id(1, coord_destino) == -1
			
			_cache_pode_mover[dir_nome] = tem_chao and sem_obstaculo

# ==========================================
# PORTAS DE ENTRADA DO C# (API GATEWAY)
# ==========================================

func jogoEstaPronto() -> bool:
	return _posicao_inicializada

func mover(direcao: String):
	Jogador.mover_via_codigo(direcao)

func atacar(alvo: String, tipo: String):
	Jogador.atacar(alvo, tipo)

func escapar():
	Partida.escapar()

func usar_item_cinto(indice: int):
	Inventario.usar_item_cinto(indice)

func usar_item_mochila():
	Inventario.usar_item_mochila()

func comprar(item: String):
	Vilarejo.comprar(item)

func arena(nome_arena: String):
	Partida.arena(nome_arena)

func colocar_item_mochila(item: String):
	Inventario.colocar_item_mochila(item)

func colocar_item_cinto(item: String, idx: int):
	Inventario.colocar_item_cinto(item, idx)

func inimigoMaisProximo() -> String:
	return _cache_inimigo_proximo

func podeMover(direcao: String) -> bool:
	var dir_limpa = direcao.to_lower().strip_edges() 
	var resultado = false
	
	if _cache_pode_mover.has(dir_limpa): 
		resultado = _cache_pode_mover[dir_limpa] 
	
	print("[DEBUG C#] O agente perguntou se pode mover para '", dir_limpa, "' -> Godot respondeu: ", resultado)
	
	return resultado

func getTempo() -> int:
	return Partida.getTempo()

func getVidaAtual() -> int:
	return Jogador.getVidaAtual()

func escanearArea() -> Array:
	return Inimigo.escanear_area()

func posicaoX() -> int:
	return Jogador.posicaoX()

func posicaoY() -> int:
	return Jogador.posicaoY()

func tesouroX() -> int:
	return Partida.tesouroX()

func tesouroY() -> int:
	return Partida.tesouroY()


# ==========================================
# LÓGICA INTERNA DAS CLASSES
# ==========================================

class Inimigo:
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
					inimigos_proximos_ids.append(inimigo.name) 
		return inimigos_proximos_ids

	static func nomeInimigo(alvo_id: String) -> String:
		var tree = Engine.get_main_loop()
		var inimigos = tree.get_nodes_in_group("Enemy")
		for inimigo in inimigos:
			if is_instance_valid(inimigo) and inimigo.name == alvo_id:
				if "type" in inimigo and inimigo.type != null:
					return inimigo.type.nome
				return "Inimigo Desconhecido"
		return ""


class Partida:
	static var em_arena: bool = false

	static func escapar():
		if not em_arena:
			return
		em_arena = false
		print("Escapando da arena e voltando pro Vilarejo...")
		
		var tree = Engine.get_main_loop()
		var jogo_main = tree.root.get_node_or_null("Jogo")
		if jogo_main and jogo_main.has_method("fazer_transicao_tv"):
			jogo_main.fazer_transicao_tv(jogo_main.CENA_VILAREJO, "vilarejo")

	static func getTempo():
		return 0

	static func tesouro():
		var tree = Engine.get_main_loop()
		var tilemap = tree.get_first_node_in_group("Mapa")
		if not tilemap: return null
		for x in range(50):
			for y in range(50):
				var coord = Vector2i(x, y)
				var tile_data = tilemap.get_cell_tile_data(0, coord)
				if tile_data and tile_data.get_custom_data("is_treasure"): 
					return coord 
		return null

	static func tesouroX():
		var pos = tesouro()
		return pos.x if pos != null else -1

	static func tesouroY():
		var pos = tesouro()
		return pos.y if pos != null else -1

	static func arena(nome: String):
		var tree = Engine.get_main_loop()
		
		if em_arena:
			tree.call_group("Terminal", "mostrar_erro", "Você já está em uma arena!\nUse a interface para escapar primeiro.")
			return
			
		var jogo_main = tree.root.get_node_or_null("Jogo")
		if not jogo_main:
			printerr("ERRO: Cena principal 'Jogo' não encontrada.")
			return
		var novo_stage_data = ArenasDB.get_stage_data(nome)

		if novo_stage_data != null:
			em_arena = true
			
			FuncoesNativas._posicao_inicializada = false 
			
			if jogo_main.has_method("carregar_arena_via_codigo"):
				jogo_main.carregar_arena_via_codigo(novo_stage_data)
			else:
				printerr("ERRO: Função 'carregar_arena_via_codigo' não encontrada em jogo.gd")
		else:
			tree.call_group("Terminal", "mostrar_erro", "A arena '" + nome + "' não foi encontrada no banco de dados.")


class Inventario:
	static func usar_item_mochila(): pass
	static func usar_item_cinto(index): pass
	static func colocar_item_mochila(item): pass
	static func colocar_item_cinto(item, index): pass


class Vilarejo:
	static func comprar(item): pass


class Jogador:
	static func mover_via_codigo(direcao: String) -> void:
		var dir_limpa = direcao.to_lower().strip_edges()
		
		# Verifica se o movimento atual é válido com base no cache atual
		if FuncoesNativas._cache_pode_mover.has(dir_limpa) and FuncoesNativas._cache_pode_mover[dir_limpa]:
			
			var direcoes_vetores = {
				"cima": Vector2i(0, -1),
				"baixo": Vector2i(0, 1),
				"esquerda": Vector2i(-1, 0),
				"direita": Vector2i(1, 0)
			}
			
			FuncoesNativas._coordenada_logica_atual += direcoes_vetores[dir_limpa]
			
			var tree = Engine.get_main_loop()
			var tile_map = tree.get_first_node_in_group("Mapa")
			
			if tile_map:
				for dir_nome in direcoes_vetores:
					var coord_futura = FuncoesNativas._coordenada_logica_atual + direcoes_vetores[dir_nome]
					
					var tem_chao = tile_map.get_cell_source_id(0, coord_futura) != -1
					var sem_obstaculo = tile_map.get_cell_source_id(1, coord_futura) == -1
					var caminho_livre = tem_chao and sem_obstaculo
					
					FuncoesNativas._cache_pode_mover[dir_nome] = caminho_livre
			
			# 2. ATUALIZA O FRONT-END: Manda o boneco deslizar na tela
			mover(direcao)
		else:
			print("\n[Debug] O agente tentou ir para '", dir_limpa, "', mas bateu na parede/abismo!")
		
	static func mover(direcao: String) -> void:
		var tree = Engine.get_main_loop()
		var player = tree.get_first_node_in_group("Player")
		if not player: return

		var vetor_dir := Vector2.ZERO
		match direcao.to_lower():
			"cima": vetor_dir = Vector2.UP
			"baixo": vetor_dir = Vector2.DOWN
			"esquerda": vetor_dir = Vector2.LEFT
			"direita": vetor_dir = Vector2.RIGHT
		
		if vetor_dir != Vector2.ZERO:
			player.input_dir = vetor_dir
			player.move()

	static func posicaoX():
		var coord = posicao()
		return coord.x if coord != null else -1

	static func posicaoY():
		var coord = posicao()
		return coord.y if coord != null else -1

	static func posicao():
		var tree = Engine.get_main_loop()
		var player = tree.get_first_node_in_group("Player")
		var tilemap = tree.get_first_node_in_group("Mapa")
		if not player or not tilemap: return Vector2.ZERO
		return tilemap.local_to_map(player.global_position)

	static func atacar(alvo_id: String, tipo_ataque: String):
		var tree = Engine.get_main_loop()
		var player = tree.get_first_node_in_group("Player")
		var inimigos = tree.get_nodes_in_group("Enemy")
		
		if not player:
			return
		
		var ataque_data = AtaquesDB.get_ataque(tipo_ataque)
		
		if ataque_data == null:
			tree.call_group("Terminal", "mostrar_erro", "O ataque '" + tipo_ataque + "' não foi encontrado no grimório.")
			return
			
		var alvo_encontrado = false
		
		for inimigo in inimigos:
			if is_instance_valid(inimigo) and inimigo.name == alvo_id:
				alvo_encontrado = true
				print("[FuncoesNativas] Disparando projétil no alvo ", alvo_id, " com: ", ataque_data.nome)
				
				if ataque_data.projectile_node != null:
					var projetil = ataque_data.projectile_node.instantiate()
					
					projetil.global_position = player.global_position
					projetil.direction = player.global_position.direction_to(inimigo.global_position)
					projetil.rotation = projetil.direction.angle()
					
					projetil.speed = ataque_data.speed
					projetil.damage = ataque_data.damage
					projetil.knockback_multiplier = ataque_data.knockback_multiplier
					
					if "hit_sound" in projetil:
						projetil.hit_sound = ataque_data.hit_sound
						projetil.hit_volume = ataque_data.hit_volume
						projetil.pitch_min = ataque_data.pitch_min
						projetil.pitch_max = ataque_data.pitch_max
							
					player.get_parent().add_child(projetil)
					
					if ataque_data.attack_sound != null:
						var audio = AudioStreamPlayer2D.new()
						audio.stream = ataque_data.attack_sound
						audio.volume_db = ataque_data.attack_volume
						audio.global_position = player.global_position
						audio.pitch_scale = randf_range(ataque_data.pitch_min, ataque_data.pitch_max)
						player.get_parent().add_child(audio)
						audio.play()
						audio.finished.connect(audio.queue_free)
						
				return
				
		if not alvo_encontrado:
			print("[FuncoesNativas] O ataque falhou. O alvo '", alvo_id, "' não está mais na arena.")
				
	static func getVidaAtual() -> int:
		var tree = Engine.get_main_loop()
		var player = tree.get_first_node_in_group("Player")
		if player and "health" in player:
			return player.health
		return 0
