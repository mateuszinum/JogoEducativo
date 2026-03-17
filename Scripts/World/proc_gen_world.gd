extends Node2D

@export var stage_data : StageData
@export var noise_height_text : NoiseTexture2D
@export var noise_tree_text : NoiseTexture2D
var noise : Noise
var tree_noise : Noise

# Referência ao seu único nó TileMap
@onready var tile_map = $TileMap
@onready var camera_2d = $Player/Camera2D
var tree_atlas = Vector2i(6,0)
var tree_source_id = 2

func _ready():
	noise = noise_height_text.noise
	tree_noise = noise_tree_text.noise
	generate_world()
	
func generate_world():
	if not stage_data or not noise:
		push_error("StageData ou NoiseTexture2D não configurados!")
		return

	var qtd_obstaculos = stage_data.obstaculos_source_ids.size()
	var arr_noise = []
	var arr_tree_noise = []
	for x in range(stage_data.map_width):
		for y in range(stage_data.map_height):
			var pos = Vector2i(x, y)
			var noise_val = noise.get_noise_2d(x, y)
			var noise_tree_val = tree_noise.get_noise_2d(x, y)
			
			arr_noise.append(noise_val)
			arr_tree_noise.append(noise_tree_val)
			
			# 1. BASE: 20% Obstáculo vs 80% Grama
			# O ruído varia de ~ -0.44 a 0.37. 
			# Cortar em -0.15 ou -0.1 pega aproximadamente a "ponta" de 20% dos valores mais baixos.
			if noise_val < -0.15 and qtd_obstaculos > 0:
				var index_aleatorio = randi() % qtd_obstaculos
				var s_id = stage_data.obstaculos_source_ids[index_aleatorio]
				var atlas = stage_data.obstaculos_atlas[index_aleatorio]
				
				# Desenha o obstáculo na camada 0
				tile_map.set_cell(0, pos, s_id, atlas)
				
			else:
				# Desenha a Grama na camada 0
				tile_map.set_cell(0, pos, stage_data.source_id_chao, stage_data.chao_atlas)
				
				
				# 2. DECORAÇÃO: Apenas nos 80% de grama, testamos os 10% de Árvore
				# O ruído da árvore varia de ~ -0.99 a 0.94.
				# Para pegar os 10% mais raros, exigimos um valor muito alto, próximo do topo.
				if noise_tree_val > 0.85:
					print("ENTROU")
					tile_map.set_cell(1, pos, tree_source_id, tree_atlas)
	
	var player = get_tree().get_first_node_in_group("Player")
	var centro_x = (stage_data.map_width	*	16)	/	2
	var centro_y = (stage_data.map_height	*	16)	/	2
	player.position = Vector2(centro_x, centro_y)
	print("Ruído Normal - Min: ", arr_noise.min(), " | Max: ", arr_noise.max())
	print("Ruído Tree   - Min: ", arr_tree_noise.min(), " | Max: ", arr_tree_noise.max())
	
func _input(event):
	if Input.is_action_just_pressed("zoom_in"):
		var zoom_val = camera_2d.zoom.x - 0.1
		camera_2d.zoom = Vector2(zoom_val, zoom_val)
	if Input.is_action_just_pressed("zoom_out"):
		var zoom_val = camera_2d.zoom.x + 0.1
		camera_2d.zoom = Vector2(zoom_val, zoom_val)
