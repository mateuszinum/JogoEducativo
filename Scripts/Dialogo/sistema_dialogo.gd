extends Control
class_name SistemaDialogo

const TEMPO_FRAME_ANIM = 0.06
const TEMPO_RESTORE_ANIM = 0.06

@onready var caixa_dialogo = %CaixaDialogo
@onready var texto_dialogo = %TextoDialogo 
@onready var fundo = $Fundo
@onready var container_opcoes = %ContainerOpcoes

@export_group("Referências Externas")
@export var personagem_animado: Control 
@export var prefab_botao_resposta: PackedScene

@export_group("Configurações de Diálogo")
@export var velocidade_texto: float = 0.03

@export_group("Efeitos de Fundo")
@export var cor_fundo: Color = Color(0.0, 0.0, 0.0, 0.6)
@export var usar_blur: bool = true
@export var intensidade_blur: float = 2.0
@export var tempo_fade_out: float = 0.2

@export_group("Tamanho e Layout")
@export var largura_minima_caixa: float = 100.0
@export var largura_maxima_caixa: float = 275.0
@export var espaco_acima_opcoes: float = 12.0

@export_group("Áudio do Diálogo")
@export var som_voz: AudioStream
@export var volume_voz_db: float = 0.0
@export var pitch_min: float = 0.95
@export var pitch_max: float = 1.1

@export_group("Animação do Personagem")
@export var escala_squash: Vector2 = Vector2(1.03, 0.97)
@export var escala_stretch: Vector2 = Vector2(0.97, 1.03)
@export var rotacao_maxima_graus: float = 3.0

@export_group("Animação da Caixa")
@export var escala_pulo_caixa: Vector2 = Vector2(1.1, 1.1)
@export var tempo_pulo_caixa: float = 0.15

var sfx_voz: AudioStreamPlayer
var dialogo_atual: DialogoResource
var pilha_dialogos: Array[Dictionary] = []
var lista_linhas_atual: Array[LinhaDialogo] = []
var indice_linha_atual: int = 0
var digitando: bool = false
var animacao_personagem: Tween
var animacao_caixa: Tween
var animacao_fade: Tween

func _ready() -> void:
	hide()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	sfx_voz = AudioStreamPlayer.new()
	sfx_voz.bus = "UI"
	add_child(sfx_voz)

func iniciar_dialogo(recurso: DialogoResource) -> void:
	if recurso == null or recurso.linhas.is_empty():
		return
		
	if animacao_fade and animacao_fade.is_valid():
		animacao_fade.kill()
		
	modulate = Color.WHITE
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	if fundo:
		fundo.color = cor_fundo
		if usar_blur and fundo.material is ShaderMaterial:
			fundo.material.set_shader_parameter("lod", intensidade_blur)
		elif fundo.material is ShaderMaterial:
			fundo.material.set_shader_parameter("lod", 0.0)
			
	pilha_dialogos.clear()
	dialogo_atual = recurso
	lista_linhas_atual = recurso.linhas
	indice_linha_atual = 0
	show() 
	mostrar_linha()

