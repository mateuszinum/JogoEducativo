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

@onready var viewport = %SubViewport
@onready var terminal = %PainelTerminal
@onready var fade_tv = %FadeTV 
@onready var fade_rect = $FadeLayer/ColorRect 

const CENA_VILAREJO = preload("res://Scenes/UI/village_menu.tscn")
const CENA_ARENA = preload("res://Scenes/World/proc_gen_world.tscn")

var transicao_em_andamento: bool = false 

func _ready() -> void:
	add_to_group("Jogo") 
	limpar_viewport()
	var vilarejo = CENA_VILAREJO.instantiate()
	viewport.add_child(vilarejo)
	if terminal.has_method("ativar_modo_vilarejo"):
		terminal.ativar_modo_vilarejo()

	if fade_rect:
		$FadeLayer.show()
		fade_rect.show()
		fade_rect.modulate.a = 1.0
		
		var tween = create_tween()
		tween.tween_property(fade_rect, "modulate:a", 0.0, 1.5)
		await tween.finished
		$FadeLayer.hide()

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
	Atributos.resetar_multiplicador_labirinto(1.0)
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

func _on_botao_debug_pressed() -> void:
	pass

func _on_botao_recurso_pressed() -> void:
	RecursosManager.receberRecurso("Couro", 100)
	RecursosManager.receberRecurso("Cristal", 200)
	RecursosManager.receberRecurso("Diamante", 300)
	RecursosManager.receberRecurso("Esmeralda", 400)
	RecursosManager.receberRecurso("Magma", 500)
	RecursosManager.receberRecurso("Moeda", 9000000000)
	RecursosManager.receberRecurso("Osso", 1000)
	RecursosManager.receberRecurso("Plasma", 56)
	RecursosManager.receberRecurso("Safira", 275)
	RecursosManager.receberRecurso("Sangue", 5125)
	pass
	
func escrever_debug(texto: String) -> void:
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
	nova_mensagem.add_theme_font_size_override("font_size", tamanho_fonte_debug)
	nova_mensagem.add_theme_color_override("font_color", cor_texto_debug)
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

func _on_botao_atributos_pressed() -> void:
	Atributos.maximizar_agilidade()

func _on_botao_musica_pressed() -> void:
	if Constantes.VOLUME_MUSICA == 0.0:
		Constantes.VOLUME_MUSICA = 0.5
	else:
		Constantes.VOLUME_MUSICA = 0.0
