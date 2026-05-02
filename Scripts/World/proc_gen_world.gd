extends Node2D

@export var stage_data: StageData
@export var cena_tesouro: PackedScene
@onready var tile_map = $TileMap
@onready var camera_2d = $Player/Camera2D

var seed_hash: int
var recursos_iniciais: Dictionary

func _ready():
	randomize()
	seed_hash = randi()
	seed(seed_hash)
	generate_world()
	if Constantes.TOCAR_MUSICA:
		play_stage_music()
	if not Constantes.USAR_EFEITOS_TELA:
		if has_node("PosProcessamento"):
			$PosProcessamento.hide()

func generate_world():
	if not stage_data:
		return
		
	if has_node("%Escuridao"):
		var escuridao = get_node("%Escuridao")
		escuridao.color = stage_data.cor_escuridao
		
	var player_luz = get_tree().get_first_node_in_group("Player")
	if player_luz and player_luz.has_node("%LuzPlayer"):
		var luz = player_luz.get_node("%LuzPlayer")
		luz.enabled = stage_data.ativar_luz_player
		
	if has_node("Spawner"):
		var spawner = $Spawner
		spawner.current_stage = stage_data
		spawner.total_time_seconds = 0
		spawner.active_spawns.clear()
		if spawner.has_node("Timer"):
			spawner.get_node("Timer").start()
		
	if stage_data.stage_tileset:
		tile_map.tile_set = stage_data.stage_tileset
	
	tile_map.clear()
	
	if stage_data.tipo_mapa == StageData.TipoMapa.LABIRINTO:
		_gerar_modo_labirinto()
		_configurar_visibilidade_ui(false) 
		Atributos.resetar_multiplicador_labirinto(stage_data.labirinto_multiplicador_inicial) 
	else:
		_gerar_modo_arena()
		_configurar_visibilidade_ui(true)
		Atributos.resetar_multiplicador_labirinto(1.0)
		
	recursos_iniciais = RecursosManager.listarRecursos().duplicate()	
	var player = get_tree().get_first_node_in_group("Player")
	if not player.is_connected("vida_zerada", _on_player_morreu):
		player.connect("vida_zerada", _on_player_morreu)
	
	if stage_data.tipo_mapa == StageData.TipoMapa.LABIRINTO:
		if player.has_method("configurar_modo_labirinto"):
			player.configurar_modo_labirinto(stage_data.recurso_destaque_labirinto)
	else:
		if player.has_method("configurar_modo_arena"):
			player.configurar_modo_arena()
	
	gerar_tesouro()