func calcular_largura_perfeita(texto: String, opcoes: Array[OpcaoDialogo] = []) -> float:
	var font = texto_dialogo.get_theme_font("normal_font")
	if not font: font = ThemeDB.fallback_font
	var font_size = texto_dialogo.get_theme_font_size("normal_font_size")
	
	var maior_largura: float = 0.0
	var largura_espaco = font.get_string_size(" ", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var linhas = texto.split("\n")
	
	for linha in linhas:
		var largura_linha_total = font.get_string_size(linha, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		if largura_linha_total <= largura_maxima_caixa:
			if largura_linha_total > maior_largura:
				maior_largura = largura_linha_total
			continue
			
		var palavras = linha.split(" ")
		var largura_atual: float = 0.0
		
		for palavra in palavras:
			var largura_palavra = font.get_string_size(palavra, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
			
			if largura_atual + largura_palavra > largura_maxima_caixa:
				var limpa = max(0.0, largura_atual - largura_espaco)
				if limpa > maior_largura:
					maior_largura = limpa
				largura_atual = largura_palavra + largura_espaco
			else:
				largura_atual += largura_palavra + largura_espaco
				
		var resto_limpo = max(0.0, largura_atual - largura_espaco)
		if resto_limpo > maior_largura:
			maior_largura = resto_limpo
			
	for opcao in opcoes:
		if opcao == null: continue
		var largura_opcao = font.get_string_size(opcao.texto_opcao, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x + 32.0
		if largura_opcao > maior_largura:
			maior_largura = largura_opcao
			
	return maior_largura

func ajustar_tamanho_caixa(texto_puro: String, opcoes: Array[OpcaoDialogo] = []) -> void:
	texto_dialogo.autowrap_mode = TextServer.AUTOWRAP_WORD
	var largura_calculada = calcular_largura_perfeita(texto_puro, opcoes)
	texto_dialogo.custom_minimum_size.x = clamp(largura_calculada, largura_minima_caixa, largura_maxima_caixa)

func _descartar_botao(botao: Node) -> void:
	container_opcoes.remove_child(botao)
	add_child(botao)
	if botao is CanvasItem:
		botao.hide()
	get_tree().create_timer(1.5).timeout.connect(botao.queue_free)

func mostrar_linha() -> void:
	digitando = true
	
	for child in container_opcoes.get_children():
		_descartar_botao(child)
		
	var linha_atual_obj = lista_linhas_atual[indice_linha_atual]
	
	caixa_dialogo.custom_minimum_size = Vector2.ZERO
	
	texto_dialogo.text = linha_atual_obj.texto
	texto_dialogo.visible_characters = -1
	
	var texto_puro = texto_dialogo.get_parsed_text()
	var total_caracteres = texto_puro.length()
	
	var array_opcoes: Array[OpcaoDialogo] = []
	if linha_atual_obj.tem_opcoes:
		array_opcoes = linha_atual_obj.opcoes
		
	ajustar_tamanho_caixa(texto_puro, array_opcoes)
	
	if array_opcoes.is_empty():
		container_opcoes.hide()
	else:
		container_opcoes.show()
		var espacador = Control.new()
		espacador.custom_minimum_size.y = espaco_acima_opcoes
		container_opcoes.add_child(espacador)
		
	for opcao in array_opcoes:
		if opcao == null: continue
		
		var btn: Button
		if prefab_botao_resposta:
			btn = prefab_botao_resposta.instantiate() as Button
		else:
			btn = Button.new()
			
		btn.text = opcao.texto_opcao
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		btn.pressed.connect(func(): _on_opcao_escolhida(opcao))
		
		btn.modulate.a = 0.0
		btn.disabled = true
		btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		container_opcoes.add_child(btn)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	caixa_dialogo.custom_minimum_size = caixa_dialogo.size
	
	texto_dialogo.visible_characters = 0
	
	iniciar_animacao_fala()
	animar_pulo_caixa()
	
	for i in range(total_caracteres):
		if not digitando:
			break 
			
		texto_dialogo.visible_characters += 1
		
		if texto_puro[i] != " " and som_voz != null: 
			sfx_voz.stream = som_voz
			sfx_voz.volume_db = volume_voz_db
			sfx_voz.pitch_scale = randf_range(pitch_min, pitch_max)
			sfx_voz.play()
			
		await get_tree().create_timer(velocidade_texto).timeout
			
	finalizar_escrita()

func finalizar_escrita() -> void:
	digitando = false
	texto_dialogo.visible_characters = -1 
	parar_animacao_fala()
	
	for btn in container_opcoes.get_children():
		if btn is Button:
			btn.disabled = false
			btn.mouse_filter = Control.MOUSE_FILTER_STOP
			
			var tween = create_tween()
			tween.tween_property(btn, "modulate:a", 1.0, 0.15)

func _on_opcao_escolhida(opcao: OpcaoDialogo) -> void:
	for child in container_opcoes.get_children():
		_descartar_botao(child)
		
	if opcao.linhas.size() > 0:
		pilha_dialogos.push_back({
			"lista": lista_linhas_atual,
			"indice": indice_linha_atual
		})
		lista_linhas_atual = opcao.linhas
		indice_linha_atual = 0
		mostrar_linha()
	else:
		encerrar_dialogo()

func avancar_dialogo() -> void:
	var linha_atual_obj = lista_linhas_atual[indice_linha_atual]
	if linha_atual_obj.tem_opcoes and container_opcoes.get_child_count() > 0:
		return
		
	indice_linha_atual += 1
	if indice_linha_atual < lista_linhas_atual.size():
		mostrar_linha()
	else:
		if pilha_dialogos.size() > 0:
			var estado = pilha_dialogos.pop_back()
			lista_linhas_atual = estado.lista
			indice_linha_atual = estado.indice
			avancar_dialogo()
		else:
			encerrar_dialogo()

func encerrar_dialogo() -> void:
	dialogo_atual = null
	parar_animacao_fala()
	
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if animacao_fade and animacao_fade.is_valid():
		animacao_fade.kill()
		
	animacao_fade = create_tween()
	animacao_fade.tween_property(self, "modulate", Color.TRANSPARENT, tempo_fade_out)
	animacao_fade.tween_callback(func(): hide())

func animar_pulo_caixa() -> void:
	if caixa_dialogo.size.y > 0 and caixa_dialogo.size.x > 0:
		caixa_dialogo.pivot_offset = Vector2(caixa_dialogo.size.x / 2.0, caixa_dialogo.size.y / 2.0)
	
	if animacao_caixa and animacao_caixa.is_valid():
		animacao_caixa.kill()
		
	caixa_dialogo.scale = Vector2.ONE
	animacao_caixa = create_tween()
	animacao_caixa.tween_property(caixa_dialogo, "scale", escala_pulo_caixa, tempo_pulo_caixa / 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	animacao_caixa.tween_property(caixa_dialogo, "scale", Vector2.ONE, tempo_pulo_caixa / 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func iniciar_animacao_fala() -> void:
	if personagem_animado == null or personagem_animado.size.y == 0: return
	
	personagem_animado.pivot_offset = Vector2(personagem_animado.size.x / 2.0, personagem_animado.size.y)
	
	if animacao_personagem and animacao_personagem.is_valid():
		animacao_personagem.kill()
		
	animacao_personagem = create_tween().set_loops()
	
	animacao_personagem.tween_property(personagem_animado, "scale", escala_squash, TEMPO_FRAME_ANIM)
	animacao_personagem.parallel().tween_property(personagem_animado, "rotation_degrees", rotacao_maxima_graus, TEMPO_FRAME_ANIM)
	
	animacao_personagem.tween_property(personagem_animado, "scale", escala_stretch, TEMPO_FRAME_ANIM)
	animacao_personagem.parallel().tween_property(personagem_animado, "rotation_degrees", -rotacao_maxima_graus, TEMPO_FRAME_ANIM)
	
	animacao_personagem.tween_property(personagem_animado, "scale", Vector2.ONE, TEMPO_FRAME_ANIM)
	animacao_personagem.parallel().tween_property(personagem_animado, "rotation_degrees", 0.0, TEMPO_FRAME_ANIM)

func parar_animacao_fala() -> void:
	if personagem_animado == null: return
	
	if animacao_personagem and animacao_personagem.is_valid():
		animacao_personagem.kill()
		
	var tween = create_tween()
	tween.tween_property(personagem_animado, "scale", Vector2.ONE, TEMPO_RESTORE_ANIM)
	tween.parallel().tween_property(personagem_animado, "rotation_degrees", 0.0, TEMPO_RESTORE_ANIM)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		accept_event() 
		
		if digitando:
			digitando = false 
		else:
			var linha_atual_obj = lista_linhas_atual[indice_linha_atual]
			if not linha_atual_obj.tem_opcoes:
				avancar_dialogo()
