extends Node2D

@export var stage_data : StageData
@export var noise_height_text : NoiseTexture2D
@export var noise_tree_text : NoiseTexture2D
var noise : Noise
var tree_noise : Noise

@onready var tile_map = $TileMap
@onready var camera_2d = $Player/Camera2D
var tree_atlas = [Vector2i(6,0), Vector2i(2,2), Vector2i(0,2), Vector2i(4,0), Vector2i(8,2)]
var tree_source_id = 3

func _ready():
	noise = noise_height_text.noise
	tree_noise = noise_tree_text.noise
	generate_world()
	
func generate_world():
	var qtd_obstaculos = stage_data.obstaculos_source_ids.size()
	var centro_x = (stage_data.map_width * 16) / 2
	var centro_y = (stage_data.map_height * 16) / 2
	var centro_vetor = Vector2(centro_x, centro_y)
	
	var raio_seguro = 5.0
	
	for x in range(stage_data.map_width):
		for y in range(stage_data.map_height):
			var pos = Vector2i(x, y)
			
			var pos_vetor = Vector2(x, y)
			if pos_vetor.distance_to(centro_vetor) <= raio_seguro:
				# Força o chão na Camada 0 e pula a verificação de obstáculos/árvores
				tile_map.set_cell(0, pos, stage_data.source_id_chao, stage_data.chao_atlas)
				continue
			
			
			var noise_val = noise.get_noise_2d(x, y)
			var noise_tree_val = tree_noise.get_noise_2d(x, y)
			
		
			if noise_val < -0.15 and qtd_obstaculos > 0:
				var index_aleatorio = randi() % qtd_obstaculos
				var s_id = stage_data.obstaculos_source_ids[index_aleatorio]
				var atlas = stage_data.obstaculos_atlas[index_aleatorio]
				
				# Desenha o obstáculo na camada 0
				tile_map.set_cell(0, pos, s_id, atlas)
				
			else:
				tile_map.set_cell(0, pos, stage_data.source_id_chao, stage_data.chao_atlas)
				
				
				if noise_tree_val > 0.85:
					print("ENTROU")
					tile_map.set_cell(1, pos, tree_source_id, tree_atlas.pick_random())
	
	var player = get_tree().get_first_node_in_group("Player")
	player.position = Vector2(centro_x, centro_y)
	
func _input(event):
	if Input.is_action_just_pressed("zoom_in"):
		var zoom_val = camera_2d.zoom.x - 0.1
		camera_2d.zoom = Vector2(zoom_val, zoom_val)
	if Input.is_action_just_pressed("zoom_out"):
		var zoom_val = camera_2d.zoom.x + 0.1
		camera_2d.zoom = Vector2(zoom_val, zoom_val)