func _gerar_modo_arena():
	var centro_grid_x = 0
	var centro_grid_y = 0
	var centro_vetor_grid = Vector2(centro_grid_x, centro_grid_y)
	
	@warning_ignore("integer_division")
	var metade_largura = stage_data.map_width / 2
	@warning_ignore("integer_division")
	var metade_altura = stage_data.map_height / 2
	
	for x in range(-metade_largura, metade_largura):
		for y in range(-metade_altura, metade_altura):
			tile_map.set_cell(0, Vector2i(x, y), stage_data.get_random_ground_id(), Vector2i(0, 0))
	
	var grid_obstaculos = {} 
	
	for regra in stage_data.spawn_rules:
		if regra.source_ids.is_empty() or regra.frequencia <= 0.0:
			continue
			
		var malha_temporaria = {}
		var centros_clusters = [] 
		
		var area_total = stage_data.map_width * stage_data.map_height
		var tiles_alvo = int(area_total * regra.frequencia)
		var tiles_gerados = 0
		var tentativas = 0
		
		while tiles_gerados < tiles_alvo and tentativas < 2000:
			tentativas += 1
			var rx = randi_range(-metade_largura, metade_largura - 1)
			var ry = randi_range(-metade_altura, metade_altura - 1)
			var pos_inicial = Vector2i(rx, ry)
			
			if regra.eh_barreira and Vector2(pos_inicial).distance_to(centro_vetor_grid) <= stage_data.raio_seguro_spawn:
				continue
			if grid_obstaculos.has(pos_inicial) or malha_temporaria.has(pos_inicial):
				continue
				
			var muito_perto = false
			for centro in centros_clusters:
				if Vector2(pos_inicial).distance_to(Vector2(centro)) < regra.distancia_minima_clusters:
					muito_perto = true
					break
			
			if muito_perto:
				continue 
				
			var tamanho_sorteado = randi_range(regra.cluster_min, regra.cluster_max)
			
			var novo_cluster = _gerar_cluster_conectado(
				pos_inicial, tamanho_sorteado, grid_obstaculos, malha_temporaria, 
				metade_largura, metade_altura, stage_data.raio_seguro_spawn, 
				centro_vetor_grid, regra.eh_barreira, regra.cluster_redondo
			)
			
			for pos in novo_cluster:
				malha_temporaria[pos] = true
			
			centros_clusters.append(pos_inicial) 
			tiles_gerados += novo_cluster.size()

		for pos in malha_temporaria:
			grid_obstaculos[pos] = {
				"usa_autotile": regra.usa_autotile,
				"id": regra.source_ids.pick_random() if not regra.usa_autotile else -1,
				"terrain_set": regra.terrain_set,
				"terrain_id": regra.terrain_id,
				"nome": regra.nome_obstaculo
			}
			
		if not regra.afastar_obstaculos.is_empty():
			var remover = []
			for pos in malha_temporaria:
				for dx in [-1, 0, 1]:
					for dy in [-1, 0, 1]:
						var vizinho = pos + Vector2i(dx, dy)
						if grid_obstaculos.has(vizinho):
							if grid_obstaculos[vizinho].nome in regra.afastar_obstaculos:
								remover.append(vizinho)
			for p in remover: grid_obstaculos.erase(p)

	var terrenos_para_conectar = {}
	
	for pos in grid_obstaculos:
		var obs = grid_obstaculos[pos]
		if obs.usa_autotile:
			var key = str(obs.terrain_set) + "_" + str(obs.terrain_id)
			if not terrenos_para_conectar.has(key):
				terrenos_para_conectar[key] = []
			terrenos_para_conectar[key].append(pos)
		else:
			tile_map.set_cell(1, pos, obs.id, Vector2i(0, 0))
			
		tile_map.erase_cell(0, pos)
		
	for key in terrenos_para_conectar:
		var partes = key.split("_")
		var t_set = int(partes[0])
		var t_id = int(partes[1])
		tile_map.set_cells_terrain_connect(1, terrenos_para_conectar[key], t_set, t_id)
		
	var player = get_tree().get_first_node_in_group("Player")
	player.position = tile_map.map_to_local(Vector2i(0, 0)) + Vector2(8, 8)
	
	if camera_2d:
		camera_2d.top_level = false
		camera_2d.position = Vector2.ZERO 
		camera_2d.zoom = Vector2(1.6, 1.6)

