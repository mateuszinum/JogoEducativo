extends Node2D

@export var enemy_scene : PackedScene
@export var max_enemies : int = 50

@export var current_stage : StageData 

var distance : float = 220
var total_time_seconds : int = 0

var active_spawns : Dictionary = {}
var spawn_accumulators : Dictionary = {}

func spawn(pos : Vector2, type_to_spawn: Enemy):
	if get_tree().get_node_count_in_group("Enemy") >= max_enemies:
		return

	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.type = type_to_spawn
	enemy_instance.position = pos
	
	get_parent().add_child(enemy_instance)

func get_random_position() -> Vector2:
	var player = get_tree().get_first_node_in_group("Player")
	
	if player != null:
		var random_dir = Vector2.RIGHT.rotated(randf_range(0, 2 * PI))
		var raw_pos = player.global_position + (random_dir * distance)
		
		var nav_map = get_world_2d().navigation_map
		var safe_pos = NavigationServer2D.map_get_closest_point(nav_map, raw_pos)
		
		return safe_pos
	
	return Vector2.ZERO

func _on_timer_timeout() -> void:
	total_time_seconds += 1
	update_ui_clock()
	
	check_spawn_events()
	
	execute_spawns()

func check_spawn_events():
	if current_stage == null: return
	
	for event in current_stage.spawn_events:
		var tempo_alvo = event.time_in_seconds
		if tempo_alvo == 0:
			tempo_alvo = 1
			
		if tempo_alvo == total_time_seconds:
			if event.spawn_rate > 0.01:
				active_spawns[event.enemy_type] = event.spawn_rate
				print("Evento: Começando a spawnar ", event.enemy_type.nome)
			else:
				active_spawns.erase(event.enemy_type)
				print("Evento: Parando de spawnar ", event.enemy_type.nome)

func execute_spawns():
	for enemy_type in active_spawns:
		var rate = active_spawns[enemy_type]
		
		if not spawn_accumulators.has(enemy_type):
			spawn_accumulators[enemy_type] = 0.0
			
		spawn_accumulators[enemy_type] += rate
		
		while spawn_accumulators[enemy_type] >= 1.0:
			spawn(get_random_position(), enemy_type)
			spawn_accumulators[enemy_type] -= 1.0

func update_ui_clock():
	var m = total_time_seconds / 60
	var s = total_time_seconds % 60
	
	var minute_node = get_node_or_null("%Minute")
	var seconds_node = get_node_or_null("%Seconds")
	
	if minute_node and seconds_node:
		minute_node.text = str(m)
		seconds_node.text = str(s).lpad(2, '0')
