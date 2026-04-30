extends VBoxContainer

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
@export var duracao_ganhar: float = 0.1
@export var cooldown_animacao_ganhar: float = 0.15

@onready var icone: TextureRect = %IconeRecursoLabirinto
@onready var label: Label = %TextoRecursoLabirinto

var _ultimo_pulo_msec: int = 0
var recurso_rastreado: ItemData = null

func _ready() -> void:
	if fonte_customizada: label.add_theme_font_override("font", fonte_customizada)
	label.add_theme_font_size_override("font_size", tamanho_fonte)
	label.add_theme_color_override("font_color", cor_fonte)
	if tamanho_contorno > 0:
		label.add_theme_color_override("font_outline_color", cor_contorno)
		label.add_theme_constant_override("outline_size", tamanho_contorno)
		
	RecursosManager.recursos_alterados.connect(_atualizar_texto)
	RecursosManager.recurso_ganho.connect(_ao_ganhar_recurso)

func setup(recurso: ItemData) -> void:
	recurso_rastreado = recurso
	if recurso != null:
		icone.texture = recurso.icone
		icone.custom_minimum_size = tamanho_icone
		icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_atualizar_texto()

func _atualizar_texto() -> void:
	if recurso_rastreado != null:
		var quantidade = RecursosManager.listarRecursos().get(recurso_rastreado, 0)
		label.text = formatar_numero(quantidade)

func _ao_ganhar_recurso(item: ItemData) -> void:
	if item == recurso_rastreado:
		var tempo_atual = Time.get_ticks_msec()
		var cooldown_msec = int(cooldown_animacao_ganhar * 1000)
		if tempo_atual - _ultimo_pulo_msec >= cooldown_msec:
			_ultimo_pulo_msec = tempo_atual
			_animar_pulo()

func _animar_pulo() -> void:
	icone.pivot_offset = icone.size / 2.0 
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(icone, "scale", escala_ao_ganhar, duracao_ganhar)
	tween.tween_property(icone, "scale", Vector2.ONE, duracao_ganhar)

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
