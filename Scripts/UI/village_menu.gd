extends Control

@export var musica_tema: AudioStream
@export var volume_musica_db: float = 0.0

@onready var loja_bruxa = $LojaBruxa
@onready var loja_comerciante = $LojaComerciante
@onready var loja_biblioteca = $LojaBiblioteca
@onready var loja_mago_velho = $LojaMagoVelho

var player_musica: AudioStreamPlayer

func _ready() -> void:
	if loja_bruxa: loja_bruxa.hide()
	if loja_comerciante: loja_comerciante.hide()
	if loja_biblioteca: loja_biblioteca.hide()
	if loja_mago_velho: loja_mago_velho.hide()
	
	iniciar_musica()
	
	if not Constantes.USAR_EFEITOS_TELA:
		if has_node("PosProcessamento"):
			$PosProcessamento.hide()

func iniciar_musica() -> void:
	GerenciadorAudio.tocar_musica(musica_tema, volume_musica_db)

func _on_button_bruxa_pressed() -> void:
	if loja_bruxa: loja_bruxa.show()

func _on_button_comerciante_pressed() -> void:
	if loja_comerciante: loja_comerciante.show()

func _on_button_biblioteca_pressed() -> void:
	if loja_biblioteca: loja_biblioteca.show()

func _on_button_mago_velho_pressed() -> void:
	if loja_mago_velho: loja_mago_velho.show()

func _on_loja_bruxa_fechou_loja() -> void:
	if loja_bruxa: loja_bruxa.hide()

func _on_loja_comerciante_fechou_loja() -> void:
	if loja_comerciante: loja_comerciante.hide()

func _on_loja_biblioteca_fechou_loja() -> void:
	if loja_biblioteca: loja_biblioteca.hide()

func _on_loja_mago_velho_fechou_loja() -> void:
	if loja_mago_velho: loja_mago_velho.hide()

func _on_start_game_pressed() -> void:
	var main_scene = get_node_or_null("/root/Jogo")
	if main_scene and main_scene.has_method("ir_para_arena"):
		main_scene.ir_para_arena()
