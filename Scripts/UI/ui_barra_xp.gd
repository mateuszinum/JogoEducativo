extends Control

@export_group("Configurações Visuais")
@export var cor_normal: Color = Color("2e88f0")
@export var cor_max_level: Color = Color("f1c40f")
@export var texto_nivel_prefixo: String = "LV "
@export var texto_max_level: String = "MÁXIMO"

@export_group("Áudio")
@export var som_level_up: AudioStream
@export var volume_som_db: float = 0.0

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var label_nivel: Label = %TextoLevel

var is_pronto: bool = false

func _ready() -> void:
	Atributos.xp_alterado.connect(_on_xp_alterado)
	Atributos.subiu_de_nivel.connect(_on_subiu_de_nivel)
	Atributos.max_level_alcancado.connect(_on_max_level_alcancado)
	
	label_nivel.text = texto_nivel_prefixo + str(Atributos.level_atual)
	progress_bar.max_value = Atributos.LEVEL_UP_XP * Atributos.level_atual
	progress_bar.value = Atributos.xp_atual
	_atualizar_cor(cor_normal)
	
	if Atributos.level_atual >= Atributos.MAX_LEVEL:
		_on_max_level_alcancado()
		
	is_pronto = true

func _on_xp_alterado(xp_atual: int, xp_necessario: int) -> void:

	if Atributos.level_atual >= Atributos.MAX_LEVEL:
		progress_bar.max_value = 1
		progress_bar.value = 1
		return

	progress_bar.max_value = xp_necessario

	if xp_atual == 0:
		progress_bar.value = 0
	else:
		var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(progress_bar, "value", xp_atual, 0.4)

func _on_subiu_de_nivel(novo_nivel: int) -> void:

	if novo_nivel < Atributos.MAX_LEVEL:
		label_nivel.text = texto_nivel_prefixo + str(novo_nivel)

	if not is_pronto: return 
	
	if som_level_up != null:
		var audio = AudioStreamPlayer.new()
		audio.stream = som_level_up
		audio.volume_db = volume_som_db
		audio.bus = "UI"
		add_child(audio)
		audio.play()
		audio.finished.connect(audio.queue_free)

	var piscar = create_tween()
	progress_bar.modulate = Color(2.5, 2.5, 2.5, 1.0)
	piscar.tween_property(progress_bar, "modulate", Color.WHITE, 0.4)

	label_nivel.pivot_offset = label_nivel.size / 2.0

	var pop = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	label_nivel.scale = Vector2(1.8, 1.8)
	pop.tween_property(label_nivel, "scale", Vector2.ONE, 0.6)

	var shake = create_tween()
	shake.tween_property(label_nivel, "rotation_degrees", 12.0, 0.05)
	shake.tween_property(label_nivel, "rotation_degrees", -12.0, 0.05)
	shake.tween_property(label_nivel, "rotation_degrees", 6.0, 0.05)
	shake.tween_property(label_nivel, "rotation_degrees", 0.0, 0.05)

func _on_max_level_alcancado() -> void:
	progress_bar.max_value = 1
	progress_bar.value = 1
	label_nivel.text = texto_max_level
	_atualizar_cor(cor_max_level)

func _atualizar_cor(nova_cor: Color) -> void:
	if progress_bar.has_theme_stylebox("fill"):
		var estilo_atual = progress_bar.get_theme_stylebox("fill").duplicate()
		if estilo_atual is StyleBoxFlat:
			estilo_atual.bg_color = nova_cor
			progress_bar.add_theme_stylebox_override("fill", estilo_atual)
