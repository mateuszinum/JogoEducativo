extends Control

@onready var container = $MarginContainer/HBoxContainer

@export var largura_do_slot: int = 50
@export var espacamento_vertical: int = 2
@export var ordem_preferencial: Array[ItemData] = []

@export_group("Configurações do Ícone")
@export var tamanho_icone: Vector2 = Vector2(24, 24)

@export_group("Configurações do Texto")
@export var fonte_customizada: Font
@export var tamanho_fonte: int = 16
@export var cor_fonte: Color = Color.WHITE
@export var cor_contorno: Color = Color.BLACK
@export var tamanho_contorno: int = 0

@export_group("Escalas de Feedback")
@export var escala_ao_ganhar: Vector2 = Vector2(1.2, 1.2)
@export var escala_ao_gastar: Vector2 = Vector2(0.8, 0.8)
@export var escala_ao_falhar: Vector2 = Vector2(0.8, 0.8)

@export_group("Velocidades (Segundos)")
@export var cooldown_animacao_ganhar: float = 0.15
@export var duracao_ganhar: float = 0.1
@export var duracao_gastar: float = 0.1
@export var duracao_falha: float = 0.1
@export var cor_erro: Color = Color(1.0, 0.2, 0.2)

var slots_ativos: Dictionary = {} 
var _ultimo_pulo_por_item: Dictionary = {}

func _ready() -> void:
	add_to_group("UI_Inventario") 
	RecursosManager.recursos_alterados.connect(atualizar_tela)
	RecursosManager.recurso_ganho.connect(_ao_ganhar_recurso)
	RecursosManager.recurso_gasto.connect(_ao_gastar_recurso)
	RecursosManager.falha_pagamento.connect(_ao_falhar_pagamento)
	atualizar_tela()

func atualizar_tela() -> void:
	var recursos_atuais = RecursosManager.listarRecursos()
	
	var itens_para_remover = []
	for item_data in slots_ativos.keys():
		if not recursos_atuais.has(item_data):
			itens_para_remover.append(item_data)
	
	for item_data in itens_para_remover:
		slots_ativos[item_data].queue_free()
		slots_ativos.erase(item_data)

	var itens_ordenados = _ordenar_recursos(recursos_atuais.keys())
	
	for i in range(itens_ordenados.size()):
		var item_data = itens_ordenados[i]
		var quantidade = recursos_atuais[item_data]
		
		if not slots_ativos.has(item_data):
			var novo_slot = _criar_slot_visual(item_data)
			container.add_child(novo_slot)
			slots_ativos[item_data] = novo_slot
		
		container.move_child(slots_ativos[item_data], i)
		slots_ativos[item_data].get_node("Label").text = formatar_numero(quantidade)

func _ordenar_recursos(lista_de_objetos: Array) -> Array:
	var ordenados = []
	var restantes = lista_de_objetos.duplicate()
	
	for item_preferido in ordem_preferencial:
		if item_preferido != null and restantes.has(item_preferido):
			ordenados.append(item_preferido)
			restantes.erase(item_preferido)
				
	ordenados.append_array(restantes)
	return ordenados

func _criar_slot_visual(item: ItemData) -> VBoxContainer:
	var slot = VBoxContainer.new()
	slot.custom_minimum_size.x = largura_do_slot
	slot.add_theme_constant_override("separation", espacamento_vertical)
	
	var icone = TextureRect.new()
	icone.name = "Icone"
	icone.texture = item.icone
	icone.custom_minimum_size = tamanho_icone
	icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icone.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icone.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icone.pivot_offset = tamanho_icone / 2.0
	
	var texto = Label.new()
	texto.name = "Label"
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.autowrap_mode = TextServer.AUTOWRAP_OFF
	texto.clip_text = true
	
	if fonte_customizada: texto.add_theme_font_override("font", fonte_customizada)
	texto.add_theme_font_size_override("font_size", tamanho_fonte)
	texto.add_theme_color_override("font_color", cor_fonte)
	if tamanho_contorno > 0:
		texto.add_theme_color_override("font_outline_color", cor_contorno)
		texto.add_theme_constant_override("outline_size", tamanho_contorno)
	
	slot.add_child(icone)
	slot.add_child(texto)
	return slot

func _ao_ganhar_recurso(item: ItemData) -> void:
	var tempo_atual = Time.get_ticks_msec()
	var ultimo_tempo = _ultimo_pulo_por_item.get(item, 0)
	var cooldown_msec = int(cooldown_animacao_ganhar * 1000)
	if tempo_atual - ultimo_tempo >= cooldown_msec:
		_ultimo_pulo_por_item[item] = tempo_atual
		_animar_pulo(item, escala_ao_ganhar, duracao_ganhar)

func _ao_gastar_recurso(item: ItemData) -> void:
	_animar_pulo(item, escala_ao_gastar, duracao_gastar)

func _animar_pulo(item: ItemData, escala_alvo: Vector2, tempo: float) -> void:
	if slots_ativos.has(item):
		var icone = slots_ativos[item].get_node("Icone")
		icone.pivot_offset = tamanho_icone / 2.0 
		var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(icone, "scale", escala_alvo, tempo)
		tween.tween_property(icone, "scale", Vector2.ONE, tempo)

func _ao_falhar_pagamento(item: ItemData) -> void:
	if slots_ativos.has(item):
		var icone = slots_ativos[item].get_node("Icone")
		icone.pivot_offset = tamanho_icone / 2.0
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
		tween.set_parallel(true)
		tween.tween_property(icone, "modulate", cor_erro, duracao_falha)
		tween.tween_property(icone, "scale", escala_ao_falhar, duracao_falha)
		
		tween.set_parallel(false)
		tween.tween_interval(0.05)
		
		tween.set_parallel(true)
		tween.tween_property(icone, "modulate", Color.WHITE, duracao_falha)
		tween.tween_property(icone, "scale", Vector2.ONE, duracao_falha)

func formatar_numero(valor: int) -> String:
	if valor < 1000: return str(valor)
	var sufixos = ["", "k", "m", "b", "t"]
	var indice = 0
	var v_float = float(valor)
	while v_float >= 1000.0 and indice < sufixos.size() - 1:
		v_float /= 1000.0
		indice += 1
	var s = sufixos[indice]
	var p_int = int(v_float)
	if p_int >= 100 or p_int >= 10: return str(p_int) + s
	else:
		var p_dec = int((v_float - p_int) * 10)
		return (str(p_int) + "." + str(p_dec) + s) if p_dec > 0 else (str(p_int) + s)
