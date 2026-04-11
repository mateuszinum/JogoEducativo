extends Node

func _ready() -> void:
	call_deferred("aplicar_configuracoes_de_tela")

func aplicar_configuracoes_de_tela() -> void:

	var resolucao = Vector2i(1280, 720)
	
	if Constantes.TELA_CHEIA:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(resolucao)
		
		var tela_atual = DisplayServer.window_get_current_screen()
		var tamanho_da_tela = DisplayServer.screen_get_size(tela_atual)
		var posicao_central = (tamanho_da_tela - resolucao) / 2
		DisplayServer.window_set_position(posicao_central)
