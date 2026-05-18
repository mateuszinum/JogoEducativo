extends Control

var menu_aberto: bool = false

@onready var tela_config = %TelaConfiguracoes
@onready var popup_confirmacao = %PopupConfirmacao

func _ready() -> void:
	add_to_group("MenuPausa")
	process_mode = Node.PROCESS_MODE_ALWAYS
	_desativar_menu()

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.health <= 0:
		return
		
	if Input.is_action_just_pressed("pause_key"):
		if not menu_aberto:
			pause()
		else:
			if tela_config.visible:
				return
			resume()

func pause():
	menu_aberto = true
	show()
	mouse_filter = Control.MOUSE_FILTER_STOP 
	congelarJogo()

func resume():
	menu_aberto = false
	descongelarJogo()
	if not menu_aberto:
		_desativar_menu()

func _desativar_menu():
	menu_aberto = false
	hide()
	mouse_filter = Control.MOUSE_FILTER_IGNORE 

func fechar_forcado() -> void:
	if menu_aberto:
		descongelarJogo()
	_desativar_menu()
	
	if has_node("TelaConfiguracoes"):
		get_node("TelaConfiguracoes").hide()
		
	var popup = get_node_or_null("%PopupConfirmacao")
	if popup:
		popup.hide()

func _on_botao_continuar_pressed() -> void:
	resume()

func _on_botao_config_pressed() -> void:
	tela_config.abrir()
	
func _on_botao_menu_principal_pressed() -> void:
	popup_confirmacao.show()
	
func congelarJogo() -> void:
	pass

func descongelarJogo() -> void:
	pass

func _on_botao_sim_pressed() -> void:
	get_tree().call_group("Terminal", "abortar_arena")
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")

func _on_botao_nao_pressed() -> void:
	popup_confirmacao.hide()
