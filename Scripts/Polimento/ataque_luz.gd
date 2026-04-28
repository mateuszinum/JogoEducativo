extends PointLight2D

@export_group("Configurações Visuais")
@export var cor_luz : Color = Color(1, 0.8, 0.4, 1) # Cor da luz
@export var energia_base : float = 1.0           # Brilho inicial
@export var escala_base : float = 1.0            # Tamanho inicial

@export_group("Comportamento")
@export var tempo_fade_out : float = 0.4         # Segundos até dissipar
@export var pulsar : bool = true                 # Se a luz fica "viva"
@export var pulso_velocidade : float = 5.0
@export var pulso_intensidade : float = 0.2

var _morrendo : bool = false

func _ready() -> void:
	if not Constantes.GRÁFICO_HIGH:
		queue_free()
		return
	color = cor_luz
	energy = energia_base
	texture_scale = escala_base

func _process(_delta: float) -> void:
	if pulsar and not _morrendo:
		# Cria um efeito de oscilação natural na energia da luz
		energy = energia_base + (sin(Time.get_ticks_msec() * 0.001 * pulso_velocidade) * pulso_intensidade)

func dissipar() -> void:
	if _morrendo: return
	_morrendo = true
	
	# TRUQUE: Anota a posição e a cena ANTES de remover o nó
	var pos_global = global_position
	var cena_atual = get_tree().current_scene 
	
	# Agora sim podemos remover e readicionar com segurança
	get_parent().remove_child(self)
	cena_atual.add_child(self)
	global_position = pos_global
	
	# Animação de dissipação
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "energy", 0.0, tempo_fade_out)
	tween.tween_property(self, "texture_scale", escala_base * 1.3, tempo_fade_out)
	
	# Se deleta ao final do fade
	tween.chain().tween_callback(queue_free)
