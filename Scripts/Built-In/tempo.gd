extends Node

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("check_time"):
		tempo()

func tempo():
	var spawner = get_tree().get_first_node_in_group("Spawner")
	
	if spawner:
		# O lpad(2, '0') garante que o segundo '5' apareça como '05'
		print("Tempo atual da partida: " + str(spawner.minute) + ":" + str(spawner.seconds).lpad(2, '0'))
		
		var tempo = [spawner.minute, spawner.seconds]
		return tempo
