extends Button 

@export var escala_hover: Vector2 = Vector2(1.1, 1.1) 
@export var escala_clique: Vector2 = Vector2(0.9, 0.9) # O efeito de redução 
@export var tempo_transicao: float = 0.1 

var travado: bool = false # Nova trava de estado

func _ready() -> void: 
	mouse_entered.connect(_on_mouse_entered) 
	mouse_exited.connect(_on_mouse_exited) 
	button_down.connect(_on_button_down) 
	button_up.connect(_on_button_up) 
	pivot_offset = size / 2 

# Função para o Menu Principal usar no botão clicado
func travar_no_clique() -> void:
	travado = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE # Para de receber cliques
	_animar_escala(escala_clique) # Garante que ele fique reduzido

func _on_mouse_entered() -> void: 
	if travado: return
	pivot_offset = size / 2 
	_animar_escala(escala_hover) 

func _on_mouse_exited() -> void: 
	if travado: return
	_animar_escala(Vector2.ONE) 

func _on_button_down() -> void: 
	if travado: return
	_animar_escala(escala_clique)

func _on_button_up() -> void: 
	if travado: return
	# Se soltar e ainda estiver em cima, volta pro hover, senão volta pro normal
	var target = escala_hover if is_hovered() else Vector2.ONE
	_animar_escala(target)

func _animar_escala(target_scale: Vector2) -> void: 
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT) 
	tween.tween_property(self, "scale", target_scale, tempo_transicao)
