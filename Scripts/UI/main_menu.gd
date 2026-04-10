extends Control

static var intro_ja_exibida: bool = false

@export var musica_tema: AudioStream
@export var volume_musica_db: float = 0.0

@export var sfx_entrar: AudioStream
@export var volume_sfx_entrar_db: float = 0.0

@onready var anim_intro = $AnimationPlayer
@onready var intro_layer = $IntroLayer
@onready var transition_rect = $TransitionLayer/ColorRect

var player_musica: AudioStreamPlayer

func _ready() -> void:
	if not Constantes.MODO_DEV and not intro_ja_exibida:
		anim_intro.play("SplashIntro")
		intro_ja_exibida = true
	else:
		pular_intro()
	
	iniciar_musica()
	
	if not Constantes.USAR_EFEITOS_TELA:
		if has_node("PosProcessamento"):
			$PosProcessamento.hide()

func iniciar_musica() -> void:
	if Constantes.TOCAR_MUSICA and musica_tema != null:
		player_musica = AudioStreamPlayer.new()
		player_musica.stream = musica_tema
		player_musica.volume_db = volume_musica_db
		player_musica.bus = "Musica" 
		add_child(player_musica)
		player_musica.play()

func tocar_sfx_entrar() -> void:
	if sfx_entrar != null:
		var player_sfx = AudioStreamPlayer.new()
		player_sfx.stream = sfx_entrar
		player_sfx.volume_db = volume_sfx_entrar_db
		player_sfx.bus = "SFX" 
		add_child(player_sfx)
		player_sfx.play()

func revelar_menu():
	intro_layer.hide()

func pular_intro():
	intro_layer.hide()
	anim_intro.stop()

func _on_start_pressed() -> void:
	if player_musica: player_musica.stop()
	
	tocar_sfx_entrar()
	
	var botao_start = $VBoxContainer/Button
	
	if botao_start.has_method("travar_no_clique"):
		botao_start.travar_no_clique()
	
	for botao in $VBoxContainer.get_children():
		if botao != botao_start:
			var tween_botao = create_tween()
			tween_botao.tween_property(botao, "modulate:a", 0.0, 1)
	
	transition_rect.show()
	transition_rect.modulate.a = 0.0
	
	var tween_tela = create_tween()
	tween_tela.tween_property(transition_rect, "modulate:a", 1.0, 2)
	
	await tween_tela.finished
	get_tree().change_scene_to_file("res://Scenes/UI/jogo.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
