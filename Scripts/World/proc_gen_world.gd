extends Node2D

@export var stage_data: StageData
@onready var tile_map = $TileMap
@onready var camera_2d = $Player/Camera2D

var seed_hash: int

func _ready():
	randomize()
	seed_hash = randi()
	seed(seed_hash)
	generate_world()
	play_stage_music()
	print("Posição do Player: " + str($Player.position))
	print("Posição Global do Player: " + str($Player.global_position))

func generate_world():
	if not stage_data:
		return
		
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
						
	var player = get_tree().get_first_node_in_group("Player")
	player.position = tile_map.map_to_local(Vector2i(0, 0)) + Vector2(8, 8)

func play_stage_music():
	if stage_data != null and stage_data.stage_music != null:
		var music_player = AudioStreamPlayer.new()
		music_player.stream = stage_data.stage_music
		music_player.volume_db = stage_data.music_volume
		music_player.name = "StageMusicPlayer"
		add_child(music_player)
		music_player.play()
