extends Control

@onready var titulo = %TituloInventario
@onready var container_cinto = %CintoContainer
@onready var container_mochila = %MochilaContainer

@onready var cinto_grafico = %CintoGrafico
@onready var mochila_grafico = %MochilaGrafico

@export_group("Polimento Visual")
@export var duracao_fade: float = 0.25

@export_group("Sons de Troca")
@export var som_abrir_cinto: AudioStream
@export var som_abrir_mochila: AudioStream
@export_range(-40.0, 10.0) var volume_troca_db: float = 0.0
@export var pitch_troca_min: float = 0.9
@export var pitch_troca_max: float = 1.1

var tween_graficos: Tween
var sfx_player: AudioStreamPlayer
var _ultimo_modo_cinto: bool = true
var _foi_inicializado: bool = false

func _ready() -> void:
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "UI"
	add_child(sfx_player)
	
	if not Inventario.inventario_comprados_atualizado.is_connected(atualizar_slots):
		Inventario.inventario_comprados_atualizado.connect(atualizar_slots)
	
	var is_cinto = (Inventario.inventario_ativo == Inventario.TipoInventario.CINTO)
	cinto_grafico.modulate.a = 1.0 if is_cinto else 0.0
	mochila_grafico.modulate.a = 0.0 if is_cinto else 1.0
	
	_ultimo_modo_cinto = is_cinto
	atualizar_slots()
	_foi_inicializado = true

func atualizar_slots() -> void:
	var is_cinto = (Inventario.inventario_ativo == Inventario.TipoInventario.CINTO)
	
	if _foi_inicializado and is_cinto != _ultimo_modo_cinto:
		_tocar_som_troca(is_cinto)
	_ultimo_modo_cinto = is_cinto
	
	titulo.text = "CINTO" if is_cinto else "MOCHILA"
	container_cinto.visible = is_cinto
	container_mochila.visible = not is_cinto
	
	_animar_troca_de_graficos(is_cinto)
	
	var lista_atual = Inventario.get_lista_ativa()
	var container_ativo = container_cinto if is_cinto else container_mochila
	
	var slots_visuais = []
	for filho in container_ativo.get_children():
		if filho.has_method("atualizar_slot_inventario"):
			slots_visuais.append(filho)
	
	var capacidade = slots_visuais.size()
	
	for i in range(capacidade):
		var botao = slots_visuais[i]
		var index_na_lista = i
		
		if not is_cinto:
			index_na_lista = (capacidade - 1) - i
			
		if index_na_lista < lista_atual.size() and lista_atual[index_na_lista] != null:
			botao.atualizar_slot_inventario(lista_atual[index_na_lista], index_na_lista)
		else:
			botao.atualizar_slot_inventario(null, index_na_lista)

func _animar_troca_de_graficos(is_cinto: bool) -> void:
	if tween_graficos and tween_graficos.is_valid():
		tween_graficos.kill()
		
	tween_graficos = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	if is_cinto:
		tween_graficos.tween_property(cinto_grafico, "modulate:a", 1.0, duracao_fade)
		tween_graficos.tween_property(mochila_grafico, "modulate:a", 0.0, duracao_fade)
	else:
		tween_graficos.tween_property(cinto_grafico, "modulate:a", 0.0, duracao_fade)
		tween_graficos.tween_property(mochila_grafico, "modulate:a", 1.0, duracao_fade)

func _tocar_som_troca(is_cinto: bool) -> void:
	var som = som_abrir_cinto if is_cinto else som_abrir_mochila
	if som:
		sfx_player.stream = som
		sfx_player.volume_db = volume_troca_db
		sfx_player.pitch_scale = randf_range(pitch_troca_min, pitch_troca_max)
		sfx_player.play()
