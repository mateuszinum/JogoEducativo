extends Control

func _ready() -> void:
	# Força o menu a processar mesmo se o jogo estiver pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	_desativar_menu()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause_key"):
		if not get_tree().paused:
			pause()
		else:
			resume()

func pause():
	show()
	mouse_filter = Control.MOUSE_FILTER_STOP 
	get_tree().paused = true
	$AnimationPlayer.play("blur")

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	await $AnimationPlayer.animation_finished
	if not get_tree().paused:
		_desativar_menu()

func _desativar_menu():
	hide()
	mouse_filter = Control.MOUSE_FILTER_IGNORE 
	$AnimationPlayer.play("RESET")

func _on_continue_pressed() -> void:
	resume()

func _on_restart_pressed() -> void:
	resume()
	var main = get_node_or_null("/root/Main")
	if main: 
		main.ir_para_arena()
	else: 
		get_tree().reload_current_scene()

func _on_exit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")
