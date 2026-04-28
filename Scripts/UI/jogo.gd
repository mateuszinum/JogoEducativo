extends Control

@onready var viewport = %SubViewport
@onready var terminal = %PainelTerminal
@onready var fade_tv = %FadeTV 
@onready var fade_rect = $FadeLayer/ColorRect 

const CENA_VILAREJO = preload("res://Scenes/UI/village_menu.tscn")
const CENA_ARENA = preload("res://Scenes/World/proc_gen_world.tscn")

var transicao_em_andamento: bool = false 

func _ready() -> void:
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
	
	if viewport.get_child_count() > 0:
		var cena_atual = viewport.get_child(0)
		if cena_atual.has_node("MusicaVilarejo"):
			var musica = cena_atual.get_node("MusicaVilarejo")
			var tween_som = create_tween()
			tween_som.tween_property(musica, "volume_db", -40.0, 1.0)
			
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
