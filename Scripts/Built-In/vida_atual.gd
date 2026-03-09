extends Node

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("check_health"):
		vida_atual()

func vida_atual():
	var player = get_tree().get_first_node_in_group("Player")
	
	if player:
		var vida = player.health
		var vida_maxima = player.max_health
		print(str(vida) + "/" + str(vida_maxima))
	
		return vida
