extends Control

@onready var conteudo_menu = %ConteudoMenuPrincipal
@onready var tela_creditos = %TelaCreditos
@onready var scroll_creditos = %ScrollCreditos
@onready var anim_intro = $AnimationPlayer
@onready var intro_layer = $IntroLayer
@onready var transition_rect = $TransitionLayer/ColorRect
@onready var botao_start = %BotaoNovoJogo
@onready var container_botoes = %ContainerBotoes
@onready var sistema_cutscene = %SistemaCutscene
@onready var imagem_bg = %ImagemBG

@export_group("Áudio")
@export var musica_tema: AudioStream
@export var volume_musica_db: float = 0.0

@export var sfx_entrar: AudioStream
@export var volume_sfx_entrar_db: float = 0.0

@export_group("Novo Jogo e Cutscene")
@export var cutscene_inicial: CutsceneResource

@export_group("Créditos")
@export var tempo_fade_creditos: float = 0.1
@export var velocidade_scroll_creditos: float = 100.0
@export var multiplicador_aceleracao: float = 5.0

static var intro_ja_exibida: bool = false
var creditos_rolando: bool = false
var tween_scroll_creditos: Tween

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
	GerenciadorAudio.tocar_musica(musica_tema, volume_musica_db)

func tocar_sfx_entrar() -> void:
	if sfx_entrar != null:
		var player_sfx = AudioStreamPlayer.new()
		player_sfx.stream = sfx_entrar
		player_sfx.volume_db = volume_sfx_entrar_db
		player_sfx.bus = "UI" 
		add_child(player_sfx)
		player_sfx.play()

func revelar_menu():
	intro_layer.hide()

func pular_intro():
	intro_layer.hide()
	anim_intro.stop()

func _on_start_pressed() -> void:
	entrar_novo_jogo()

func _on_exit_pressed() -> void:
	get_tree().quit()
	
func _on_botao_creditos_pressed() -> void:
	if creditos_rolando: return
	
	tocar_sfx_entrar()
	creditos_rolando = true
	
	scroll_creditos.scroll_vertical = 0
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(conteudo_menu, "modulate:a", 0.0, tempo_fade_creditos)
	
	tela_creditos.modulate.a = 0.0
	tela_creditos.show()
	tween.tween_property(tela_creditos, "modulate:a", 1.0, tempo_fade_creditos)
	
	await tween.finished
	conteudo_menu.hide()
	
	iniciar_scroll_creditos()

func iniciar_scroll_creditos() -> void:
	if not creditos_rolando: return
	
	var v_scroll = scroll_creditos.get_v_scroll_bar()
	await get_tree().process_frame
	
	var max_scroll = max(0, v_scroll.max_value - v_scroll.page)
	
	if max_scroll == 0:
		fechar_creditos()
		return
		
	var tempo_rolagem = max_scroll / velocidade_scroll_creditos
	
	tween_scroll_creditos = create_tween()
	tween_scroll_creditos.tween_property(scroll_creditos, "scroll_vertical", max_scroll, tempo_rolagem)
	
	await tween_scroll_creditos.finished
	fechar_creditos()

func fechar_creditos() -> void:
	if not creditos_rolando: return
	creditos_rolando = false
	
	if tween_scroll_creditos and tween_scroll_creditos.is_valid():
		tween_scroll_creditos.kill()
		
	conteudo_menu.modulate.a = 0.0
	conteudo_menu.show()
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(tela_creditos, "modulate:a", 0.0, tempo_fade_creditos)
	tween.tween_property(conteudo_menu, "modulate:a", 1.0, tempo_fade_creditos)
	
	await tween.finished
	tela_creditos.hide()

func _input(event: InputEvent) -> void:
	if creditos_rolando and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if tween_scroll_creditos and tween_scroll_creditos.is_valid():
					tween_scroll_creditos.set_speed_scale(multiplicador_aceleracao)
			else:
				if tween_scroll_creditos and tween_scroll_creditos.is_valid():
					tween_scroll_creditos.set_speed_scale(1.0)
	if creditos_rolando and event.is_action_pressed("ui_cancel"):
			fechar_creditos()	

func entrar_novo_jogo() -> void:
	GerenciadorAudio.parar_musica(0.0)
	tocar_sfx_entrar()
	
	if botao_start.has_method("travar_no_clique"):
		botao_start.travar_no_clique()
		
	for botao in container_botoes.get_children():
		if botao != botao_start:
			botao.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var tween_botao = create_tween()
			tween_botao.tween_property(botao, "modulate:a", 0.0, 0.6)
			
	
	transition_rect.show()
	transition_rect.modulate.a = 0.0
	var tween_menu = create_tween()
	tween_menu.tween_property(transition_rect, "modulate:a", 1.0, 2.0)
	await tween_menu.finished
	
	conteudo_menu.hide()
	imagem_bg.hide()
	
	if not Constantes.PULAR_TUTORIAL and cutscene_inicial != null and sistema_cutscene != null:
		sistema_cutscene.iniciar_cutscene(cutscene_inicial)
		
		var tween_revelar = create_tween()
		tween_revelar.tween_property(transition_rect, "modulate:a", 0.0, 2.0)
		await tween_revelar.finished

		transition_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

		await sistema_cutscene.cutscene_finalizada
		
		var tween_cobrir = create_tween()
		tween_cobrir.tween_property(transition_rect, "modulate:a", 1.0, 2.0)
		await tween_cobrir.finished
	
	get_tree().change_scene_to_file("res://Scenes/UI/jogo.tscn")
