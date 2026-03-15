extends Node2D

@export var enemy_scene : PackedScene
@export var max_enemies : int = 300

# Aqui você arrasta o seu arquivo .tres da fase atual!
@export var current_stage : StageData 

var distance : float = 400
var total_time_seconds : int = 0

var active_spawns : Dictionary = {}

func _ready():
	check_spawn_events()

func spawn(pos : Vector2, type_to_spawn: Enemy):
	if get_tree().get_node_count_in_group("Enemy") >= max_enemies:
		return

	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.type = type_to_spawn
	enemy_instance.position = pos
	
	# Adiciona o inimigo como filho do pai do Spawner (o mapa World), e não da tela cheia!
	get_parent().add_child(enemy_instance)

func get_random_position() -> Vector2:
	# Agora o spawner também busca o player dinamicamente pelo grupo,
	# evitando erros de caminhos quebrados por causa da tela dividida.
	var player = get_tree().get_first_node_in_group("Player")
	
	if player != null:
		return player.position + distance * Vector2.RIGHT.rotated(randf_range(0, 2 * PI))
	
	return Vector2.ZERO

func _on_timer_timeout() -> void:
	total_time_seconds += 1
	update_ui_clock()
	
	check_spawn_events()
	
	execute_spawns()

func check_spawn_events():
	if current_stage == null: return
	
	for event in current_stage.spawn_events:
		if event.time_in_seconds == total_time_seconds:
			if event.spawn_rate > 0:
				active_spawns[event.enemy_type] = event.spawn_rate
				print("Evento: Começando a spawnar ", event.enemy_type.title, " a ", event.spawn_rate, "/s")
			else:
				active_spawns.erase(event.enemy_type)
				print("Evento: Parando de spawnar ", event.enemy_type.title)

func execute_spawns():
	for enemy_type in active_spawns:
		var amount_to_spawn = active_spawns[enemy_type]
		
		for i in range(amount_to_spawn):
			spawn(get_random_position(), enemy_type)

func update_ui_clock():
	var m = total_time_seconds / 60
	var s = total_time_seconds % 60
	
	var minute_node = get_node_or_null("%Minute")
	var seconds_node = get_node_or_null("%Seconds")
	
	if minute_node and seconds_node:
		minute_node.text = str(m)
		seconds_node.text = str(s).lpad(2, '0')
