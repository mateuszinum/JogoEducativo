extends Control

# Configurações para ajustar no Inspetor
@export var velocidade_rotacao: float = 15.0 # Graus por segundo
@export var pulsar: bool = true              # Opcional: faz brilhar levemente
@export var amplitude_pulso: float = 0.2     # Intensidade do brilho

var tempo: float = 0.0

func _ready() -> void:
	# Essencial: Define o centro do PNG como o ponto de giro
	pivot_offset = size / 2

func _process(delta: float) -> void:
	tempo += delta
	
	# Rotação contínua e suave
	rotation_degrees += velocidade_rotacao * delta
	
	# Efeito extra: Pulsação suave na transparência
	if pulsar:
		var brilho = 0.8 + (sin(tempo * 2.0) * amplitude_pulso)
		modulate.a = brilho