func _gerar_modo_labirinto(manter_posicao_jogador: bool = false):
	var w = stage_data.labirinto_largura
	var h = stage_data.labirinto_altura
	
	if w % 2 == 0: w += 1
	if h % 2 == 0: h += 1
	
	stage_data.map_width = w
	stage_data.map_height = h
	
	@warning_ignore("integer_division")
	var offset_x = -w / 2
	@warning_ignore("integer_division")
	var offset_y = -h / 2
	
	var player = get_tree().get_first_node_in_group("Player")
	
	var px = 1
	var py = 1
	var input_x = 0
	var input_y = 0
	
	if manter_posicao_jogador and player:
		var pos_atual_grid = tile_map.local_to_map(player.position)
		px = clamp(pos_atual_grid.x - offset_x, 1, w - 2)
		py = clamp(pos_atual_grid.y - offset_y, 1, h - 2)
		if player.get("input_dir") != null and player.input_dir != Vector2.ZERO:
			input_x = int(player.input_dir.x)
			input_y = int(player.input_dir.y)

	var maze = []
	for x in range(w):
		maze.append([])
		for y in range(h):
			maze[x].append(1)
			
	var stack = []
	
	var blocos_protegidos = [Vector2i(px, py)]
	if input_x != 0 or input_y != 0:
		blocos_protegidos.append(Vector2i(clamp(px - input_x, 1, w - 2), clamp(py - input_y, 1, h - 2)))
		blocos_protegidos.append(Vector2i(clamp(px + input_x, 1, w - 2), clamp(py + input_y, 1, h - 2)))

	for bloco in blocos_protegidos:
		var bx = bloco.x
		var by = bloco.y
		maze[bx][by] = 0
		
		if bx % 2 != 0 and by % 2 != 0:
			if not stack.has(Vector2i(bx, by)): stack.append(Vector2i(bx, by))
		elif bx % 2 == 0 and by % 2 != 0:
			maze[bx-1][by] = 0
			maze[bx+1][by] = 0
			if not stack.has(Vector2i(bx-1, by)): stack.append(Vector2i(bx-1, by))
			if not stack.has(Vector2i(bx+1, by)): stack.append(Vector2i(bx+1, by))
		elif bx % 2 != 0 and by % 2 == 0:
			maze[bx][by-1] = 0
			maze[bx][by+1] = 0
			if not stack.has(Vector2i(bx, by-1)): stack.append(Vector2i(bx, by-1))
			if not stack.has(Vector2i(bx, by+1)): stack.append(Vector2i(bx, by+1))
		else:
			maze[bx-1][by-1] = 0
			if not stack.has(Vector2i(bx-1, by-1)): stack.append(Vector2i(bx-1, by-1))
			
	while stack.size() > 0:
		var atual = stack.back()
		var dirs = [Vector2i(0, -2), Vector2i(0, 2), Vector2i(-2, 0), Vector2i(2, 0)]
		var vizinhos_possiveis = []
		
		for d in dirs:
			var nx = atual.x + d.x
			var ny = atual.y + d.y
			if nx > 0 and nx < w - 1 and ny > 0 and ny < h - 1:
				if maze[nx][ny] == 1:
					vizinhos_possiveis.append(d)
					
		if vizinhos_possiveis.size() > 0:
			var dir = vizinhos_possiveis.pick_random()
			maze[atual.x + dir.x/2][atual.y + dir.y/2] = 0 
			maze[atual.x + dir.x][atual.y + dir.y] = 0
			stack.append(Vector2i(atual.x + dir.x, atual.y + dir.y))
		else:
			stack.pop_back()
			
	if manter_posicao_jogador and player:
		var pos_atual_grid = tile_map.local_to_map(player.position)
		var gx = clamp(pos_atual_grid.x - offset_x, 1, w - 2)
		var gy = clamp(pos_atual_grid.y - offset_y, 1, h - 2)
		
		maze[gx][gy] = 0
		
		if player.get("input_dir") != null and player.input_dir != Vector2.ZERO:
			var dir_x = int(player.input_dir.x)
			var dir_y = int(player.input_dir.y)
			
			var prev_x = clamp(gx - dir_x, 1, w - 2)
			var prev_y = clamp(gy - dir_y, 1, h - 2)
			var next_x = clamp(gx + dir_x, 1, w - 2)
			var next_y = clamp(gy + dir_y, 1, h - 2)
			
			maze[prev_x][prev_y] = 0
			maze[next_x][next_y] = 0		
	
	var paredes_labirinto = []
	
	for x in range(w):
		for y in range(h):
			var pos = Vector2i(x + offset_x, y + offset_y)
			tile_map.set_cell(0, pos, stage_data.get_random_ground_id(), Vector2i(0, 0))
			
			if maze[x][y] == 1:
				paredes_labirinto.append(pos)
				
	tile_map.set_cells_terrain_connect(1, paredes_labirinto, stage_data.labirinto_terrain_set, stage_data.labirinto_terrain_id)
	
	if not manter_posicao_jogador and player:
		var pos_player_grid = Vector2i(1 + offset_x, 1 + offset_y)
		player.position = tile_map.map_to_local(pos_player_grid) + Vector2(8, 8)
		
		if camera_2d:
			camera_2d.top_level = true
			@warning_ignore("integer_division")
			var centro_grid = Vector2i(offset_x + w/2, offset_y + h/2)
			var posicao_centro = tile_map.map_to_local(centro_grid)
			camera_2d.global_position = posicao_centro + stage_data.labirinto_offset_camera
			camera_2d.zoom = stage_data.labirinto_zoom_camera

