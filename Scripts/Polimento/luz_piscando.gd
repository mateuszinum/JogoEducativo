extends Node

@export var luz: PointLight2D

@export_group("Energia da Luz")
@export var min_energy: float = 0.3
@export var max_energy: float = 0.6

@export_group("Escala da Textura")
@export var min_scale: float = 0.8
@export var max_scale: float = 1.1

@export_group("Velocidade (Segundos)")
@export var min_tempo_flicker: float = 0.05
@export var max_tempo_flicker: float = 0.2

var tween_flicker: Tween

func _ready() -> void:
	if not Constantes.GRÁFICO_HIGH:
		queue_free()
		return
	randomize()
	await get_tree().create_timer(randf_range(0.0, 0.5)).timeout
	_flicar_luz()

func _flicar_luz() -> void:
	if tween_flicker and tween_flicker.is_valid():
		tween_flicker.kill()
		
	var tempo_aleatorio = randf_range(min_tempo_flicker, max_tempo_flicker)
	var energy_aleatoria = randf_range(min_energy, max_energy)
	var scale_aleatoria = randf_range(min_scale, max_scale)
	
	tween_flicker = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_flicker.tween_property(luz, "energy", energy_aleatoria, tempo_aleatorio)
	tween_flicker.tween_property(luz, "texture_scale", scale_aleatoria, tempo_aleatorio)
	
	tween_flicker.chain().tween_callback(_flicar_luz)
