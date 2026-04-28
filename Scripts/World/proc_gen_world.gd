extends Node2D

@export var stage_data: StageData
@export var cena_tesouro: PackedScene
@export var terminal: Node
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
	var centro_grid_x = 0
	var centro_grid_y = 0
	var centro_vetor_grid = Vector2(centro_grid_x, centro_grid_y)
	
	var metade_largura = stage_data.map_width / 2
	var metade_altura = stage_data.map_height / 2
	for x in range(-metade_largura, metade_largura):
		for y in range(-metade_altura, metade_altura):
			var pos = Vector2i(x, y)
			var pos_vetor = Vector2(x, y)
			
			var chao_escolhido_id = stage_data.get_random_ground_id()
			if chao_escolhido_id != -1:
				tile_map.set_cell(0, pos, chao_escolhido_id, Vector2i(0, 0))
				
			
			var na_area_segura = pos_vetor.distance_to(centro_vetor_grid) <= stage_data.raio_seguro_spawn
			if na_area_segura:
				continue 
			
			var final_obstacle_id = -1
			
			for regra in stage_data.spawn_rules:
				if not regra.ruido or not regra.ruido.noise or regra.source_ids.is_empty():
					continue 
					
				regra.ruido.noise.seed = seed_hash
				var valor_atual_ruido = regra.ruido.noise.get_noise_2d(x, y)
					
				if valor_atual_ruido >= regra.valor_minimo and valor_atual_ruido <= regra.valor_maximo:
					final_obstacle_id = regra.source_ids.pick_random()
			
			if final_obstacle_id != -1:
				tile_map.set_cell(1, pos, final_obstacle_id, Vector2i(0, 0))
				tile_map.erase_cell(0, pos)
			
	recursos_iniciais = RecursosManager.listarRecursos().duplicate()	
	print(recursos_iniciais)				
	var player = get_tree().get_first_node_in_group("Player")
	player.position = tile_map.map_to_local(Vector2i(0, 0)) + Vector2(8, 8)
	player.connect("vida_zerada", _on_player_morreu)
	gerar_tesouro()

func play_stage_music():
	if stage_data != null and stage_data.stage_music != null:
		var music_player = AudioStreamPlayer.new()
		music_player.stream = stage_data.stage_music
		music_player.volume_db = stage_data.music_volume
		music_player.bus = "Musica" 
		music_player.name = "StageMusicPlayer"
		add_child(music_player)
		music_player.play()

func gerar_tesouro():
	var limite_x = stage_data.map_width / 2
	var limite_y = stage_data.map_height / 2
	
	var posicao_valida = false
	var coordenada_sorteada: Vector2i
	
	while not posicao_valida:
		var rand_x = randi_range(-limite_x, limite_x)
		var rand_y = randi_range(-limite_y, limite_y)
		coordenada_sorteada = Vector2i(rand_x, rand_y)
		
		var tem_chao = tile_map.get_cell_source_id(0, coordenada_sorteada) != -1
		var sem_obstaculo = tile_map.get_cell_source_id(1, coordenada_sorteada) == -1
		var fora_do_centro = coordenada_sorteada != Vector2i(0, 0)
		
		if tem_chao and sem_obstaculo and fora_do_centro:
			posicao_valida = true
			
	var novo_tesouro = cena_tesouro.instantiate()
	novo_tesouro.add_to_group("Tesouro")
	novo_tesouro.config = stage_data.tesouro_config
	tile_map.add_child(novo_tesouro)
	
	novo_tesouro.position = tile_map.map_to_local(coordenada_sorteada)

func _on_player_morreu():
	var player = get_tree().get_first_node_in_group("Player")
	if player and "invulneravel" in player:
		player.invulneravel = true
	
	$TelaMorte.show()
	
	await get_tree().create_timer(3.0).timeout
	print(recursos_iniciais)
	RecursosManager.aplicarListaRecursos(recursos_iniciais)
	
	var terminal = get_tree().get_first_node_in_group("Terminal")
	if terminal:
		terminal.abortar_arena()
	
