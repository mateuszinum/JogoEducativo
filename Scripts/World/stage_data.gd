class_name StageData extends Resource

@export var nome : String

@export_group("Trilha Sonora")
@export var stage_music : AudioStream
@export var music_volume : float = 0.0

@export_group("Spawn de Inimigos")
@export var spawn_events : Array[SpawnEvent] = []

@export_group("Outras configurações")
@export var map_width: int = 50
@export var map_height: int = 50
@export var raio_seguro_spawn: float = 5.0
@export var tesouro_config: TesouroData

@export_category("Tiles")
@export var stage_tileset: TileSet
@export_group("Chão")
@export var ground_variants: Array[GroundVariant] = []

@export_group("Barreiras")
@export var spawn_rules: Array[GenRule] = []


func get_random_ground_id() -> int:
	if ground_variants.is_empty():
		return -1
		
	var peso_total : float = 0.0
	for tile in ground_variants:
		peso_total += tile.chance_peso
		
	var sorteio = randf_range(0.0, peso_total)
	var peso_acumulado : float = 0.0
	
	for tile in ground_variants:
		peso_acumulado += tile.chance_peso
		if sorteio <= peso_acumulado:
			return tile.source_id
			
	return ground_variants[0].source_id
