extends Control
class_name SistemaCutscene

signal cutscene_finalizada

@onready var imagem_fundo = %ImagemFundo
@onready var texto_dialogo = %TextoDialogo

@export_group("Configurações de Texto")
@export var velocidade_texto: float = 0.04
@export var tempo_fade_imagem: float = 0.5

@export_group("Áudio")
@export var som_voz: AudioStream
@export var volume_voz_db: float = 0.0
@export var pitch_min: float = 0.9
@export var pitch_max: float = 1.1

var cutscene_atual: CutsceneResource
var indice_pagina: int = 0
var indice_texto: int = 0
var em_transicao: bool = false
var digitando: bool = false
var sfx_voz: AudioStreamPlayer

func _ready() -> void:
	hide()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	sfx_voz = AudioStreamPlayer.new()
	sfx_voz.bus = "UI"
	add_child(sfx_voz)

func iniciar_cutscene(recurso: CutsceneResource) -> void:
	if recurso == null or recurso.paginas.is_empty():
		return
		
	cutscene_atual = recurso
	indice_pagina = 0
	indice_texto = 0
	em_transicao = true
	
	imagem_fundo.modulate.a = 0.0
	texto_dialogo.text = ""
	show()
	modulate = Color.WHITE
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	await get_tree().create_timer(cutscene_atual.delay_inicial).timeout
	if cutscene_atual == null: return
	
	if cutscene_atual.musica_tema:
		GerenciadorAudio.tocar_musica(
			cutscene_atual.musica_tema, 
			cutscene_atual.volume_musica_db, 
			cutscene_atual.tempo_fade_inicial, 
			cutscene_atual.usar_fade_in_audio
		)
	
	var pagina_atual = cutscene_atual.paginas[indice_pagina]
	imagem_fundo.texture = pagina_atual.imagem
	
	var tween = create_tween()
	tween.tween_property(imagem_fundo, "modulate:a", 1.0, cutscene_atual.tempo_fade_inicial)
	await tween.finished
	
	if cutscene_atual == null: return
	mostrar_texto()

func mostrar_pagina() -> void:
	if cutscene_atual == null: return
	
	em_transicao = true
	indice_texto = 0
	var pagina_atual = cutscene_atual.paginas[indice_pagina]
	
	var tween = create_tween()
	tween.tween_property(imagem_fundo, "modulate:a", 0.0, tempo_fade_imagem / 2.0)
	tween.tween_callback(func(): imagem_fundo.texture = pagina_atual.imagem)
	tween.tween_property(imagem_fundo, "modulate:a", 1.0, tempo_fade_imagem / 2.0)
	
	await tween.finished
	
	if cutscene_atual == null: return
	mostrar_texto()

func mostrar_texto() -> void:
	em_transicao = false
	if cutscene_atual == null: return
	
	if cutscene_atual.paginas[indice_pagina].textos.is_empty():
		avancar_pagina()
		return
		
	digitando = true
	var texto_atual = cutscene_atual.paginas[indice_pagina].textos[indice_texto]
	
	texto_dialogo.text = texto_atual
	texto_dialogo.visible_characters = 0
	
	var texto_puro = texto_dialogo.get_parsed_text()
	var total_caracteres = texto_puro.length()
	
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

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		
		if cutscene_atual == null or em_transicao:
			return
		
		if digitando:
			digitando = false 
		else:
			avancar_texto()
func avancar_texto() -> void:
	indice_texto += 1
	var pagina_atual = cutscene_atual.paginas[indice_pagina]
	
	if indice_texto < pagina_atual.textos.size():
		mostrar_texto()
	else:
		avancar_pagina()

func avancar_pagina() -> void:
	texto_dialogo.text = ""
	indice_pagina += 1
	
	if indice_pagina < cutscene_atual.paginas.size():
		mostrar_pagina()
	else:
		encerrar_cutscene()

func encerrar_cutscene() -> void:
	cutscene_atual = null
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	GerenciadorAudio.parar_musica(2.0)
	
	cutscene_finalizada.emit()
