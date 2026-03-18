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

func generate_world():
	if not stage_data:
		return
	
	tile_map.clear()
	# 1. Calcula o centro em GRADE (para o raio funcionar)
	var centro_grid_x = stage_data.map_width / 2.0
	var centro_grid_y = stage_data.map_height / 2.0
	var centro_vetor_grid = Vector2(centro_grid_x, centro_grid_y)
	
	stage_data.regras_de_geracao.sort_custom(func(a, b): return a.layer_destino < b.layer_destino)
	
	for x in range(stage_data.map_width):
		for y in range(stage_data.map_height):
			var pos = Vector2i(x, y)
			var pos_vetor = Vector2(x, y)
			
			tile_map.set_cell(0, pos, stage_data.source_id_chao_padrao, stage_data.chao_padrao_atlas)
			
			# Usa o vetor em GRADE para checar a distância
			if pos_vetor.distance_to(centro_vetor_grid) <= stage_data.raio_seguro_spawn:
				continue
			
			var bloco_ocupado = false 
			
			for regra in stage_data.regras_de_geracao:
				if regra.exige_chao_livre and bloco_ocupado:
					continue
					
				if not regra.ruido or not regra.ruido.noise:
					continue # Pula a regra se você esqueceu de criar o ruído no Inspetor
					
				regra.ruido.noise.seed = seed_hash
				var valor_atual_ruido = regra.ruido.noise.get_noise_2d(x, y)
					
				if valor_atual_ruido >= regra.valor_minimo and valor_atual_ruido <= regra.valor_maximo:
					var index_rand = randi() % regra.source_ids.size()
					var s_id = regra.source_ids[index_rand]
					var atlas = regra.atlas_coords[index_rand]
					
					tile_map.set_cell(regra.layer_destino, pos, s_id, atlas)
					
					if regra.layer_destino == 0:
						bloco_ocupado = true
						
	var player = get_tree().get_first_node_in_group("Player")
	# 2. Converte a grade para PIXELS (* 16) apenas na hora de mover o jogador
	player.position = Vector2(centro_grid_x * 16, centro_grid_y * 16)
	
func _input(event):
	if Input.is_action_just_pressed("zoom_in"):
		var zoom_val = camera_2d.zoom.x - 0.1
		camera_2d.zoom = Vector2(zoom_val, zoom_val)
	if Input.is_action_just_pressed("zoom_out"):
		var zoom_val = camera_2d.zoom.x + 0.1
		camera_2d.zoom = Vector2(zoom_val, zoom_val)
