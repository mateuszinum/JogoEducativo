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
	var main = get_node_or_null("/root/Jogo")
	if main: 
		main.ir_para_arena()
	else: 
		get_tree().reload_current_scene()

func _on_exit_pressed() -> void:
	# Apenas exibe o popup visual que criamos no editor
	%PopupConfirmacao.show()


func _on_configuaracao_pressed() -> void:
	$TelaConfiguracoes.abrir()
	
	
	
#Para qunado for implementar o pause geral
func congelarJogo() -> void:
	pass


func descongelarJogo() -> void:
	pass


func _on_botao_sim_pressed() -> void:
	# 1. Tira o jogo do pause para os outros nós responderem
	get_tree().paused = false
	
	# 2. Manda o Terminal abortar a arena e salvar os recursos
	get_tree().call_group("Terminal", "abortar_arena")
	
	# 3. Espera 1 frame para garantir que o salvamento foi concluído
	await get_tree().process_frame
	
	# 4. Vai para o Menu Principal
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")


func _on_botao_nao_pressed() -> void:
	# Esconde o popup e não faz mais nada (o jogo continua pausado)
	%PopupConfirmacao.hide()
