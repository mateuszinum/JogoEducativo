extends Control

@export_group("Estética do Debug")
@export var fonte_debug: Font
@export var tamanho_fonte_debug: int = 14
@export var cor_texto_debug: Color = Color.WHITE
@export var espacamento_linhas_debug: int = 0

@export_subgroup("Alinhamento e Posição")
@export var alinhamento_h_debug: HorizontalAlignment = HORIZONTAL_ALIGNMENT_RIGHT
@export var alinhamento_v_debug: VerticalAlignment = VERTICAL_ALIGNMENT_BOTTOM
@export var alinhamento_bloco_debug: BoxContainer.AlignmentMode = BoxContainer.ALIGNMENT_END

@export_subgroup("Sombra")
@export var cor_sombra_debug: Color = Color(0, 0, 0, 0.8)
@export var tamanho_sombra_debug: int = 1
@export var deslocamento_sombra_x: int = 1
@export var deslocamento_sombra_y: int = 1

@export_subgroup("Contorno (Borda)")
@export var cor_borda_debug: Color = Color.TRANSPARENT
@export var tamanho_borda_debug: int = 0

@export_subgroup("Animação")
@export var tempo_animacao_surgir: float = 0.25

@export_subgroup("Tutorial")
@export var dialogo_apresentacao: DialogoResource
@export var dialogo_duvida: DialogoResource

@onready var viewport = %SubViewport
@onready var terminal = %PainelTerminal
@onready var fade_tv = %FadeTV 
@onready var fade_rect = $FadeLayer/ColorRect 
@onready var sistema_cutscene = %SistemaCutscene
@onready var overlay_dialogo = %OverlayDialogo
@onready var botao_duvida = %BotaoDuvida
@onready var overlay_tutorial = %OverlayTutorial

const CENA_VILAREJO = preload("res://Scenes/UI/village_menu.tscn")
const CENA_ARENA = preload("res://Scenes/World/proc_gen_world.tscn")
const CENA_TUTORIAL = preload("res://Scenes/Tutorial/tutorial_world.tscn")

var transicao_em_andamento: bool = false

func _ready() -> void:
	add_to_group("Jogo") 
	limpar_viewport()
	overlay_tutorial.hide()
	
	SaveManager.CarregarProdutos()
	SaveManager.CarregarInventario()
	SaveManager.CarregarRecursos()
	
	if ProgressoDB.passou_do_tutorial():
		var vilarejo = CENA_VILAREJO.instantiate()
		viewport.add_child(vilarejo)
		if terminal and terminal.has_method("ativar_modo_vilarejo"):
			terminal.ativar_modo_vilarejo()
	else:
		var tutorial = CENA_TUTORIAL.instantiate()
		viewport.add_child(tutorial)
		ativar_modo_tutorial()
		if terminal and terminal.has_method("ativar_modo_tutorial"):
			terminal.ativar_modo_tutorial()
			
	SaveManager.CarregarCodigo()
	
	if not ProgressoDB.passou_do_tutorial() and terminal:
		var codigo_atual = terminal.get_codigo_slot(terminal.slot_atual_idx)
		if codigo_atual.strip_edges() == "":
			var codigo_tutorial = "mover(Baixo)\nmover(Direita)\nmover(Esquerda)\nmover(Cima)"
			terminal.definir_codigo_slot(terminal.slot_atual_idx, codigo_tutorial)

	if fade_rect:
		$FadeLayer.show()
		fade_rect.show()
		fade_rect.modulate.a = 1.0
		
		await get_tree().process_frame
		await get_tree().process_frame
		
		var tween = create_tween()
		tween.tween_property(fade_rect, "modulate:a", 0.0, 1.5)
		await tween.finished
		$FadeLayer.hide()

func cobrir_tela_inteira(tempo: float = 1.0) -> Signal:
	$FadeLayer.show()
	fade_rect.show()
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, tempo)
	return tween.finished

func revelar_tela_inteira(tempo: float = 1.0) -> Signal:
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, tempo)
	tween.tween_callback($FadeLayer.hide)
	return tween.finished

func tocar_cutscene(recurso: CutsceneResource) -> void:
	GerenciadorAudio.parar_musica()
	await cobrir_tela_inteira(1.0)
		
	if sistema_cutscene and recurso:
		sistema_cutscene.iniciar_cutscene(recurso)
		
	await revelar_tela_inteira(1.0)
	
	if sistema_cutscene:
		await sistema_cutscene.cutscene_finalizada
		
	await cobrir_tela_inteira(1.0)
	
	if sistema_cutscene:
		sistema_cutscene.hide()
		
	var cena_atual = viewport.get_child(0) if viewport.get_child_count() > 0 else null
	if cena_atual:
		if cena_atual.has_method("iniciar_musica"):
			cena_atual.iniciar_musica()
		elif cena_atual.has_method("play_stage_music"):
			cena_atual.play_stage_music()
		
	await revelar_tela_inteira(1.0)

func limpar_codigo_terminal() -> void:
	if terminal and terminal.has_method("limpar_codigo"):
		terminal.limpar_codigo()

func fazer_transicao_tv(cena_preload, modo_terminal: String) -> void:
	if transicao_em_andamento: return
	transicao_em_andamento = true
	
	fade_tv.show()
	fade_tv.modulate.a = 0.0
	var tween_out = create_tween()
	tween_out.tween_property(fade_tv, "modulate:a", 1.0, 1.0)
			
	await tween_out.finished
	
	limpar_viewport()
	if cena_preload:
		var nova_cena = cena_preload.instantiate()
		viewport.add_child(nova_cena)
		
	if modo_terminal == "vilarejo" and terminal.has_method("ativar_modo_vilarejo"):
		terminal.ativar_modo_vilarejo()
	elif modo_terminal == "arena" and terminal.has_method("ativar_modo_arena"):
		terminal.ativar_modo_arena()
		
	var tween_in = create_tween()
	tween_in.tween_property(fade_tv, "modulate:a", 0.0, 1.0)
	await tween_in.finished
	
	fade_tv.hide()
	transicao_em_andamento = false