func _gerar_cluster_conectado(inicio: Vector2i, tamanho_exato: int, grid_global: Dictionary, grid_regra: Dictionary, lim_x: int, lim_y: int, safe_radius: float, centro: Vector2, eh_barreira: bool, redondo: bool) -> Dictionary:
	var cluster = {}
	var fronteira = [inicio]
	var direcoes = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
	
	cluster[inicio] = true
	
	while cluster.size() < tamanho_exato and fronteira.size() > 0:
		var idx = 0
		if redondo:
			var menor_dist = INF
			for i in range(fronteira.size()):
				var dist = Vector2(fronteira[i]).distance_squared_to(Vector2(inicio))
				if dist < menor_dist:
					menor_dist = dist
					idx = i
		else:
			idx = randi() % fronteira.size()
			
		var atual = fronteira[idx]
		direcoes.shuffle() 
		var conseguiu_expandir = false
		
		for dir in direcoes:
			var vizinho = atual + dir
			if vizinho.x < -lim_x or vizinho.x >= lim_x or vizinho.y < -lim_y or vizinho.y >= lim_y:
				continue
			if eh_barreira and Vector2(vizinho).distance_to(centro) <= safe_radius:
				continue
			if not cluster.has(vizinho) and not grid_global.has(vizinho) and not grid_regra.has(vizinho):
				cluster[vizinho] = true
				fronteira.append(vizinho)
				conseguiu_expandir = true
				break 
		
		if not conseguiu_expandir:
			fronteira.remove_at(idx)
			
	return cluster

func gerar_tesouro():
	@warning_ignore("integer_division")
	var limite_x = stage_data.map_width / 2
	@warning_ignore("integer_division")
	var limite_y = stage_data.map_height / 2
	
	var posicao_valida = false
	var coordenada_sorteada: Vector2i
	
	# 1. Descobrir onde o jogador está agora na grade
	var player = get_tree().get_first_node_in_group("Player")
	var pos_player_grid = Vector2i(0, 0)
	if player:
		pos_player_grid = tile_map.local_to_map(player.position)
		
	var tentativas = 0
	var distancia_desejada = 5.0 # Tenta spawnar a pelo menos 5 blocos de distância
	
	while not posicao_valida:
		tentativas += 1
		var rand_x = randi_range(-limite_x, limite_x)
		var rand_y = randi_range(-limite_y, limite_y)
		coordenada_sorteada = Vector2i(rand_x, rand_y)
		
		var tem_chao = tile_map.get_cell_source_id(0, coordenada_sorteada) != -1
		var sem_obstaculo = tile_map.get_cell_source_id(1, coordenada_sorteada) == -1
		
		var longe_o_suficiente = false
		var distancia_atual = Vector2(coordenada_sorteada).distance_to(Vector2(pos_player_grid))
		
		if tentativas < 150:
			longe_o_suficiente = distancia_atual >= distancia_desejada
		elif tentativas < 300:
			longe_o_suficiente = distancia_atual >= 3.0
		else:
			longe_o_suficiente = distancia_atual > 0.0
		
		if tem_chao and sem_obstaculo and longe_o_suficiente:
			posicao_valida = true
			
	var novo_tesouro = cena_tesouro.instantiate()
	novo_tesouro.add_to_group("Tesouro")
	novo_tesouro.config = stage_data.tesouro_config
	tile_map.add_child(novo_tesouro)
	
	novo_tesouro.position = tile_map.map_to_local(coordenada_sorteada)

func play_stage_music():
	if stage_data != null and stage_data.stage_music != null:
		GerenciadorAudio.tocar_musica(stage_data.stage_music, stage_data.music_volume)

func _on_player_morreu():
	var terminal = get_tree().get_first_node_in_group("Terminal")
	if terminal:
		terminal.desativar_botao_executar()

	var player = get_tree().get_first_node_in_group("Player")
	if player and "invulneravel" in player:
		player.invulneravel = true
	
	$TelaMorte.show()
	await get_tree().create_timer(3.0).timeout
	RecursosManager.aplicarListaRecursos(recursos_iniciais)
	
	if terminal:
		terminal.abortar_arena()
		
func _configurar_visibilidade_ui(mostrar: bool):
	var ui_timer = get_tree().get_first_node_in_group("UI_Timer")
	var ui_inventario = get_tree().get_first_node_in_group("UI_Inventario")
	
	if ui_timer:
		ui_timer.visible = mostrar
		
	if ui_inventario:
		ui_inventario.visible = mostrar

func notificar_tesouro_coletado():
	if stage_data.tipo_mapa == StageData.TipoMapa.LABIRINTO:
		var passos = max(1, stage_data.labirinto_tesouros_para_maximo)
		var incremento = (stage_data.labirinto_multiplicador_maximo - stage_data.labirinto_multiplicador_inicial) / float(passos)
		Atributos.incrementar_multiplicador_labirinto(incremento, stage_data.labirinto_multiplicador_maximo)
		tile_map.clear()
		_gerar_modo_labirinto(true) 		
	gerar_tesouro()
