extends Node2D

@export var stage_data : StageData
@export var noise_height_text : NoiseTexture2D
var noise : Noise

@onready var tile_map = $TileMap

func _ready():
    noise = noise_height_text.noise
    generate_world()
    
func generate_world():
    
    var qtd_obstaculos = stage_data.obstaculos_source_ids.size()
    
    for x in range(stage_data.map_width):
        for y in range(stage_data.map_height):
            var pos = Vector2i(x, y)
            var noise_val = noise.get_noise_2d(x, y)
            if noise_val > 0.2 and qtd_obstaculos > 0:
                var index_aleatorio = randi() % qtd_obstaculos
                
                var s_id = stage_data.obstaculos_source_ids[index_aleatorio]
                var atlas = stage_data.obstaculos_atlas[index_aleatorio]
                
                # Desenha o obstáculo na camada interna 0
                tile_map.set_cell(0, pos, s_id, atlas)
            else:
                # Desenha o chão na camada interna 0
                tile_map.set_cell(0, pos, stage_data.source_id_chao, stage_data.chao_atlas)
    
    var player = get_tree().get_first_node_in_group("Player")
    var centro_x = (stage_data.map_width	*	16)	/	2
    var centro_y = (stage_data.map_height	*	16)	/	2
    player.position = Vector2(centro_x, centro_y)
