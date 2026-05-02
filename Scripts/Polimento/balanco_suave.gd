extends Control

@export_group("Movimento")
@export var amplitude_x: float = 15.0
@export var velocidade_x: float = 1.2
@export var amplitude_y: float = 10.0
@export var velocidade_y: float = 0.8

@export_group("Rotação Z")
@export var amplitude_rotacao: float = 1.0
@export var velocidade_rotacao: float = 1.0

var tempo: float = 0.0
var pos_inicial: Vector2

func _ready() -> void:
	# Salva a posição original para ter a referência do centro 
	pos_inicial = position
	# Garante que ele rotacione a partir do centro 
	pivot_offset = size / 2

func _process(delta: float) -> void:
	tempo += delta
	
	# Cálculo das ondas senoidais usando as variáveis exportadas 
	var x = sin(tempo * velocidade_x) * amplitude_x
	var y = cos(tempo * velocidade_y) * amplitude_y
	var rot = sin(tempo * velocidade_rotacao) * amplitude_rotacao
	
	# O SEGREDO: Arredondamos a posição final para evitar o meio-pixel e o jittering 
	position.x = round(pos_inicial.x + x)
	position.y = round(pos_inicial.y + y)
	
	# A rotação pode continuar quebrada, o Snap do Godot cuida dela 
	rotation_degrees = rot
