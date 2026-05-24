extends Control

const TEMPO_FADE_BIBLIOTECA: float = 0.5

@export var musica_tema: AudioStream
@export var volume_musica_db: float = 0.0

@onready var loja_bruxa = $LojaBruxa
@onready var loja_comerciante = $LojaComerciante
@onready var loja_biblioteca = $LojaBiblioteca
@onready var loja_mago_velho = $LojaMagoVelho

@onready var botao_bruxa = %ButtonBruxa
@onready var botao_comerciante = %ButtonComerciante
@onready var botao_biblioteca = %ButtonBiblioteca
@onready var botao_mago_velho = %ButtonMagoVelho

@onready var pause_menu = %PauseMenu

var player_musica: AudioStreamPlayer

func _ready() -> void:
	add_to_group("MenuVilarejo")
	if loja_bruxa: loja_bruxa.hide()
	if loja_comerciante: loja_comerciante.hide()
	if loja_biblioteca: loja_biblioteca.hide()
	if loja_mago_velho: loja_mago_velho.hide()
	
	verificar_progresso()
	iniciar_musica()
	
	ProgressoDB.progresso_alterado.connect(_on_progresso_alterado)
	
	if not Constantes.USAR_EFEITOS_TELA:
		if has_node("PosProcessamento"):
			$PosProcessamento.hide()

func iniciar_musica() -> void:
	GerenciadorAudio.tocar_musica(musica_tema, volume_musica_db)

func _on_button_bruxa_pressed() -> void:
	verificar_progresso()
	if loja_bruxa: loja_bruxa.show()

func _on_button_comerciante_pressed() -> void:
	verificar_progresso()
	if loja_comerciante: loja_comerciante.show()

func _on_button_biblioteca_pressed() -> void:
	verificar_progresso()
	if loja_biblioteca: loja_biblioteca.show()

func _on_button_mago_velho_pressed() -> void:
	verificar_progresso()
	if loja_mago_velho: loja_mago_velho.show()
	if (!ProgressoDB.tem_desbloqueado("MagoVelho")):
		ProgressoDB.desbloquear("MagoVelho")
		if loja_mago_velho and loja_mago_velho.has_method("tocar_dialogo_especial"):
			loja_mago_velho.tocar_dialogo_especial()

func _on_loja_bruxa_fechou_loja() -> void:
	verificar_progresso()
	if loja_bruxa: loja_bruxa.hide()

func _on_loja_comerciante_fechou_loja() -> void:
	verificar_progresso()
	if loja_comerciante: loja_comerciante.hide()

func _on_loja_biblioteca_fechou_loja() -> void:
	verificar_progresso()
	if loja_biblioteca: loja_biblioteca.hide()

func _on_loja_mago_velho_fechou_loja() -> void:
	if loja_mago_velho:
		loja_mago_velho.hide()
	if (!ProgressoDB.tem_desbloqueado("MagoVelho")):
		ProgressoDB.desbloquear("MagoVelho")
	verificar_progresso()

func _on_start_game_pressed() -> void:
	verificar_progresso()
	var main_scene = get_node_or_null("/root/Jogo")
	if main_scene and main_scene.has_method("ir_para_arena"):
		main_scene.ir_para_arena()

#----------------------------------#
# desbloqueio de estabelecimentos

func set_bruxa(valor : bool):
	botao_bruxa.disabled = !valor
	
func set_comerciante(valor : bool):
	botao_comerciante.disabled = !valor
	
func set_biblioteca(valor : bool):
	botao_biblioteca.disabled = !valor
	
func set_mago_velho(valor : bool):
	botao_mago_velho.disabled = !valor

func verificar_progresso():
	set_bruxa(ProgressoDB.tem_desbloqueado("Localização"))
	set_comerciante(ProgressoDB.tem_desbloqueado("Itens"))
	set_biblioteca(ProgressoDB.tem_desbloqueado("MagoVelho"))

#----------------------------------#

func _on_progresso_alterado() -> void:
	verificar_progresso()
	
			
func _on_progresso_inicio_alterado() -> void:
	verificar_progresso()
	
func forcar_abertura_biblioteca(nome_pagina: String) -> void:
	if Constantes.DEBUG: print("[DEBUG] VillageMenu: Recebeu ordem para transição. Página alvo: ", nome_pagina)
	
	if Constantes.FORÇAR_BIBLIOTECA:
		if loja_mago_velho and loja_mago_velho.visible:
			if Constantes.DEBUG: print("[DEBUG] VillageMenu: Mago Velho está aberto. Iniciando Fade to Black...")
			
			var tela_preta = ColorRect.new()
			tela_preta.color = Color(0, 0, 0, 0)
			tela_preta.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			tela_preta.z_index = 100
			tela_preta.mouse_filter = Control.MOUSE_FILTER_STOP
			add_child(tela_preta)
			
			var tween = create_tween()
			tween.tween_property(tela_preta, "color:a", 1.0, TEMPO_FADE_BIBLIOTECA)
			
			tween.tween_callback(func():
				loja_mago_velho.hide()
				if loja_biblioteca:
					loja_biblioteca.show()
					if Constantes.DEBUG: print("[DEBUG] VillageMenu: Fade escuro máximo. Trocando loja e chamando BibliotecaPagina.")
					get_tree().call_group("BibliotecaPagina", "abrir_pagina_por_nome", nome_pagina)
			)
			
			tween.tween_property(tela_preta, "color:a", 0.0, TEMPO_FADE_BIBLIOTECA)
			tween.tween_callback(tela_preta.queue_free)
		else:
			if Constantes.DEBUG: print("[DEBUG] VillageMenu ERRO: Transição cancelada pois o Mago Velho NÃO está visível.")
	else:
		if Constantes.DEBUG: print("[DEBUG] VillageMenu AVISO: Transição ignorada pois Constantes.FORÇAR_BIBLIOTECA é falso.")
