extends Node2D

@export var tempo_fade_reset: float = 0.2

@export_group("Configurações da Câmera")
@export var camera_zoom: Vector2 = Vector2(2.0, 2.0)
@export var camera_offset: Vector2 = Vector2.ZERO
@export var posicao_centro_camera: Vector2 = Vector2.ZERO 

@export_group("Configuração do Player")
@export var posicao_inicial: Vector2

@export_group("Trilha Sonora")
@export var musica_tema: AudioStream
@export var volume_musica_db: float = 0.0

@export_group("Cutscene Final")
@export var cutscene_final: CutsceneResource

@onready var tile_map = $TileMap
@onready var transition_rect = %TransitionRect
@onready var saida_tutorial = %SaidaTutorial

var pos_inicial_player: Vector2

func _ready():
	add_to_group("MundoTutorial")
	_configurar_visibilidade_ui(false)
	
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		if player.has_method("configurar_modo_tutorial"):
			player.configurar_modo_tutorial()
			
		player.global_position = posicao_inicial
		pos_inicial_player = posicao_inicial
			
		var camera_2d = player.get_node_or_null("Camera2D")
		if camera_2d:
			camera_2d.position_smoothing_enabled = false
			camera_2d.top_level = true
			camera_2d.global_position = posicao_centro_camera + camera_offset
			camera_2d.zoom = camera_zoom
			camera_2d.reset_smoothing()
			
	if Constantes.TOCAR_MUSICA and musica_tema != null:
		GerenciadorAudio.tocar_musica(musica_tema, volume_musica_db)
		
	if not Constantes.USAR_EFEITOS_TELA and has_node("PosProcessamento"):
		$PosProcessamento.hide()

func _configurar_visibilidade_ui(mostrar: bool):
	var ui_timer = get_tree().get_first_node_in_group("UI_Timer")
	var ui_inventario = get_tree().get_first_node_in_group("UI_Inventario")
	
	if ui_timer: ui_timer.visible = mostrar
	if ui_inventario: ui_inventario.visible = mostrar

func _on_saida_tutorial_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		saida_tutorial.queue_free()
		iniciar_cutscene_final()

func iniciar_cutscene_final() -> void:
	var terminal = get_tree().get_first_node_in_group("Terminal")
	if terminal and terminal.has_method("desativar_botao_executar"):
		terminal.desativar_botao_executar()

	var player = get_tree().get_first_node_in_group("Player")
	if player:
		while player.moving:
			await get_tree().process_frame
		
		await ExecutarComTick.mover("Cima")
		
		while player.moving:
			await get_tree().process_frame
			
		player.set_physics_process(false) 
		
	GerenciadorAudio.parar_musica(1.0)
	
	var jogo = get_tree().get_first_node_in_group("Jogo")
	if jogo:
		await jogo.cobrir_tela_inteira(1.0)
		jogo.limpar_codigo_terminal()
		
		if tile_map: tile_map.hide()
		if player: player.hide()
		
		if cutscene_final:
			if jogo.sistema_cutscene:
				jogo.sistema_cutscene.iniciar_cutscene(cutscene_final)
			
			await jogo.revelar_tela_inteira(1.0)
			await jogo.sistema_cutscene.cutscene_finalizada
			await jogo.cobrir_tela_inteira(1.0)
			
			if jogo.sistema_cutscene:
				jogo.sistema_cutscene.hide()
			
		Constantes.PULAR_TUTORIAL = true
		FuncoesNativas.Partida.em_arena = false
		jogo.limpar_viewport()
		
		var vilarejo = jogo.CENA_VILAREJO.instantiate()
		jogo.viewport.add_child(vilarejo)
		
		if jogo.terminal.has_method("ativar_modo_vilarejo"):
			jogo.terminal.ativar_modo_vilarejo()
			
		await jogo.revelar_tela_inteira(1.0)
		
func resetar_player() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if not player: return

	player.set_physics_process(false)
	if "moving" in player:
		player.moving = false
	
	transition_rect.modulate.a = 0.0
	transition_rect.show()
	
	var tween = create_tween()
	tween.tween_property(transition_rect, "modulate:a", 1.0, tempo_fade_reset)
	await tween.finished
	
	player.global_position = pos_inicial_player
	
	if get_tree().root.has_node("FuncoesNativas"):
		FuncoesNativas._posicao_inicializada = false
		
	await get_tree().create_timer(0.1).timeout

	var tween_out = create_tween()
	tween_out.tween_property(transition_rect, "modulate:a", 0.0, tempo_fade_reset)
	await tween_out.finished
	
	player.set_physics_process(true)
	transition_rect.hide()
	
func iniciar_musica() -> void:
	if Constantes.TOCAR_MUSICA and musica_tema != null:
		GerenciadorAudio.tocar_musica(musica_tema, volume_musica_db)
