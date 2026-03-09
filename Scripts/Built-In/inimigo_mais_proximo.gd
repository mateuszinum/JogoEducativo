class_name InimigoMaisProximo
extends RefCounted

static func get_nearest_enemy(origin_position: Vector2, enemies_array: Array[CharacterBody2D]) -> CharacterBody2D:
	if enemies_array.is_empty():
		return null
	
	var nearest : CharacterBody2D = null
	var min_distance := INF

	for enemy in enemies_array:
		if !is_instance_valid(enemy):
			continue
			
		# Calcula a distância da posição de origem (que será o player) até o inimigo
		var distance = origin_position.distance_squared_to(enemy.global_position)
		if distance < min_distance:
			min_distance = distance
			nearest = enemy

	return nearest