func ir_para_vilarejo() -> void:
	fazer_transicao_tv(CENA_VILAREJO, "vilarejo")

func ir_para_arena() -> void:
	fazer_transicao_tv(CENA_ARENA, "arena")

func limpar_viewport() -> void:
	Atributos.resetar_xp_bonus_level()
	FuncoesNativas._posicao_inicializada = false
	if viewport:
		for child in viewport.get_children():
			viewport.remove_child(child) 
			child.queue_free()

func carregar_arena_via_codigo(novo_stage_data: Resource) -> void:
	if transicao_em_andamento: return
	transicao_em_andamento = true
	
	fade_tv.show()
	fade_tv.modulate.a = 0.0
	var tween_out = create_tween()
	tween_out.tween_property(fade_tv, "modulate:a", 1.0, 1.0)
	
	if viewport.get_child_count() > 0:
		var cena_atual = viewport.get_child(0)
		if cena_atual.has_node("MusicaVilarejo"):
			var musica = cena_atual.get_node("MusicaVilarejo")
			var tween_som = create_tween()
			tween_som.tween_property(musica, "volume_db", -40.0, 1.0)
			
	await tween_out.finished
	
	limpar_viewport()
	
	var nova_arena = CENA_ARENA.instantiate()
	nova_arena.stage_data = novo_stage_data
	viewport.add_child(nova_arena)
	
	if terminal.has_method("ativar_modo_arena"):
		terminal.ativar_modo_arena()
		
	var tween_in = create_tween()
	tween_in.tween_property(fade_tv, "modulate:a", 0.0, 1.0)
	await tween_in.finished
	fade_tv.hide()
	
	transicao_em_andamento = false
	
func escrever_debug(texto: String, cor_personalizada: Color = Color.TRANSPARENT) -> void:
	var container = get_node_or_null("%TextoDebug")
	if not container: return
	
	if container is VBoxContainer:
		container.alignment = alinhamento_bloco_debug
	
	var nova_mensagem = Label.new()
	nova_mensagem.text = texto
	nova_mensagem.autowrap_mode = TextServer.AUTOWRAP_WORD
	
	nova_mensagem.horizontal_alignment = alinhamento_h_debug
	nova_mensagem.vertical_alignment = alinhamento_v_debug
	nova_mensagem.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	if fonte_debug:
		nova_mensagem.add_theme_font_override("font", fonte_debug)
	if cor_personalizada != Color.TRANSPARENT:
		nova_mensagem.add_theme_color_override("font_color", cor_personalizada)
	else:
		nova_mensagem.add_theme_color_override("font_color", cor_texto_debug)
	nova_mensagem.add_theme_font_size_override("font_size", tamanho_fonte_debug)
	nova_mensagem.add_theme_constant_override("line_spacing", espacamento_linhas_debug)
	nova_mensagem.add_theme_color_override("font_shadow_color", cor_sombra_debug)
	nova_mensagem.add_theme_constant_override("shadow_outline_size", tamanho_sombra_debug)
	nova_mensagem.add_theme_constant_override("shadow_offset_x", deslocamento_sombra_x)
	nova_mensagem.add_theme_constant_override("shadow_offset_y", deslocamento_sombra_y)
	
	if tamanho_borda_debug > 0:
		nova_mensagem.add_theme_color_override("font_outline_color", cor_borda_debug)
		nova_mensagem.add_theme_constant_override("outline_size", tamanho_borda_debug)
	
	nova_mensagem.modulate.a = 0.0
	nova_mensagem.scale = Vector2(0.5, 0.5)
	
	container.add_child(nova_mensagem)
	
	await get_tree().process_frame
	if not is_instance_valid(nova_mensagem): return
	
	nova_mensagem.pivot_offset = nova_mensagem.size / 2
	
	var tween_surgir = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween_surgir.tween_property(nova_mensagem, "modulate:a", 1.0, tempo_animacao_surgir)
	tween_surgir.tween_property(nova_mensagem, "scale", Vector2.ONE, tempo_animacao_surgir)
	
	if container.get_child_count() > 50:
		var mensagem_velha = container.get_child(0)
		mensagem_velha.queue_free()
		
	await get_tree().create_timer(Constantes.TEMPO_ESCREVA).timeout
	
	if is_instance_valid(nova_mensagem):
		var tween_sumir = create_tween()
		tween_sumir.tween_property(nova_mensagem, "modulate:a", 0.0, 1.0)
		await tween_sumir.finished
		
		if is_instance_valid(nova_mensagem):
			nova_mensagem.queue_free()

# Chamado quando o jogador entra no tutorial
func ativar_modo_tutorial() -> void:
	overlay_tutorial.show()
	# Espera um frame para garantir que os nós estejam prontos e toca o diálogo
	await get_tree().process_frame 
	overlay_dialogo.iniciar_dialogo(dialogo_apresentacao)

# Chamado quando o jogador clica no botão de dúvida
func _on_botao_duvida_pressed() -> void:
	overlay_dialogo.iniciar_dialogo(dialogo_duvida)

# Chamado quando o jogador sai do tutorial (ex: quando desbloqueia o progresso)
func finalizar_modo_tutorial() -> void:
	overlay_tutorial.hide()
